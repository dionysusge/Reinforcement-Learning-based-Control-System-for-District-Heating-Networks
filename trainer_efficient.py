#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
高效训练器
作者: Dionysus
日期: 2025-08-08

基于成功的v2版本，优化训练流程，支持离线数据收集
"""

import os
import json
import time
import logging
from datetime import datetime
from typing import Dict, List, Any, Tuple

import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.distributions import Normal
from torch.utils.tensorboard import SummaryWriter


class ActorCritic(nn.Module):
    """
    Actor-Critic网络
    """
    
    def __init__(self, state_dim: int, action_dim: int, hidden_dim: int = 128):
        """
        初始化网络
        
        Args:
            state_dim: 状态维度
            action_dim: 动作维度
            hidden_dim: 隐藏层维度
        """
        super(ActorCritic, self).__init__()
        
        # 共享特征提取层
        self.shared_layers = nn.Sequential(
            nn.Linear(state_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU()
        )
        
        # Actor网络（策略网络）
        self.actor_mean = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, action_dim)
        )
        
        # 自定义激活函数：将输出映射到[0.5, 1.0]范围
        self.action_activation = lambda x: torch.sigmoid(x) * 0.5 + 0.5
        
        self.actor_std = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, action_dim),
            nn.Softplus()  # 确保标准差为正
        )
        
        # Critic网络（价值网络）
        self.critic = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, 1)
        )
        
    def forward(self, state: torch.Tensor) -> Tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
        """
        前向传播
        
        Args:
            state: 状态张量
            
        Returns:
            Tuple[torch.Tensor, torch.Tensor, torch.Tensor]: (动作均值, 动作标准差, 状态价值)
        """
        features = self.shared_layers(state)
        
        # 使用自定义激活函数输出[0.5, 1.0]范围的动作
        action_mean_raw = self.actor_mean(features)
        action_mean = self.action_activation(action_mean_raw)
        action_std = self.actor_std(features) + 1e-3  # 避免标准差为0
        value = self.critic(features)
        
        return action_mean, action_std, value
    
    def get_action(self, state: torch.Tensor) -> Tuple[torch.Tensor, torch.Tensor]:
        """
        获取动作
        
        Args:
            state: 状态张量
            
        Returns:
            Tuple[torch.Tensor, torch.Tensor]: (动作, 动作对数概率)
        """
        action_mean, action_std, _ = self.forward(state)
        
        # 创建正态分布
        dist = Normal(action_mean, action_std)
        
        # 采样动作
        action = dist.sample()
        action_log_prob = dist.log_prob(action).sum(dim=-1)
        
        # 限制动作范围到[0.5, 1.0]（50%-100%开度）
        action = torch.clamp(action, 0.5, 1.0)
        
        return action, action_log_prob
    
    def evaluate_action(self, state: torch.Tensor, action: torch.Tensor) -> Tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
        """
        评估动作
        
        Args:
            state: 状态张量
            action: 动作张量
            
        Returns:
            Tuple[torch.Tensor, torch.Tensor, torch.Tensor]: (动作对数概率, 状态价值, 熵)
        """
        action_mean, action_std, value = self.forward(state)
        
        # 创建正态分布
        dist = Normal(action_mean, action_std)
        
        # 计算动作对数概率和熵
        action_log_prob = dist.log_prob(action).sum(dim=-1)
        entropy = dist.entropy().sum(dim=-1)
        
        return action_log_prob, value.squeeze(), entropy


class TrainerEfficient:
    """
    高效训练器
    
    特点:
    1. 基于PPO算法
    2. 支持离线数据收集
    3. 优化训练流程
    4. 定期保存模型和统计信息
    """
    
    def __init__(self, config: Dict[str, Any]):
        """
        初始化训练器
        
        Args:
            config: 配置字典
        """
        self.config = config
        self.logger = logging.getLogger(__name__)
        
        # 训练参数
        self.state_dim = config.get('state_dim', 92)  # 23个楼栋 * 4个状态
        self.action_dim = config.get('action_dim', 23)  # 23个阀门
        self.hidden_dim = config.get('hidden_dim', 128)
        self.learning_rate = config.get('learning_rate', 3e-4)
        self.gamma = config.get('gamma', 0.99)  # 折扣因子
        self.gae_lambda = config.get('gae_lambda', 0.95)  # GAE参数
        self.clip_epsilon = config.get('clip_epsilon', 0.2)  # PPO裁剪参数
        self.entropy_coef = config.get('entropy_coef', 0.01)  # 熵系数
        self.value_coef = config.get('value_coef', 0.5)  # 价值损失系数
        self.max_grad_norm = config.get('max_grad_norm', 0.5)  # 梯度裁剪
        
        # 训练设置
        self.batch_size = config.get('batch_size', 64)
        self.update_epochs = config.get('update_epochs', 4)
        self.update_frequency = config.get('update_frequency', 10)  # 每10步更新一次
        
        # 设备
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.logger.info(f"使用设备: {self.device}")
        
        # 创建网络
        self.actor_critic = ActorCritic(self.state_dim, self.action_dim, self.hidden_dim).to(self.device)
        self.optimizer = optim.Adam(self.actor_critic.parameters(), lr=self.learning_rate)
        
        # 经验缓冲区
        self.states = []
        self.actions = []
        self.rewards = []
        self.values = []
        self.log_probs = []
        self.dones = []
        
        # 统计信息
        self.episode_rewards = []
        self.episode_lengths = []
        self.training_stats = []
        
        # 动作平滑参数
        self.min_action_change = config.get('min_action_change', 0.05)  # 最小变化量
        self.max_action_change = config.get('max_action_change', 0.2)   # 最大变化量
        self.previous_action = None  # 存储上一次的动作
        
        # 使用环境的instance_id作为训练会话标号，确保一致性
        self.session_id = config.get('instance_id', int(time.time() * 1000) % 10000)
        
        # 保存路径（使用training_result目录结构）
        base_training_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'training_result')
        self.save_dir = os.path.join(base_training_dir, str(self.session_id))
        os.makedirs(self.save_dir, exist_ok=True)
        os.makedirs(os.path.join(self.save_dir, 'models'), exist_ok=True)
        os.makedirs(os.path.join(self.save_dir, 'stats'), exist_ok=True)
        
        # TensorBoard日志
        self.tensorboard_dir = os.path.join(self.save_dir, 'tensorboard')
        os.makedirs(self.tensorboard_dir, exist_ok=True)
        self.writer = SummaryWriter(log_dir=self.tensorboard_dir)
        
        # 记录训练会话信息
        self.logger.info(f"训练会话ID: {self.session_id}")
        self.logger.info(f"保存目录: {self.save_dir}")
        self.logger.info(f"TensorBoard日志: {self.tensorboard_dir}")
        
        # 训练步数计数器
        self.global_step = 0
        self.episode_count = 0
        
    def select_action(self, state: np.ndarray) -> Tuple[np.ndarray, float, float]:
        """
        选择动作（带动作平滑）
        
        Args:
            state: 当前状态
            
        Returns:
            Tuple[np.ndarray, float, float]: (平滑后的动作, 动作对数概率, 状态价值)
        """
        with torch.no_grad():
            state_tensor = torch.FloatTensor(state).unsqueeze(0).to(self.device)
            raw_action, log_prob = self.actor_critic.get_action(state_tensor)
            _, _, value = self.actor_critic.forward(state_tensor)
            
            # 获取原始动作
            raw_action_np = raw_action.cpu().numpy()[0]
            
            # 如果是第一次动作，直接返回
            if self.previous_action is None:
                self.previous_action = raw_action_np.copy()
                return raw_action_np, log_prob.cpu().item(), value.cpu().item()
            
            # 应用动作平滑
            smoothed_action = self._apply_action_smoothing(raw_action_np)
            
            # 更新上一次动作
            self.previous_action = smoothed_action.copy()
            
            return smoothed_action, log_prob.cpu().item(), value.cpu().item()
    
    def _apply_action_smoothing(self, raw_action: np.ndarray) -> np.ndarray:
        """
        应用动作平滑，限制每次动作的变化幅度
        根据阀门开度的极端情况动态调整变化范围
        
        Args:
            raw_action: 原始动作
            
        Returns:
            np.ndarray: 平滑后的动作
        """
        # 计算动作变化
        action_change = raw_action - self.previous_action
        
        # 计算变化幅度
        change_magnitude = np.abs(action_change)
        
        # 对每个阀门应用变化限制
        smoothed_action = self.previous_action.copy()
        
        for i in range(len(action_change)):
            change = action_change[i]
            magnitude = change_magnitude[i]
            current_opening = self.previous_action[i]
            
            # 根据当前阀门开度动态调整变化范围
            min_change, max_change = self._get_dynamic_action_range(current_opening)
            
            # 如果变化太小，强制最小变化（保持探索性）
            if magnitude < min_change and magnitude > 0:
                # 保持变化方向，但调整到最小变化量
                direction = np.sign(change)
                limited_change = direction * min_change
            # 如果变化太大，限制到最大变化量
            elif magnitude > max_change:
                # 保持变化方向，但限制到最大变化量
                direction = np.sign(change)
                limited_change = direction * max_change
            else:
                # 变化在合理范围内，保持原变化
                limited_change = change
            
            # 应用变化并确保在[0.5, 1.0]范围内（50%-100%开度）
            new_value = self.previous_action[i] + limited_change
            smoothed_action[i] = np.clip(new_value, 0.5, 1.0)
        
        return smoothed_action
    
    def _get_dynamic_action_range(self, current_opening: float) -> Tuple[float, float]:
        """
        根据当前阀门开度获取动态的动作变化范围（适配50-100%开度范围）
        
        Args:
            current_opening: 当前阀门开度 [0.5, 1.0]（50%-100%开度）
            
        Returns:
            Tuple[float, float]: (最小变化量, 最大变化量)
        """
        # 定义开度阈值（基于50-100%范围）
        low_threshold = 0.6   # 低开度阈值（60%）
        high_threshold = 0.85  # 高开度阈值（85%）
        
        # 基础变化范围
        base_min = self.min_action_change  # 0.05
        base_max = self.max_action_change  # 0.2
        
        # 低开度的扩大变化范围（50-60%）
        low_min = 0.1   # 低开度最小变化量
        low_max = 0.25  # 低开度最大变化量
        
        # 极高开度的微调范围（85-100%）
        high_min = 0.02     # 极高开度最小变化量
        high_max = 0.08     # 极高开度最大变化量
        
        if current_opening <= low_threshold:
            # 低开度（50-60%）：给予较大的调整空间，鼓励向上调整
            return low_min, low_max
        elif current_opening >= high_threshold:
            # 极高开度（85-100%）：使用更小的微调范围，精确控制
            return high_min, high_max
        else:
            # 正常开度（60-85%）：使用基础变化范围
            return base_min, base_max
    
    def store_transition(self, state: np.ndarray, action: np.ndarray, reward: float, 
                        value: float, log_prob: float, done: bool):
        """
        存储转换
        
        Args:
            state: 状态
            action: 动作
            reward: 奖励
            value: 状态价值
            log_prob: 动作对数概率
            done: 是否结束
        """
        self.states.append(state)
        self.actions.append(action)
        self.rewards.append(reward)
        self.values.append(value)
        self.log_probs.append(log_prob)
        self.dones.append(done)
    
    def compute_gae(self, next_value: float = 0.0) -> Tuple[List[float], List[float]]:
        """
        计算GAE（广义优势估计）
        
        Args:
            next_value: 下一个状态的价值
            
        Returns:
            Tuple[List[float], List[float]]: (优势, 回报)
        """
        advantages = []
        returns = []
        
        gae = 0
        for i in reversed(range(len(self.rewards))):
            if i == len(self.rewards) - 1:
                next_non_terminal = 1.0 - self.dones[i]
                next_value_i = next_value
            else:
                next_non_terminal = 1.0 - self.dones[i]
                next_value_i = self.values[i + 1]
            
            delta = self.rewards[i] + self.gamma * next_value_i * next_non_terminal - self.values[i]
            gae = delta + self.gamma * self.gae_lambda * next_non_terminal * gae
            
            advantages.insert(0, gae)
            returns.insert(0, gae + self.values[i])
        
        return advantages, returns
    
    def update_policy(self) -> Dict[str, float]:
        """
        更新策略
        
        Returns:
            Dict[str, float]: 训练统计信息
        """
        if len(self.states) < self.batch_size:
            return {}
        
        # 计算优势和回报
        advantages, returns = self.compute_gae()
        
        # 转换为张量
        states = torch.FloatTensor(np.array(self.states)).to(self.device)
        actions = torch.FloatTensor(np.array(self.actions)).to(self.device)
        old_log_probs = torch.FloatTensor(self.log_probs).to(self.device)
        advantages = torch.FloatTensor(advantages).to(self.device)
        returns = torch.FloatTensor(returns).to(self.device)
        
        # 标准化优势
        advantages = (advantages - advantages.mean()) / (advantages.std() + 1e-8)
        
        # 训练统计
        total_policy_loss = 0
        total_value_loss = 0
        total_entropy_loss = 0
        
        # 多轮更新
        for _ in range(self.update_epochs):
            # 随机打乱数据
            indices = torch.randperm(len(states))
            
            for start in range(0, len(states), self.batch_size):
                end = start + self.batch_size
                batch_indices = indices[start:end]
                
                batch_states = states[batch_indices]
                batch_actions = actions[batch_indices]
                batch_old_log_probs = old_log_probs[batch_indices]
                batch_advantages = advantages[batch_indices]
                batch_returns = returns[batch_indices]
                
                # 计算新的策略输出
                log_probs, values, entropy = self.actor_critic.evaluate_action(batch_states, batch_actions)
                
                # 计算比率
                ratio = torch.exp(log_probs - batch_old_log_probs)
                
                # 计算策略损失（PPO）
                surr1 = ratio * batch_advantages
                surr2 = torch.clamp(ratio, 1.0 - self.clip_epsilon, 1.0 + self.clip_epsilon) * batch_advantages
                policy_loss = -torch.min(surr1, surr2).mean()
                
                # 计算价值损失
                value_loss = nn.MSELoss()(values, batch_returns)
                
                # 计算熵损失
                entropy_loss = -entropy.mean()
                
                # 总损失
                total_loss = policy_loss + self.value_coef * value_loss + self.entropy_coef * entropy_loss
                
                # 反向传播
                self.optimizer.zero_grad()
                total_loss.backward()
                torch.nn.utils.clip_grad_norm_(self.actor_critic.parameters(), self.max_grad_norm)
                self.optimizer.step()
                
                # 累计损失
                total_policy_loss += policy_loss.item()
                total_value_loss += value_loss.item()
                total_entropy_loss += entropy_loss.item()
        
        # 清空缓冲区
        self.clear_buffer()
        
        # 计算平均损失
        num_updates = self.update_epochs * (len(states) // self.batch_size)
        avg_policy_loss = total_policy_loss / max(num_updates, 1)
        avg_value_loss = total_value_loss / max(num_updates, 1)
        avg_entropy_loss = total_entropy_loss / max(num_updates, 1)
        
        # 记录到TensorBoard
        self.global_step += 1
        self.writer.add_scalar('Loss/Policy', avg_policy_loss, self.global_step)
        self.writer.add_scalar('Loss/Value', avg_value_loss, self.global_step)
        self.writer.add_scalar('Loss/Entropy', avg_entropy_loss, self.global_step)
        
        # 返回统计信息
        return {
            'policy_loss': avg_policy_loss,
            'value_loss': avg_value_loss,
            'entropy_loss': avg_entropy_loss
        }
    
    def clear_buffer(self):
        """
        清空经验缓冲区
        """
        self.states.clear()
        self.actions.clear()
        self.rewards.clear()
        self.values.clear()
        self.log_probs.clear()
        self.dones.clear()
    
    def reset_episode(self):
        """
        重置episode相关状态
        """
        self.previous_action = None
        self.logger.info("Episode状态已重置，动作平滑机制重新开始")
    
    def log_episode_stats(self, episode_reward: float, episode_length: int):
        """
        记录episode统计信息到TensorBoard
        
        Args:
            episode_reward: episode奖励
            episode_length: episode长度
        """
        self.episode_count += 1
        
        # 记录episode统计
        self.writer.add_scalar('Episode/Reward', episode_reward, self.episode_count)
        self.writer.add_scalar('Episode/Length', episode_length, self.episode_count)
        
        # 记录平均奖励（最近10个episode）
        if len(self.episode_rewards) >= 10:
            recent_avg_reward = np.mean(self.episode_rewards[-10:])
            self.writer.add_scalar('Episode/Recent_Avg_Reward', recent_avg_reward, self.episode_count)
        
        # 记录最佳奖励
        if self.episode_rewards:
            best_reward = max(self.episode_rewards)
            self.writer.add_scalar('Episode/Best_Reward', best_reward, self.episode_count)
    
    def save_model(self, episode: int):
        """
        保存模型
        
        Args:
            episode: 当前episode数
        """
        try:
            # 确保models目录存在
            models_dir = os.path.join(self.save_dir, 'models')
            os.makedirs(models_dir, exist_ok=True)
            
            model_path = os.path.join(models_dir, f'model_episode_{episode}.pth')
            
            # 保存模型状态
            checkpoint = {
                'episode': episode,
                'model_state_dict': self.actor_critic.state_dict(),
                'optimizer_state_dict': self.optimizer.state_dict(),
                'config': self.config,
                'episode_rewards': self.episode_rewards,
                'episode_lengths': self.episode_lengths,
                'global_step': self.global_step,
                'timestamp': datetime.now().isoformat()
            }
            
            torch.save(checkpoint, model_path)
            
            self.logger.info(f"模型已保存: {model_path}")
            
        except Exception as e:
            self.logger.error(f"保存模型失败: {e}")
            import traceback
            self.logger.error(f"保存模型错误详情: {traceback.format_exc()}")
    
    def load_model(self, model_path: str):
        """
        加载模型
        
        Args:
            model_path: 模型路径
        """
        try:
            checkpoint = torch.load(model_path, map_location=self.device)
            self.actor_critic.load_state_dict(checkpoint['model_state_dict'])
            self.optimizer.load_state_dict(checkpoint['optimizer_state_dict'])
            
            self.logger.info(f"模型已加载: {model_path}")
            return checkpoint.get('episode', 0)
            
        except Exception as e:
            self.logger.error(f"加载模型失败: {e}")
            return 0
    
    def save_training_stats(self, episode: int):
        """
        保存训练统计信息
        
        Args:
            episode: 当前episode数
        """
        try:
            stats = {
                'episode': episode,
                'episode_rewards': self.episode_rewards,
                'episode_lengths': self.episode_lengths,
                'training_stats': self.training_stats,
                'timestamp': datetime.now().isoformat()
            }
            
            stats_path = os.path.join(self.save_dir, 'stats', f'training_stats_{episode}.json')
            with open(stats_path, 'w', encoding='utf-8') as f:
                json.dump(stats, f, indent=2, ensure_ascii=False)
            
            self.logger.info(f"训练统计已保存: {stats_path}")
            
        except Exception as e:
            self.logger.error(f"保存训练统计失败: {e}")
    
    def close_tensorboard(self):
        """
        关闭TensorBoard writer
        """
        if hasattr(self, 'writer') and self.writer is not None:
            self.writer.close()
            self.logger.info("TensorBoard writer已关闭")
    
    def get_training_summary(self) -> Dict[str, Any]:
        """
        获取训练摘要
        
        Returns:
            Dict[str, Any]: 训练摘要
        """
        if not self.episode_rewards:
            return {}
        
        recent_rewards = self.episode_rewards[-10:] if len(self.episode_rewards) >= 10 else self.episode_rewards
        
        return {
            'total_episodes': len(self.episode_rewards),
            'average_reward': np.mean(self.episode_rewards),
            'recent_average_reward': np.mean(recent_rewards),
            'best_reward': max(self.episode_rewards),
            'average_episode_length': np.mean(self.episode_lengths) if self.episode_lengths else 0,
            'total_training_updates': len(self.training_stats),
            'global_step': self.global_step,
            'episode_count': self.episode_count
        }


if __name__ == "__main__":
    # 测试训练器
    logging.basicConfig(level=logging.INFO)
    
    config = {
        'state_dim': 104,
        'action_dim': 26,
        'hidden_dim': 128,
        'learning_rate': 3e-4,
        'batch_size': 64,
        'save_dir': 'test_training_results'
    }
    
    trainer = TrainerEfficient(config)
    
    # 模拟一些训练数据
    for i in range(100):
        state = np.random.randn(104)
        action, log_prob, value = trainer.select_action(state)
        reward = np.random.randn()
        done = i % 20 == 19
        
        trainer.store_transition(state, action, reward, value, log_prob, done)
        
        if done:
            trainer.episode_rewards.append(sum(trainer.rewards[-20:]))
            trainer.episode_lengths.append(20)
            
        if len(trainer.states) >= trainer.batch_size:
            stats = trainer.update_policy()
            if stats:
                trainer.training_stats.append(stats)
                print(f"更新 {len(trainer.training_stats)}: {stats}")
    
    # 显示训练摘要
    summary = trainer.get_training_summary()
    print(f"训练摘要: {summary}")