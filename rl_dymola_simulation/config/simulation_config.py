#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
强化学习-Dymola闭环仿真配置文件

作者: Dionysus
"""

import os
from pathlib import Path

class SimulationConfig:
    """
    闭环仿真系统配置类
    
    定义强化学习模型与Dymola仿真的集成参数
    """
    
    def __init__(self):
        # 基础路径配置
        self.base_dir = Path(__file__).parent.parent
        self.project_root = self.base_dir.parent
        
        # 强化学习模型配置
        self.rl_config = {
            'model_path': self.project_root / 'reinforcement_learning' / 'models',
            'latest_model': 'model_episode_500.pth',  # 使用最新训练的模型
            'state_dim': 92,  # 23个楼栋 * 4个变量 (流量、压力、供水温度、回水温度)
            'action_dim': 23,  # 23个阀门开度调整
            'action_bound': 1.0,
            'action_low': 0.5,  # 最小阀门开度50%
            'action_high': 1.0,  # 最大阀门开度100%
            'hidden_dim': 128  # 神经网络隐藏层维度
        }
        
        # Dymola仿真配置
        self.dymola_config = {
            'model_file': self.project_root / 'models' / 'HeatingNetwork_20250316.mo',
            'executable': self.project_root / 'dymosim.exe',
            'simulation_time': 3600,  # 仿真时间（秒）
            'time_step': 60,  # 时间步长（秒）
            'output_interval': 60,  # 输出间隔（秒）
            'tolerance': 1e-6,
            'dymola_visible': False  # Dymola界面是否可见
        }
        
        # 控制循环配置
        self.control_config = {
            'max_iterations': 50,  # 最大控制循环次数
            'convergence_threshold': 0.5,  # 收敛阈值（温度误差）
            'valve_adjustment_limit': 0.1,  # 单次阀门调整限制
            'target_return_temp': 45.0,  # 目标回水温度
            'temp_tolerance': 2.0,  # 温度容差
            'min_valve_opening': 0.5,  # 最小阀门开度
            'max_valve_opening': 1.0   # 最大阀门开度
        }
        
        # 数据记录配置
        self.logging_config = {
            'log_level': 'INFO',
            'log_dir': self.base_dir / 'logs',
            'results_dir': self.base_dir / 'results',
            'analysis_dir': self.base_dir / 'analysis',
            'save_intermediate': True,  # 是否保存中间结果
            'save_frequency': 10  # 中间结果保存频率
        }
        
        # 楼栋配置
        self.building_config = {
            'total_buildings': 27,
            'excluded_buildings': [8, 14, 15, 16],  # 跳过的楼栋编号
            'active_buildings': [i for i in range(1, 28) if i not in [8, 14, 15, 16]],
            'num_active_buildings': 23
        }
        
        # 创建必要的目录
        self._create_directories()
    
    def _create_directories(self):
        """
        创建必要的目录
        """
        for config_group in [self.logging_config]:
            for key, path in config_group.items():
                if key.endswith('_dir') and isinstance(path, Path):
                    path.mkdir(parents=True, exist_ok=True)
    
    def validate_config(self) -> bool:
        """
        验证配置的有效性
        
        Returns:
            bool: 配置是否有效
        """
        # 检查模型文件是否存在
        model_path = self.rl_config['model_path'] / self.rl_config['latest_model']
        if not model_path.exists():
            print(f"警告: 强化学习模型文件不存在: {model_path}")
            return False
        
        # 检查Dymola模型文件是否存在
        if not self.dymola_config['model_file'].exists():
            print(f"警告: Dymola模型文件不存在: {self.dymola_config['model_file']}")
            return False
        
        # 检查Dymola可执行文件是否存在
        if not self.dymola_config['executable'].exists():
            print(f"警告: Dymola可执行文件不存在: {self.dymola_config['executable']}")
            return False
        
        return True
    
    def get_model_path(self) -> Path:
        """
        获取强化学习模型完整路径
        
        Returns:
            Path: 模型文件路径
        """
        return self.rl_config['model_path'] / self.rl_config['latest_model']
    
    def update_model_name(self, model_name: str):
        """
        更新要使用的模型文件名
        
        Args:
            model_name: 模型文件名
        """
        self.rl_config['latest_model'] = model_name
    
    def get_active_valve_numbers(self) -> list:
        """
        获取活跃的阀门编号列表
        
        Returns:
            list: 活跃阀门编号列表
        """
        return self.building_config['active_buildings']
    
    def __str__(self) -> str:
        """
        配置信息字符串表示
        
        Returns:
            str: 配置信息
        """
        return f"""仿真配置:
- 强化学习模型: {self.get_model_path()}
- Dymola模型: {self.dymola_config['model_file']}
- 目标回水温度: {self.control_config['target_return_temp']}°C
- 最大迭代次数: {self.control_config['max_iterations']}
- 活跃楼栋数量: {self.building_config['num_active_buildings']}"""