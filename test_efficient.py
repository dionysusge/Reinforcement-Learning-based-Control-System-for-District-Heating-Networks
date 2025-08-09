#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
高效版本测试脚本
作者: Dionysus
日期: 2025-08-08

测试高效版本的环境和训练器是否正常工作
"""

import os
import sys
import logging
import traceback
from datetime import datetime

import numpy as np

# 添加当前目录到Python路径
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from heating_environment_efficient import HeatingEnvironmentEfficient
from trainer_efficient import TrainerEfficient


def setup_test_logging():
    """
    设置测试日志
    """
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(f'simulation_results/log_files/test_efficient_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log')
        ]
    )
    return logging.getLogger(__name__)


def test_environment_basic():
    """
    测试环境基本功能
    """
    logger = logging.getLogger(__name__)
    logger.info("=== 测试环境基本功能 ===")
    
    try:
        # 创建环境
        env = HeatingEnvironmentEfficient()
        logger.info("✓ 环境创建成功")
        
        # 测试重置
        state = env.reset()
        logger.info(f"✓ 环境重置成功，状态维度: {len(state)}")
        logger.info(f"  初始状态前8个值: {state[:8]}")
        
        # 检查状态是否有效
        if np.all(state == 0) or np.any(np.isnan(state)) or np.any(np.isinf(state)):
            logger.warning("⚠ 状态可能无效（全零、NaN或无穷大）")
        else:
            logger.info("✓ 状态值看起来正常")
        
        # 测试步进
        action = np.random.uniform(0.3, 0.7, env.num_buildings)
        next_state, reward, done, info = env.step(action)
        
        logger.info(f"✓ 环境步进成功")
        logger.info(f"  动作: {action[:5]}...")
        logger.info(f"  奖励: {reward:.3f}")
        logger.info(f"  完成: {done}")
        logger.info(f"  信息: {info}")
        logger.info(f"  下一状态前8个值: {next_state[:8]}")
        
        # 检查仿真是否真正运行
        if info.get('simulation_success', False):
            logger.info("✓ Dymola仿真成功执行")
        else:
            logger.error("✗ Dymola仿真失败")
            return False
        
        # 测试多步
        logger.info("测试多步执行...")
        for i in range(3):
            action = np.random.uniform(0.3, 0.7, env.num_buildings)
            state, reward, done, info = env.step(action)
            logger.info(f"  步骤 {i+2}: 奖励={reward:.3f}, 完成={done}")
            
            if done:
                logger.info("  Episode提前结束")
                break
        
        # 获取离线数据统计
        stats = env.get_offline_data_stats()
        logger.info(f"✓ 离线数据统计: {stats}")
        
        # 关闭环境
        env.close()
        logger.info("✓ 环境关闭成功")
        
        return True
        
    except Exception as e:
        logger.error(f"✗ 环境测试失败: {e}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return False


def test_trainer_basic():
    """
    测试训练器基本功能
    """
    logger = logging.getLogger(__name__)
    logger.info("=== 测试训练器基本功能 ===")
    
    try:
        # 创建训练器配置
        config = {
            'state_dim': 104,
            'action_dim': 26,
            'hidden_dim': 64,  # 减小网络以加快测试
            'learning_rate': 3e-4,
            'batch_size': 16,  # 减小批次大小
            'save_dir': 'test_training_results'
        }
        
        # 创建训练器
        trainer = TrainerEfficient(config)
        logger.info("✓ 训练器创建成功")
        
        # 测试动作选择
        state = np.random.randn(104)
        action, log_prob, value = trainer.select_action(state)
        
        logger.info(f"✓ 动作选择成功")
        logger.info(f"  动作维度: {len(action)}")
        logger.info(f"  动作范围: [{action.min():.3f}, {action.max():.3f}]")
        logger.info(f"  对数概率: {log_prob:.3f}")
        logger.info(f"  状态价值: {value:.3f}")
        
        # 测试经验存储和策略更新
        logger.info("测试经验存储和策略更新...")
        
        for i in range(20):  # 收集足够的经验
            state = np.random.randn(104)
            action, log_prob, value = trainer.select_action(state)
            reward = np.random.randn()
            done = i == 19
            
            trainer.store_transition(state, action, reward, value, log_prob, done)
        
        logger.info(f"✓ 已存储 {len(trainer.states)} 个转换")
        
        # 更新策略
        update_stats = trainer.update_policy()
        if update_stats:
            logger.info(f"✓ 策略更新成功: {update_stats}")
        else:
            logger.warning("⚠ 策略更新返回空统计")
        
        # 测试模型保存和加载
        trainer.save_model(1)
        logger.info("✓ 模型保存成功")
        
        # 测试训练统计
        trainer.episode_rewards = [1.0, 2.0, 3.0]
        trainer.episode_lengths = [10, 15, 20]
        summary = trainer.get_training_summary()
        logger.info(f"✓ 训练摘要: {summary}")
        
        return True
        
    except Exception as e:
        logger.error(f"✗ 训练器测试失败: {e}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return False


def test_integration():
    """
    测试环境和训练器集成
    """
    logger = logging.getLogger(__name__)
    logger.info("=== 测试环境和训练器集成 ===")
    
    try:
        # 创建环境和训练器
        env = HeatingEnvironmentEfficient()
        
        config = {
            'state_dim': 104,
            'action_dim': 26,
            'hidden_dim': 64,
            'learning_rate': 3e-4,
            'batch_size': 8,
            'update_frequency': 5,
            'save_dir': 'test_integration_results'
        }
        trainer = TrainerEfficient(config)
        
        logger.info("✓ 环境和训练器创建成功")
        
        # 运行一个完整的episode
        state = env.reset()
        episode_reward = 0
        step_count = 0
        
        logger.info("开始集成测试episode...")
        
        while step_count < 10:  # 限制步数以加快测试
            # 选择动作
            action, log_prob, value = trainer.select_action(state)
            
            # 执行动作
            next_state, reward, done, info = env.step(action)
            
            # 存储转换
            trainer.store_transition(state, action, reward, value, log_prob, done)
            
            # 更新统计
            episode_reward += reward
            step_count += 1
            state = next_state
            
            logger.info(f"  步骤 {step_count}: 奖励={reward:.3f}, 累计奖励={episode_reward:.3f}")
            
            # 测试策略更新
            if len(trainer.states) >= config['update_frequency']:
                update_stats = trainer.update_policy()
                if update_stats:
                    logger.info(f"  策略更新: {update_stats}")
            
            if done:
                logger.info("  Episode自然结束")
                break
        
        logger.info(f"✓ 集成测试完成，总奖励: {episode_reward:.3f}")
        
        # 获取统计信息
        trainer.episode_rewards.append(episode_reward)
        trainer.episode_lengths.append(step_count)
        summary = trainer.get_training_summary()
        logger.info(f"✓ 训练摘要: {summary}")
        
        offline_stats = env.get_offline_data_stats()
        logger.info(f"✓ 离线数据统计: {offline_stats}")
        
        # 清理
        env.close()
        logger.info("✓ 集成测试成功")
        
        return True
        
    except Exception as e:
        logger.error(f"✗ 集成测试失败: {e}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return False


def main():
    """
    主测试函数
    """
    logger = setup_test_logging()
    logger.info("开始高效版本测试")
    
    test_results = []
    
    # 运行所有测试
    tests = [
        ("环境基本功能", test_environment_basic),
        ("训练器基本功能", test_trainer_basic),
        ("环境和训练器集成", test_integration)
    ]
    
    for test_name, test_func in tests:
        logger.info(f"\n{'='*50}")
        logger.info(f"开始测试: {test_name}")
        logger.info(f"{'='*50}")
        
        try:
            result = test_func()
            test_results.append((test_name, result))
            
            if result:
                logger.info(f"✓ {test_name} 测试通过")
            else:
                logger.error(f"✗ {test_name} 测试失败")
                
        except Exception as e:
            logger.error(f"✗ {test_name} 测试异常: {e}")
            test_results.append((test_name, False))
    
    # 总结测试结果
    logger.info(f"\n{'='*50}")
    logger.info("测试结果总结")
    logger.info(f"{'='*50}")
    
    passed = 0
    total = len(test_results)
    
    for test_name, result in test_results:
        status = "✓ 通过" if result else "✗ 失败"
        logger.info(f"{test_name}: {status}")
        if result:
            passed += 1
    
    logger.info(f"\n总计: {passed}/{total} 个测试通过")
    
    if passed == total:
        logger.info("🎉 所有测试通过！高效版本工作正常")
        return 0
    else:
        logger.error(f"❌ {total - passed} 个测试失败")
        return 1


if __name__ == "__main__":
    exit(main())