#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
高效强化学习主程序
作者: Dionysus
日期: 2025-08-08

整合高效环境和训练器，实现优化的训练流程
"""

import os
import json
import argparse
import logging
from datetime import datetime
from typing import Dict, Any

import numpy as np

from heating_environment_efficient import HeatingEnvironmentEfficient
from trainer_efficient import TrainerEfficient


def setup_logging(log_level: str = 'INFO') -> logging.Logger:
    """
    设置日志
    
    Args:
        log_level: 日志级别
        
    Returns:
        logging.Logger: 日志器
    """
    # 确保日志目录存在
    log_dir = 'simulation_results/log_files'
    os.makedirs(log_dir, exist_ok=True)
    
    logging.basicConfig(
        level=getattr(logging, log_level.upper()),
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(f'{log_dir}/training_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log')
        ]
    )
    return logging.getLogger(__name__)


def load_or_create_config(config_path: str) -> Dict[str, Any]:
    """
    加载或创建配置文件
    
    Args:
        config_path: 配置文件路径
        
    Returns:
        Dict[str, Any]: 配置字典
    """
    if os.path.exists(config_path):
        with open(config_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    else:
        # 默认配置
        config = {
            # 环境配置
            'num_buildings': 23,  # 跳过8、14、15、16号楼栋
            'max_steps': 50,  # 减少步数以提高效率
            'simulation_time': 3600,
            'target_return_temp': 30.0,
            'dymola_visible': False,
            
            # 训练配置
            'state_dim': 92,  # 23 * 4
            'action_dim': 23,
            'hidden_dim': 128,
            'learning_rate': 3e-4,
            'gamma': 0.99,
            'gae_lambda': 0.95,
            'clip_epsilon': 0.2,
            'entropy_coef': 0.01,
            'value_coef': 0.5,
            'max_grad_norm': 0.5,
            'batch_size': 32,  # 减小批次大小
            'update_epochs': 4,
            'update_frequency': 5,  # 更频繁的更新
            
            # 训练设置
            'total_episodes': 1000,
            'save_frequency': 50,  # 每50个episode保存一次
            'eval_frequency': 20,  # 每20个episode评估一次
            'save_dir': 'efficient_training_results'
        }
        
        # 保存默认配置
        with open(config_path, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2, ensure_ascii=False)
        
        return config


def train_agent(config: Dict[str, Any], logger: logging.Logger):
    """
    训练智能体
    
    Args:
        config: 配置字典
        logger: 日志器
    """
    logger.info("开始训练智能体")
    
    # 创建环境和训练器
    try:
        logger.info("正在创建环境...")
        env = HeatingEnvironmentEfficient()
        logger.info("环境创建成功")
        
        logger.info("正在创建训练器...")
        # 将环境的instance_id传递给训练器配置
        config['instance_id'] = env.instance_id
        trainer = TrainerEfficient(config)
        logger.info("训练器创建成功")
        
    except Exception as e:
        logger.error(f"环境或训练器创建失败: {e}")
        import traceback
        logger.error(f"错误详情: {traceback.format_exc()}")
        return
    
    try:
        best_reward = float('-inf')
        
        for episode in range(config['total_episodes']):
            logger.info(f"\n{'='*50}")
            logger.info(f"开始Episode {episode + 1}/{config['total_episodes']}")
            logger.info(f"{'='*50}")
            
            try:
                # 重置环境
                logger.info("正在重置环境...")
                state = env.reset()
                logger.info(f"环境重置成功，状态维度: {len(state)}")
                
                episode_reward = 0
                episode_length = 0
                
                while True:
                    try:
                        # 选择动作
                        action, log_prob, value = trainer.select_action(state)
                        logger.debug(f"选择动作: {action[:5]}... (前5个值)")
                        
                        # 执行动作
                        next_state, reward, done, info = env.step(action)
                        logger.debug(f"步骤 {episode_length + 1}: 奖励={reward:.3f}, 完成={done}")
                        
                        # 存储转换
                        trainer.store_transition(state, action, reward, value, log_prob, done)
                        
                        # 更新统计
                        episode_reward += reward
                        episode_length += 1
                        state = next_state
                        
                        # 检查是否需要更新策略
                        if len(trainer.states) >= config['update_frequency']:
                            logger.debug("正在更新策略...")
                            update_stats = trainer.update_policy()
                            if update_stats:
                                trainer.training_stats.append(update_stats)
                                logger.debug(f"✓ 策略更新完成: {update_stats}")
                        
                        if done:
                            logger.info(f"Episode {episode + 1} 自然结束")
                            break
                            
                    except Exception as step_error:
                        logger.error(f"✗ 步骤执行失败: {step_error}")
                        import traceback
                        logger.error(f"步骤错误详情: {traceback.format_exc()}")
                        break
                
                # 记录episode统计
                trainer.episode_rewards.append(episode_reward)
                trainer.episode_lengths.append(episode_length)
                
                # 记录到TensorBoard
                trainer.log_episode_stats(episode_reward, episode_length)
                
                logger.info(f"Episode {episode + 1} 完成: 奖励={episode_reward:.3f}, 长度={episode_length}")
                
                # 更新最佳奖励
                if episode_reward > best_reward:
                    best_reward = episode_reward
                    logger.info(f"新的最佳奖励: {best_reward:.3f}")
                
                # 获取并显示离线数据统计
                try:
                    offline_stats = env.get_offline_data_stats()
                    logger.info(f"离线数据统计: {offline_stats}")
                except Exception as stats_error:
                    logger.warning(f"获取离线数据统计失败: {stats_error}")
                
                # 定期保存模型和统计
                if (episode + 1) % config['save_frequency'] == 0:
                    try:
                        logger.info("正在保存模型和统计...")
                        trainer.save_model(episode + 1)
                        trainer.save_training_stats(episode + 1)
                        logger.info("✓ 模型和统计保存成功")
                        
                        # 显示训练摘要
                        summary = trainer.get_training_summary()
                        logger.info(f"📊 训练摘要 (Episode {episode + 1}): {summary}")
                    except Exception as save_error:
                        logger.error(f"✗ 保存失败: {save_error}")
                
                # 定期评估
                if (episode + 1) % config['eval_frequency'] == 0:
                    try:
                        logger.info("正在进行评估...")
                        eval_reward = evaluate_agent(env, trainer, logger)
                        logger.info(f"📈 评估奖励 (Episode {episode + 1}): {eval_reward:.3f}")
                    except Exception as eval_error:
                        logger.error(f"✗ 评估失败: {eval_error}")
                        
            except Exception as episode_error:
                logger.error(f"✗ Episode {episode + 1} 执行失败: {episode_error}")
                import traceback
                logger.error(f"Episode错误详情: {traceback.format_exc()}")
                continue
        
        # 最终保存
        try:
            logger.info("正在进行最终保存...")
            trainer.save_model(config['total_episodes'])
            trainer.save_training_stats(config['total_episodes'])
            logger.info("✓ 最终保存完成")
            
            # 显示最终统计
            final_summary = trainer.get_training_summary()
            logger.info(f"🏁 训练完成! 最终统计: {final_summary}")
            
            # 显示离线数据统计
            offline_stats = env.get_offline_data_stats()
            logger.info(f"📁 最终离线数据统计: {offline_stats}")
            
        except Exception as final_error:
            logger.error(f"✗ 最终保存失败: {final_error}")
        
    except KeyboardInterrupt:
        logger.info("⚠️ 训练被用户中断")
    except Exception as e:
        logger.error(f"✗ 训练过程中发生严重错误: {e}")
        import traceback
        logger.error(f"训练错误详情: {traceback.format_exc()}")
    finally:
        try:
            # 关闭TensorBoard writer
            trainer.close_tensorboard()
            env.close()
            logger.info("✓ 环境已安全关闭")
        except Exception as close_error:
            logger.error(f"✗ 环境关闭失败: {close_error}")


def evaluate_agent(env: HeatingEnvironmentEfficient, trainer: TrainerEfficient, 
                  logger: logging.Logger, num_episodes: int = 3) -> float:
    """
    评估智能体
    
    Args:
        env: 环境
        trainer: 训练器
        logger: 日志器
        num_episodes: 评估episode数
        
    Returns:
        float: 平均奖励
    """
    total_reward = 0
    
    for i in range(num_episodes):
        state = env.reset()
        episode_reward = 0
        
        while True:
            # 使用确定性策略（不添加噪声）
            action, _, _ = trainer.select_action(state)
            state, reward, done, _ = env.step(action)
            episode_reward += reward
            
            if done:
                break
        
        total_reward += episode_reward
        logger.debug(f"评估Episode {i + 1}: 奖励={episode_reward:.3f}")
    
    return total_reward / num_episodes


def test_environment(config: Dict[str, Any], logger: logging.Logger):
    """
    测试环境
    
    Args:
        config: 配置字典
        logger: 日志器
    """
    logger.info("开始测试环境")
    
    env = HeatingEnvironmentEfficient()
    
    try:
        # 重置环境
        state = env.reset()
        logger.info(f"环境重置成功，状态维度: {len(state)}")
        
        # 执行几步随机动作
        for step in range(5):
            action = np.random.uniform(0.3, 0.7, config['action_dim'])
            next_state, reward, done, info = env.step(action)
            
            logger.info(f"步骤 {step + 1}: 奖励={reward:.3f}, 完成={done}")
            logger.debug(f"动作: {action[:5]}..., 状态: {next_state[:5]}...")
            
            if done:
                logger.info("Episode结束")
                break
            
            state = next_state
        
        # 显示离线数据统计
        offline_stats = env.get_offline_data_stats()
        logger.info(f"离线数据统计: {offline_stats}")
        
    except Exception as e:
        logger.error(f"环境测试失败: {e}")
    finally:
        env.close()
        logger.info("环境测试完成")


def main():
    """
    主函数
    """
    parser = argparse.ArgumentParser(description='高效强化学习训练程序')
    parser.add_argument('--mode', choices=['train', 'test'], default='train',
                       help='运行模式: train(训练) 或 test(测试)')
    parser.add_argument('--config', default='config_efficient.json',
                       help='配置文件路径')
    parser.add_argument('--log-level', default='INFO',
                       choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
                       help='日志级别')
    
    args = parser.parse_args()
    
    # 设置日志
    logger = setup_logging(args.log_level)
    logger.info(f"程序启动，模式: {args.mode}")
    
    # 加载配置
    config = load_or_create_config(args.config)
    logger.info(f"配置已加载: {args.config}")
    
    try:
        if args.mode == 'train':
            train_agent(config, logger)
        elif args.mode == 'test':
            test_environment(config, logger)
    except Exception as e:
        logger.error(f"程序执行失败: {e}")
        return 1
    
    logger.info("程序执行完成")
    return 0


if __name__ == "__main__":
    exit(main())