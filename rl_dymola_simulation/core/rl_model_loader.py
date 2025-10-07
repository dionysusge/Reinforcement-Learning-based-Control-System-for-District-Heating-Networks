#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
RL模型加载器
作者: Dionysus

负责加载和管理IQL强化学习模型
"""

import os
import sys
import torch
import numpy as np
from typing import Dict, Any, Tuple, Optional
import logging

# 添加reinforcement_learning目录到路径
current_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(os.path.dirname(current_dir))
rl_dir = os.path.join(project_root, 'reinforcement_learning')
sys.path.insert(0, rl_dir)

try:
    from agents.iql_agent import IQLAgent
except ImportError as e:
    print(f"警告: 无法导入IQL智能体: {e}")
    IQLAgent = None


class RLModelLoader:
    """
    强化学习模型加载器
    
    专门用于加载和管理IQL模型
    """
    
    def __init__(self, config: Dict[str, Any]):
        """
        初始化模型加载器
        
        Args:
            config: 配置字典，包含完整的IQL配置结构
        """
        self.logger = logging.getLogger(__name__)
        self.config = config
        
        # 设备配置
        self.device = config.get('device', 'cuda' if torch.cuda.is_available() else 'cpu')
        
        # 初始化模型
        self.model = None
        self._initialize_model()
    
    def _initialize_model(self):
        """
        初始化IQL模型
        """
        try:
            if IQLAgent is None:
                raise ImportError("IQLAgent未能正确导入")
            
            # 使用完整的配置初始化IQL智能体
            self.model = IQLAgent(self.config)
            self.logger.info("成功初始化IQL模型")
            
        except Exception as e:
            self.logger.error(f"IQL模型初始化失败: {e}")
            raise
    
    def load_model(self, model_path: str) -> bool:
        """
        加载预训练模型
        
        Args:
            model_path: 模型文件路径
            
        Returns:
            bool: 是否加载成功
        """
        try:
            if not os.path.exists(model_path):
                self.logger.warning(f"模型文件不存在: {model_path}")
                return False
            
            self.model.load_model(model_path)
            self.logger.info(f"成功加载模型: {model_path}")
            return True
            
        except Exception as e:
            self.logger.error(f"模型加载失败: {e}")
            return False
    
    def get_action(self, state: np.ndarray, deterministic: bool = True) -> Tuple[np.ndarray, Optional[float], Optional[float]]:
        """
        获取动作
        
        Args:
            state: 状态数组
            deterministic: 是否使用确定性策略
            
        Returns:
            Tuple[np.ndarray, Optional[float], Optional[float]]: (动作, 匹配奖励, 匹配距离)
        """
        try:
            # 使用IQL智能体的get_action方法
            action, matched_reward, matched_distance = self.model.get_action(
                state, 
                deterministic=deterministic,
                verbose=False
            )
            
            # 确保动作在正确范围内 [0.5, 1.0]
            action = np.clip(action, 0.5, 1.0)
            
            return action, matched_reward, matched_distance
            
        except Exception as e:
            self.logger.error(f"动作获取失败: {e}")
            # 返回默认动作
            default_action = np.full(self.config['env_config']['action_dim'], 0.7)
            return default_action, None, None
    
    def predict_action(self, state: np.ndarray) -> Tuple[np.ndarray, Dict[str, Any]]:
        """
        预测动作（兼容性方法）
        
        Args:
            state: 状态数组
            
        Returns:
            Tuple[np.ndarray, Dict[str, Any]]: (动作, 额外信息)
        """
        action, matched_reward, matched_distance = self.get_action(state, deterministic=True)
        
        info = {
            'matched_reward': matched_reward,
            'matched_distance': matched_distance,
            'state_shape': state.shape,
            'action_shape': action.shape,
            'device': str(self.device),
            'model_type': 'iql_agent'
        }
        
        return action, info
    
    def predict(self, state: np.ndarray) -> np.ndarray:
        """
        简单预测方法（兼容性方法）
        
        Args:
            state: 状态数组
            
        Returns:
            np.ndarray: 动作数组
        """
        action, _, _ = self.get_action(state, deterministic=True)
        return action
    
    def set_offline_data(self, states: np.ndarray, actions: np.ndarray, rewards: np.ndarray, next_states: Optional[np.ndarray] = None):
        """
        设置离线数据用于相似度匹配
        
        Args:
            states: 状态数据
            actions: 动作数据
            rewards: 奖励数据
            next_states: 下一状态数据（可选）
        """
        try:
            self.model.set_offline_data(states, actions, rewards, next_states)
            self.logger.info(f"成功设置离线数据: {len(states)} 条记录")
        except Exception as e:
            self.logger.error(f"设置离线数据失败: {e}")
    
    def is_model_loaded(self) -> bool:
        """
        检查模型是否已加载
        
        Returns:
            bool: 模型是否已加载
        """
        return self.model is not None
    
    def validate_state_dimension(self, state: np.ndarray) -> bool:
        """
        验证状态维度是否正确
        
        Args:
            state: 输入状态
            
        Returns:
            bool: 维度是否正确
        """
        expected_dim = self.config['env_config']['state_dim']
        actual_dim = state.shape[-1] if len(state.shape) > 1 else len(state)
        
        if actual_dim != expected_dim:
            self.logger.error(f"状态维度不匹配: 期望{expected_dim}, 实际{actual_dim}")
            return False
        
        return True
    
    def get_model_info(self) -> Dict[str, Any]:
        """
        获取模型信息
        
        Returns:
            Dict[str, Any]: 模型信息字典
        """
        env_config = self.config.get('env_config', {})
        simulation_config = self.config.get('simulation_config', {})
        
        return {
            'model_type': 'IQL',
            'state_dim': env_config.get('state_dim', 92),
            'action_dim': env_config.get('action_dim', 23),
            'device': self.device,
            'action_bound': env_config.get('action_bound', 1.0),
            'action_range': [simulation_config.get('action_low', 0.5), simulation_config.get('action_high', 1.0)],
            'is_loaded': self.is_model_loaded(),
            'use_similarity_matching': self.config.get('use_similarity_matching', False)
        }