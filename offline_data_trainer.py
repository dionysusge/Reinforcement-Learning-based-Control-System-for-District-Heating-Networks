#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
离线数据训练脚本

作者: Dionysus
日期: 2025-01-09
描述: 直接使用离线数据进行训练，验证模型保存和TensorBoard功能
"""

import os
import json
import logging
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.tensorboard import SummaryWriter
from datetime import datetime
from typing import List, Dict, Any, Tuple


class OfflineDataTrainer:
    """
    离线数据训练器
    """
    
    def __init__(self, config: Dict[str, Any]):
        """
        初始化离线数据训练器
        
        Args:
            config: 配置字典
        """
        self.config = config
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        # 创建保存目录
        self.save_dir = config['save_dir']
        os.makedirs(f"{self.save_dir}/models", exist_ok=True)
        os.makedirs(f"{self.save_dir}/stats", exist_ok=True)
        os.makedirs(f"{self.save_dir}/tensorboard", exist_ok=True)
        
        # 初始化TensorBoard
        self.writer = SummaryWriter(f"{self.save_dir}/tensorboard")
        self.global_step = 0
        
        # 构建网络
        self.policy_net = self._build_policy_network()
        self.value_net = self._build_value_network()
        
        # 优化器
        self.policy_optimizer = optim.Adam(self.policy_net.parameters(), lr=config['learning_rate'])
        self.value_optimizer = optim.Adam(self.value_net.parameters(), lr=config['learning_rate'])
        
        # 损失函数
        self.mse_loss = nn.MSELoss()
        
        # 训练统计
        self.training_losses = []
        self.episode_rewards = []
        
        # 日志
        self.logger = logging.getLogger(__name__)
    
    def _build_policy_network(self) -> nn.Module:
        """
        构建策略网络
        
        Returns:
            nn.Module: 策略网络
        """
        return nn.Sequential(
            nn.Linear(self.config['state_dim'], self.config['hidden_dim']),
            nn.ReLU(),
            nn.Linear(self.config['hidden_dim'], self.config['hidden_dim']),
            nn.ReLU(),
            nn.Linear(self.config['hidden_dim'], self.config['action_dim']),
            nn.Sigmoid()  # 输出0-1之间的阀门开度
        ).to(self.device)
    
    def _build_value_network(self) -> nn.Module:
        """
        构建价值网络
        
        Returns:
            nn.Module: 价值网络
        """
        return nn.Sequential(
            nn.Linear(self.config['state_dim'], self.config['hidden_dim']),
            nn.ReLU(),
            nn.Linear(self.config['hidden_dim'], self.config['hidden_dim']),
            nn.ReLU(),
            nn.Linear(self.config['hidden_dim'], 1)
        ).to(self.device)
    
    def load_offline_data(self, data_file: str) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
        """
        加载离线数据
        
        Args:
            data_file: 数据文件路径
            
        Returns:
            Tuple[np.ndarray, np.ndarray, np.ndarray]: 状态、动作、奖励数据
        """
        self.logger.info(f"加载离线数据: {data_file}")
        
        with open(data_file, 'r') as f:
            data = json.load(f)
        
        states = []
        actions = []
        rewards = []
        
        for step_data in data:
            states.append(step_data['state'])
            actions.append(step_data['action'])
            # 计算简单奖励：基于回水温度与目标温度的差异
            target_temp = self.config['target_return_temp']
            return_temps = step_data['state'][1::4]  # 每4个状态中的第2个是回水温度
            avg_return_temp = np.mean(return_temps)
            reward = -abs(avg_return_temp - target_temp)  # 越接近目标温度奖励越高
            rewards.append(reward)
        
        states = np.array(states, dtype=np.float32)
        actions = np.array(actions, dtype=np.float32)
        rewards = np.array(rewards, dtype=np.float32)
        
        self.logger.info(f"数据加载完成: {len(states)} 个样本")
        self.logger.info(f"状态维度: {states.shape}, 动作维度: {actions.shape}")
        self.logger.info(f"奖励范围: [{rewards.min():.3f}, {rewards.max():.3f}]")
        
        return states, actions, rewards
    
    def train_on_batch(self, states: torch.Tensor, actions: torch.Tensor, rewards: torch.Tensor) -> Dict[str, float]:
        """
        在一个批次上训练
        
        Args:
            states: 状态张量
            actions: 动作张量
            rewards: 奖励张量
            
        Returns:
            Dict[str, float]: 训练统计
        """
        # 策略网络训练（监督学习）
        self.policy_optimizer.zero_grad()
        predicted_actions = self.policy_net(states)
        policy_loss = self.mse_loss(predicted_actions, actions)
        policy_loss.backward()
        self.policy_optimizer.step()
        
        # 价值网络训练
        self.value_optimizer.zero_grad()
        predicted_values = self.value_net(states).squeeze()
        value_loss = self.mse_loss(predicted_values, rewards)
        value_loss.backward()
        self.value_optimizer.step()
        
        return {
            'policy_loss': policy_loss.item(),
            'value_loss': value_loss.item(),
            'total_loss': policy_loss.item() + value_loss.item()
        }
    
    def train_epoch(self, states: np.ndarray, actions: np.ndarray, rewards: np.ndarray, epoch: int) -> Dict[str, float]:
        """
        训练一个epoch
        
        Args:
            states: 状态数据
            actions: 动作数据
            rewards: 奖励数据
            epoch: 当前epoch
            
        Returns:
            Dict[str, float]: epoch统计
        """
        batch_size = self.config['batch_size']
        num_samples = len(states)
        num_batches = (num_samples + batch_size - 1) // batch_size
        
        epoch_losses = []
        
        # 随机打乱数据
        indices = np.random.permutation(num_samples)
        states = states[indices]
        actions = actions[indices]
        rewards = rewards[indices]
        
        for batch_idx in range(num_batches):
            start_idx = batch_idx * batch_size
            end_idx = min(start_idx + batch_size, num_samples)
            
            batch_states = torch.FloatTensor(states[start_idx:end_idx]).to(self.device)
            batch_actions = torch.FloatTensor(actions[start_idx:end_idx]).to(self.device)
            batch_rewards = torch.FloatTensor(rewards[start_idx:end_idx]).to(self.device)
            
            batch_stats = self.train_on_batch(batch_states, batch_actions, batch_rewards)
            epoch_losses.append(batch_stats)
            
            self.global_step += 1
        
        # 计算epoch平均损失
        avg_policy_loss = np.mean([loss['policy_loss'] for loss in epoch_losses])
        avg_value_loss = np.mean([loss['value_loss'] for loss in epoch_losses])
        avg_total_loss = np.mean([loss['total_loss'] for loss in epoch_losses])
        
        # 记录到TensorBoard
        self.writer.add_scalar('Loss/Policy', avg_policy_loss, epoch)
        self.writer.add_scalar('Loss/Value', avg_value_loss, epoch)
        self.writer.add_scalar('Loss/Total', avg_total_loss, epoch)
        
        # 计算并记录平均奖励
        avg_reward = np.mean(rewards)
        self.writer.add_scalar('Training/Average_Reward', avg_reward, epoch)
        self.episode_rewards.append(avg_reward)
        
        epoch_stats = {
            'epoch': epoch,
            'policy_loss': avg_policy_loss,
            'value_loss': avg_value_loss,
            'total_loss': avg_total_loss,
            'avg_reward': avg_reward,
            'num_batches': num_batches
        }
        
        self.training_losses.append(epoch_stats)
        return epoch_stats
    
    def save_model(self, epoch: int):
        """
        保存模型
        
        Args:
            epoch: 当前epoch
        """
        model_path = f"{self.save_dir}/models/model_epoch_{epoch}.pth"
        
        checkpoint = {
            'epoch': epoch,
            'policy_net_state_dict': self.policy_net.state_dict(),
            'value_net_state_dict': self.value_net.state_dict(),
            'policy_optimizer_state_dict': self.policy_optimizer.state_dict(),
            'value_optimizer_state_dict': self.value_optimizer.state_dict(),
            'config': self.config,
            'global_step': self.global_step,
            'training_losses': self.training_losses,
            'episode_rewards': self.episode_rewards,
            'timestamp': datetime.now().isoformat()
        }
        
        torch.save(checkpoint, model_path)
        self.logger.info(f"模型已保存: {model_path}")
    
    def save_training_stats(self, epoch: int):
        """
        保存训练统计
        
        Args:
            epoch: 当前epoch
        """
        stats_path = f"{self.save_dir}/stats/training_stats_epoch_{epoch}.json"
        
        # 转换numpy类型为Python原生类型
        def convert_numpy_types(obj):
            if isinstance(obj, np.floating):
                return float(obj)
            elif isinstance(obj, np.integer):
                return int(obj)
            elif isinstance(obj, np.ndarray):
                return obj.tolist()
            elif isinstance(obj, dict):
                return {k: convert_numpy_types(v) for k, v in obj.items()}
            elif isinstance(obj, list):
                return [convert_numpy_types(item) for item in obj]
            return obj
        
        stats = {
            'epoch': epoch,
            'global_step': self.global_step,
            'training_losses': convert_numpy_types(self.training_losses),
            'episode_rewards': convert_numpy_types(self.episode_rewards),
            'config': convert_numpy_types(self.config),
            'timestamp': datetime.now().isoformat()
        }
        
        with open(stats_path, 'w') as f:
            json.dump(stats, f, indent=2)
        
        self.logger.info(f"训练统计已保存: {stats_path}")
    
    def close_tensorboard(self):
        """
        关闭TensorBoard writer
        """
        if hasattr(self, 'writer'):
            self.writer.close()
            self.logger.info("TensorBoard writer已关闭")


def setup_logging():
    """
    设置日志
    """
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    return logging.getLogger(__name__)


def main():
    """
    主函数
    """
    logger = setup_logging()
    logger.info("开始离线数据训练")
    
    # 配置
    config = {
        "state_dim": 92,
        "action_dim": 23,
        "hidden_dim": 128,
        "learning_rate": 0.001,
        "batch_size": 32,
        "num_epochs": 50,
        "save_frequency": 10,
        "target_return_temp": 30.0,
        "save_dir": "offline_training_results"
    }
    
    try:
        # 创建训练器
        trainer = OfflineDataTrainer(config)
        
        # 加载数据
        data_file = "offline_data/offline_data_1440_20250809_174526_final.json"
        states, actions, rewards = trainer.load_offline_data(data_file)
        
        # 训练循环
        for epoch in range(1, config['num_epochs'] + 1):
            logger.info(f"Epoch {epoch}/{config['num_epochs']}")
            
            epoch_stats = trainer.train_epoch(states, actions, rewards, epoch)
            
            logger.info(f"Epoch {epoch} 完成: "
                       f"策略损失={epoch_stats['policy_loss']:.4f}, "
                       f"价值损失={epoch_stats['value_loss']:.4f}, "
                       f"平均奖励={epoch_stats['avg_reward']:.3f}")
            
            # 定期保存
            if epoch % config['save_frequency'] == 0:
                trainer.save_model(epoch)
                trainer.save_training_stats(epoch)
        
        # 最终保存
        trainer.save_model(config['num_epochs'])
        trainer.save_training_stats(config['num_epochs'])
        
        logger.info("训练完成!")
        logger.info(f"TensorBoard日志: {config['save_dir']}/tensorboard")
        logger.info(f"模型文件: {config['save_dir']}/models")
        
        # 关闭
        trainer.close_tensorboard()
        
    except Exception as e:
        logger.error(f"训练失败: {e}")
        import traceback
        logger.error(f"错误详情: {traceback.format_exc()}")


if __name__ == "__main__":
    main()