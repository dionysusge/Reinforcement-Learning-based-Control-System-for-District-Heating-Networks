#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
IQL智能体决策控制器

作者: Dionysus
功能: 基于IQL强化学习智能体进行阀门开度决策控制
"""

import numpy as np
import torch
import logging
from pathlib import Path
from typing import List, Dict, Optional, Tuple, Any
import json
import time

from .rl_model_loader import RLModelLoader
from .mo_file_handler import MoFileHandler


class IQLDecisionController:
    """
    IQL智能体决策控制器
    
    负责使用训练好的IQL模型进行阀门开度决策
    """
    
    def __init__(self, 
                 model_path: str,
                 mo_file_path: str,
                 config_path: Optional[str] = None,
                 device: str = 'auto'):
        """
        初始化IQL决策控制器
        
        Args:
            model_path: IQL模型文件路径
            mo_file_path: Dymola .mo文件路径
            config_path: 配置文件路径
            device: 计算设备 ('cpu', 'cuda', 'auto')
        """
        self.logger = logging.getLogger(self.__class__.__name__)
        
        # 设备配置
        if device == 'auto':
            self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        else:
            self.device = device
        
        self.logger.info(f"使用设备: {self.device}")
        
        # 加载配置
        self.config = self._load_config(config_path)
        
        # 初始化模型加载器
        self.model_loader = RLModelLoader(
            state_dim=self.config.get('state_dim', 20),
            action_dim=self.config.get('action_dim', 10),
            device=self.device,
            model_type='iql'  # 指定使用IQL模型
        )
        
        # 加载模型
        model_path = Path(model_path)
        if not self.model_loader.load_model(model_path):
            raise RuntimeError(f"无法加载IQL模型: {model_path}")
        
        self.logger.info(f"成功加载IQL模型: {model_path}")
        
        # 初始化mo文件处理器
        self.mo_handler = MoFileHandler(
            mo_file_path=mo_file_path,
            backup_enabled=self.config.get('backup_enabled', True)
        )
        
        # 决策历史记录
        self.decision_history = []
        self.max_history_length = self.config.get('max_history_length', 1000)
        
        # 状态标准化参数
        self.state_mean = None
        self.state_std = None
        self._load_normalization_params()
        
        # 动作后处理参数
        self.action_clip_range = self.config.get('action_clip_range', [0.0, 1.0])
        self.action_smoothing = self.config.get('action_smoothing', False)
        self.smoothing_factor = self.config.get('smoothing_factor', 0.1)
        
        self.logger.info("IQL决策控制器初始化完成")
    
    def make_decision(self, 
                     state: List[float], 
                     deterministic: bool = True,
                     apply_to_mo: bool = True) -> Tuple[List[float], Dict[str, Any]]:
        """
        基于当前状态做出阀门开度决策
        
        Args:
            state: 当前环境状态
            deterministic: 是否使用确定性策略
            apply_to_mo: 是否直接应用到mo文件
            
        Returns:
            Tuple[List[float], Dict[str, Any]]: (阀门开度列表, 决策信息)
        """
        try:
            start_time = time.time()
            
            # 状态预处理
            processed_state = self._preprocess_state(state)
            
            # 使用IQL模型进行预测
            action, prediction_info = self.model_loader.predict(
                processed_state, 
                deterministic=deterministic
            )
            
            # 动作后处理
            valve_openings = self._postprocess_action(action)
            
            # 构建决策信息
            decision_info = {
                'timestamp': time.time(),
                'input_state': state.copy(),
                'processed_state': processed_state.tolist() if isinstance(processed_state, np.ndarray) else processed_state,
                'raw_action': action.copy() if isinstance(action, list) else action.tolist(),
                'valve_openings': valve_openings.copy(),
                'deterministic': deterministic,
                'prediction_time': time.time() - start_time,
                'prediction_info': prediction_info
            }
            
            # 应用到mo文件
            if apply_to_mo:
                apply_success = self.mo_handler.modify_valve_opening_list(valve_openings)
                decision_info['mo_apply_success'] = apply_success
                
                if apply_success:
                    self.logger.info(f"成功应用阀门开度到mo文件: {len(valve_openings)} 个阀门")
                else:
                    self.logger.error("应用阀门开度到mo文件失败")
            
            # 记录决策历史
            self._record_decision(decision_info)
            
            self.logger.debug(f"决策完成，耗时: {decision_info['prediction_time']:.4f}s")
            
            return valve_openings, decision_info
            
        except Exception as e:
            self.logger.error(f"决策失败: {e}")
            import traceback
            self.logger.error(f"详细错误: {traceback.format_exc()}")
            
            # 返回安全的默认开度
            default_openings = self._get_safe_default_openings()
            error_info = {
                'timestamp': time.time(),
                'error': str(e),
                'default_openings': default_openings
            }
            
            return default_openings, error_info
    
    def get_current_valve_openings(self) -> List[float]:
        """
        获取当前mo文件中的阀门开度
        
        Returns:
            List[float]: 当前阀门开度列表
        """
        return self.mo_handler.get_valve_opening_list()
    
    def validate_state(self, state: List[float]) -> Tuple[bool, List[str]]:
        """
        验证输入状态的有效性
        
        Args:
            state: 输入状态
            
        Returns:
            Tuple[bool, List[str]]: (是否有效, 错误信息列表)
        """
        errors = []
        
        # 检查状态维度
        expected_dim = self.config.get('state_dim', 20)
        if len(state) != expected_dim:
            errors.append(f"状态维度错误: 期望 {expected_dim}, 实际 {len(state)}")
        
        # 检查状态值类型和范围
        for i, value in enumerate(state):
            if not isinstance(value, (int, float)):
                errors.append(f"状态值 {i} 类型错误: {type(value)}")
            elif np.isnan(value) or np.isinf(value):
                errors.append(f"状态值 {i} 包含无效数值: {value}")
        
        return len(errors) == 0, errors
    
    def get_decision_statistics(self) -> Dict[str, Any]:
        """
        获取决策统计信息
        
        Returns:
            Dict[str, Any]: 统计信息
        """
        if not self.decision_history:
            return {'total_decisions': 0}
        
        # 计算统计信息
        prediction_times = [d.get('prediction_time', 0) for d in self.decision_history]
        successful_applications = sum(1 for d in self.decision_history 
                                    if d.get('mo_apply_success', False))
        
        recent_decisions = self.decision_history[-10:] if len(self.decision_history) >= 10 else self.decision_history
        
        stats = {
            'total_decisions': len(self.decision_history),
            'successful_applications': successful_applications,
            'success_rate': successful_applications / len(self.decision_history),
            'avg_prediction_time': np.mean(prediction_times),
            'max_prediction_time': np.max(prediction_times),
            'min_prediction_time': np.min(prediction_times),
            'recent_decisions_count': len(recent_decisions)
        }
        
        return stats
    
    def reset_decision_history(self) -> None:
        """
        重置决策历史记录
        """
        self.decision_history.clear()
        self.logger.info("决策历史记录已重置")
    
    def save_decision_history(self, save_path: str) -> bool:
        """
        保存决策历史到文件
        
        Args:
            save_path: 保存路径
            
        Returns:
            bool: 是否保存成功
        """
        try:
            with open(save_path, 'w', encoding='utf-8') as f:
                json.dump(self.decision_history, f, indent=2, ensure_ascii=False)
            
            self.logger.info(f"决策历史已保存到: {save_path}")
            return True
            
        except Exception as e:
            self.logger.error(f"保存决策历史失败: {e}")
            return False
    
    def _load_config(self, config_path: Optional[str]) -> Dict[str, Any]:
        """
        加载配置文件
        
        Args:
            config_path: 配置文件路径
            
        Returns:
            Dict[str, Any]: 配置字典
        """
        default_config = {
            'state_dim': 20,
            'action_dim': 10,
            'backup_enabled': True,
            'max_history_length': 1000,
            'action_clip_range': [0.0, 1.0],
            'action_smoothing': False,
            'smoothing_factor': 0.1
        }
        
        if config_path is None:
            self.logger.info("使用默认配置")
            return default_config
        
        try:
            config_path = Path(config_path)
            if not config_path.exists():
                self.logger.warning(f"配置文件不存在: {config_path}，使用默认配置")
                return default_config
            
            with open(config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
            
            # 合并默认配置
            for key, value in default_config.items():
                if key not in config:
                    config[key] = value
            
            self.logger.info(f"成功加载配置文件: {config_path}")
            return config
            
        except Exception as e:
            self.logger.error(f"加载配置文件失败: {e}，使用默认配置")
            return default_config
    
    def _load_normalization_params(self) -> None:
        """
        加载状态标准化参数
        """
        try:
            # 尝试从模型加载器获取标准化参数
            if hasattr(self.model_loader, 'state_mean') and self.model_loader.state_mean is not None:
                self.state_mean = self.model_loader.state_mean
                self.state_std = self.model_loader.state_std
                self.logger.info("从模型加载器获取状态标准化参数")
            else:
                self.logger.info("未找到状态标准化参数，将使用原始状态")
                
        except Exception as e:
            self.logger.warning(f"加载状态标准化参数失败: {e}")
    
    def _preprocess_state(self, state: List[float]) -> np.ndarray:
        """
        预处理输入状态
        
        Args:
            state: 原始状态
            
        Returns:
            np.ndarray: 预处理后的状态
        """
        state_array = np.array(state, dtype=np.float32)
        
        # 应用标准化
        if self.state_mean is not None and self.state_std is not None:
            state_array = (state_array - self.state_mean) / (self.state_std + 1e-8)
        
        return state_array
    
    def _postprocess_action(self, action: List[float]) -> List[float]:
        """
        后处理动作输出
        
        Args:
            action: 原始动作
            
        Returns:
            List[float]: 后处理后的阀门开度
        """
        action_array = np.array(action, dtype=np.float32)
        
        # 限制动作范围
        min_val, max_val = self.action_clip_range
        action_array = np.clip(action_array, min_val, max_val)
        
        # 动作平滑
        if self.action_smoothing and len(self.decision_history) > 0:
            last_decision = self.decision_history[-1]
            if 'valve_openings' in last_decision:
                last_openings = np.array(last_decision['valve_openings'])
                action_array = (1 - self.smoothing_factor) * last_openings + \
                              self.smoothing_factor * action_array
        
        return action_array.tolist()
    
    def _get_safe_default_openings(self) -> List[float]:
        """
        获取安全的默认阀门开度
        
        Returns:
            List[float]: 默认阀门开度列表
        """
        try:
            # 尝试获取当前开度
            current_openings = self.mo_handler.get_valve_opening_list()
            if current_openings:
                return current_openings
        except:
            pass
        
        # 返回中等开度作为安全默认值
        valve_count = self.config.get('action_dim', 10)
        return [0.5] * valve_count
    
    def _record_decision(self, decision_info: Dict[str, Any]) -> None:
        """
        记录决策信息
        
        Args:
            decision_info: 决策信息
        """
        self.decision_history.append(decision_info)
        
        # 限制历史记录长度
        if len(self.decision_history) > self.max_history_length:
            self.decision_history = self.decision_history[-self.max_history_length:]