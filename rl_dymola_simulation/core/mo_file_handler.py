#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Dymola .mo文件处理模块

作者: Dionysus
功能: 读取和修改Dymola模型文件中的阀门开度参数，适配根目录仿真方式
"""

import re
import logging
import numpy as np
from pathlib import Path
from typing import List, Dict, Optional, Tuple
import shutil
import time


class MoFileHandler:
    """
    Dymola .mo文件处理器
    
    负责读取和修改Dymola模型文件中的阀门开度参数
    适配根目录仿真环境的23个阀门配置
    """
    
    def __init__(self, mo_file_path: str, backup_enabled: bool = True):
        """
        初始化mo文件处理器
        
        Args:
            mo_file_path: .mo文件路径
            backup_enabled: 是否启用备份功能
        """
        self.mo_file_path = Path(mo_file_path)
        self.backup_enabled = backup_enabled
        self.logger = logging.getLogger(self.__class__.__name__)
        
        # 验证文件存在性
        if not self.mo_file_path.exists():
            raise FileNotFoundError(f"Mo文件不存在: {self.mo_file_path}")
        
        # 根据根目录仿真环境配置23个有效阀门
        # 跳过8,14,15,16号阀门，实际有效阀门为23个
        self.valve_numbers = [i for i in range(1, 28) if i not in [8, 14, 15, 16]]
        
        # 阀门参数模式匹配（适配const块格式）
        self.valve_pattern = re.compile(
            r'(const\d+)\s*\(\s*k\s*=\s*([0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)\s*\)',
            re.IGNORECASE
        )
        
        self.logger.info(f"初始化Mo文件处理器: {self.mo_file_path}")
        self.logger.info(f"配置有效阀门数量: {len(self.valve_numbers)}")
    
    def read_valve_openings(self) -> Dict[str, float]:
        """
        读取当前mo文件中的所有阀门开度（适配根目录仿真方式）
        
        Returns:
            Dict[str, float]: 阀门名称到开度值的映射
        """
        try:
            with open(self.mo_file_path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            valve_openings = {}
            
            # 只读取有效阀门的开度
            for valve_num in self.valve_numbers:
                const_param = f"const{valve_num}"
                # 修复正则表达式以匹配完整的Modelica格式
                pattern = rf"Modelica\.Blocks\.Sources\.Constant\s+{const_param}\(k=([0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)\)"
                
                match = re.search(pattern, content)
                if match:
                    valve_openings[const_param] = float(match.group(1))
                    self.logger.debug(f"读取阀门 {const_param}: {match.group(1)}")
                else:
                    self.logger.warning(f"未找到阀门参数: {const_param}")
            
            self.logger.debug(f"读取到 {len(valve_openings)} 个阀门开度")
            return valve_openings
            
        except Exception as e:
            self.logger.error(f"读取阀门开度失败: {e}")
            return {}
    
    def get_valve_opening_list(self) -> List[float]:
        """
        获取按顺序排列的阀门开度列表（适配根目录仿真方式）
        
        Returns:
            List[float]: 阀门开度列表，按有效阀门编号顺序排列，长度为23
        """
        valve_openings = self.read_valve_openings()
        
        # 按有效阀门编号顺序排列
        opening_list = []
        for valve_num in self.valve_numbers:
            const_param = f"const{valve_num}"
            if const_param in valve_openings:
                opening_list.append(valve_openings[const_param])
            else:
                # 如果未找到，使用默认值0.75
                self.logger.warning(f"阀门 {const_param} 未找到，使用默认值0.75")
                opening_list.append(0.75)
        
        self.logger.debug(f"获取阀门开度列表: {len(opening_list)} 个阀门")
        
        return opening_list
    
    def modify_valve_openings(self, valve_openings: np.ndarray) -> bool:
        """
        修改阀门开度值（适配根目录仿真方式）
        
        Args:
            valve_openings: 阀门开度数组，长度为23，范围[0.5, 1.0]
            
        Returns:
            bool: 是否修改成功
        """
        try:
            # 验证输入参数
            if len(valve_openings) != len(self.valve_numbers):
                self.logger.error(f"阀门开度数组长度不匹配: {len(valve_openings)} vs {len(self.valve_numbers)}")
                return False
            
            # 参数验证和清理（适配根目录环境的0.5-1.0范围）
            valve_openings = np.clip(valve_openings, 0.5, 1.0)
            valve_openings = np.nan_to_num(valve_openings, nan=0.75, posinf=1.0, neginf=0.5)
            
            # 创建备份
            if self.backup_enabled:
                self._create_backup()
            
            # 读取文件内容
            with open(self.mo_file_path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            # 修改阀门开度参数
            modified_count = 0
            for i, opening in enumerate(valve_openings):
                if i >= len(self.valve_numbers):
                    self.logger.error(f"索引错误: i={i}, valve_numbers长度={len(self.valve_numbers)}")
                    break
                    
                valve_num = self.valve_numbers[i]
                const_param = f"const{valve_num}"
                
                # 检查参数是否存在于文件中
                if const_param not in content:
                    self.logger.warning(f"未找到参数 {const_param} 进行替换")
                    continue
                
                # 使用正则表达式查找并替换const块的k参数值
                pattern = rf"(Modelica\.Blocks\.Sources\.Constant\s+{const_param}\(k=)([0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)\)"
                replacement = rf"\g<1>{opening:.6f})"
                
                # 先检查是否能找到该参数
                match = re.search(pattern, content)
                if match:
                    # 提取当前的k值
                    current_value = float(match.group(2))
                    new_value = opening
                    
                    self.logger.debug(f"找到参数 {const_param}: {match.group(0)}")
                    
                    # 检查值是否需要更新
                    if abs(current_value - new_value) < 1e-6:
                        self.logger.debug(f"参数 {const_param} 值未变化: {current_value:.6f}")
                        continue
                    
                    new_content = re.sub(pattern, replacement, content)
                    if new_content != content:
                        content = new_content
                        modified_count += 1
                        self.logger.debug(f"成功修改参数 {const_param}: {current_value:.6f} -> {new_value:.6f}")
                    else:
                        self.logger.warning(f"参数 {const_param} 替换失败")
                else:
                    self.logger.warning(f"未找到匹配的参数格式: {const_param}")
            
            # 写回文件
            with open(self.mo_file_path, 'w', encoding='utf-8') as file:
                file.write(content)
            
            self.logger.info(f"成功修改 {modified_count} 个阀门开度")
            return modified_count > 0
            
        except Exception as e:
            self.logger.error(f"修改阀门开度失败: {e}")
            return False
    
    def modify_valve_opening_list(self, opening_list: List[float]) -> bool:
        """
        按列表顺序修改所有阀门开度（适配根目录仿真方式）
        
        Args:
            opening_list: 阀门开度列表，长度为23，范围[0.5, 1.0]
            
        Returns:
            bool: 是否修改成功
        """
        try:
            # 检查列表长度匹配
            if len(opening_list) != len(self.valve_numbers):
                self.logger.error(f"开度列表长度 {len(opening_list)} 与阀门数量 {len(self.valve_numbers)} 不匹配")
                return False
            
            # 转换为numpy数组并执行修改
            valve_openings = np.array(opening_list, dtype=float)
            return self.modify_valve_openings(valve_openings)
            
        except Exception as e:
            self.logger.error(f"按列表修改阀门开度失败: {e}")
            return False
    
    def get_valve_count(self) -> int:
        """
        获取有效阀门数量（适配根目录仿真方式）
        
        Returns:
            int: 有效阀门数量（23个）
        """
        return len(self.valve_numbers)
    
    def validate_valve_openings(self, openings: List[float]) -> Tuple[bool, List[str]]:
        """
        验证阀门开度值的有效性（适配根目录仿真方式）
        
        Args:
            openings: 阀门开度列表
            
        Returns:
            Tuple[bool, List[str]]: (是否全部有效, 错误信息列表)
        """
        errors = []
        
        # 检查列表长度
        if len(openings) != len(self.valve_numbers):
            errors.append(f"阀门开度列表长度错误: 期望 {len(self.valve_numbers)}, 实际 {len(openings)}")
        
        for i, opening in enumerate(openings):
            if not isinstance(opening, (int, float)):
                errors.append(f"阀门 {i+1} 开度值类型错误: {type(opening)}")
            elif np.isnan(opening) or np.isinf(opening):
                errors.append(f"阀门 {i+1} 开度值包含无效数值: {opening}")
            elif not (0.5 <= opening <= 1.0):
                errors.append(f"阀门 {i+1} 开度值 {opening} 超出范围 [0.5,1.0]")
        
        return len(errors) == 0, errors
    
    def _create_backup(self) -> None:
        """
        创建mo文件备份
        """
        try:
            timestamp = time.strftime("%Y%m%d_%H%M%S")
            backup_path = self.mo_file_path.with_suffix(f'.backup_{timestamp}.mo')
            shutil.copy2(self.mo_file_path, backup_path)
            self.logger.debug(f"创建备份文件: {backup_path}")
        except Exception as e:
            self.logger.warning(f"创建备份失败: {e}")
    
    def restore_from_backup(self, backup_path: Optional[str] = None) -> bool:
        """
        从备份文件恢复
        
        Args:
            backup_path: 备份文件路径，如果为None则使用最新备份
            
        Returns:
            bool: 是否恢复成功
        """
        try:
            if backup_path is None:
                # 查找最新备份
                backup_files = list(self.mo_file_path.parent.glob(f"{self.mo_file_path.stem}.backup_*.mo"))
                if not backup_files:
                    self.logger.error("未找到备份文件")
                    return False
                backup_path = max(backup_files, key=lambda x: x.stat().st_mtime)
            
            backup_path = Path(backup_path)
            if not backup_path.exists():
                self.logger.error(f"备份文件不存在: {backup_path}")
                return False
            
            shutil.copy2(backup_path, self.mo_file_path)
            self.logger.info(f"从备份恢复成功: {backup_path}")
            return True
            
        except Exception as e:
            self.logger.error(f"从备份恢复失败: {e}")
            return False
    
    def initialize_valve_openings_smart(self, target_avg: float = 0.75, min_opening: float = 0.5, max_opening: float = 1.0) -> bool:
        """
        智能初始化阀门开度
        
        每个阀门独立随机调整，确保const12和const13在0.9以上，平均开度在目标值附近
        
        Args:
            target_avg: 目标平均开度
            min_opening: 最小开度
            max_opening: 最大开度
            
        Returns:
            是否成功修改
        """
        try:
            # 读取当前阀门开度
            current_openings = self.read_valve_openings()
            if not current_openings:
                self.logger.warning("未找到阀门开度，使用随机初始化")
                # 如果读取失败，使用随机初始化
                new_openings_array = np.random.uniform(0.6, 0.9, len(self.valve_numbers))
                # 确保const12和const13在0.9以上
                for i, valve_num in enumerate(self.valve_numbers):
                    if valve_num in [12, 13]:
                        new_openings_array[i] = np.random.uniform(0.9, 1.0)
            else:
                # 创建按阀门编号顺序的开度数组
                new_openings_array = np.zeros(len(self.valve_numbers))
                
                # 第一步：为每个阀门生成随机开度
                for i, valve_num in enumerate(self.valve_numbers):
                    const_param = f"const{valve_num}"
                    current_value = current_openings.get(const_param, 0.75)
                    
                    # 特殊处理const12和const13，确保在0.9以上
                    if valve_num in [12, 13]:
                        new_value = np.random.uniform(0.9, 1.0)
                    else:
                        # 其他阀门在当前值基础上随机调整
                        random_offset = np.random.uniform(-0.15, 0.15)
                        new_value = current_value + random_offset
                        # 确保在范围内
                        new_value = max(min_opening, min(max_opening, new_value))
                    
                    new_openings_array[i] = new_value
                
                # 第二步：调整平均值到目标值
                current_avg = np.mean(new_openings_array)
                adjustment_needed = target_avg - current_avg
                
                # 如果需要调整平均值
                if abs(adjustment_needed) > 0.01:
                    # 对非特殊阀门进行调整
                    for i, valve_num in enumerate(self.valve_numbers):
                        if valve_num not in [12, 13]:  # 不调整const12和const13
                            # 随机分配调整量
                            individual_adjustment = adjustment_needed * np.random.uniform(0.5, 1.5)
                            new_value = new_openings_array[i] + individual_adjustment
                            # 确保在范围内
                            new_value = max(min_opening, min(max_opening, new_value))
                            new_openings_array[i] = new_value
                
                # 记录调整结果
                for i, valve_num in enumerate(self.valve_numbers):
                    const_param = f"const{valve_num}"
                    current_value = current_openings.get(const_param, 0.75)
                    new_value = new_openings_array[i]
                    self.logger.info(f"阀门 {const_param}: {current_value:.3f} -> {new_value:.3f}")
            
            # 计算最终平均值
            final_avg = np.mean(new_openings_array)
            self.logger.info(f"调整后平均开度: {final_avg:.3f} (目标: {target_avg:.3f})")
            
            # 应用新的开度值
            success = self.modify_valve_openings(new_openings_array)
            
            if success:
                self.logger.info(f"智能初始化完成，共修改 {len(new_openings_array)} 个阀门开度")
            else:
                self.logger.error("智能初始化失败")
                
            return success
            
        except Exception as e:
            self.logger.error(f"智能初始化阀门开度失败: {e}")
            return False
    
    def get_file_info(self) -> Dict[str, any]:
        """
        获取mo文件信息
        
        Returns:
            Dict[str, any]: 文件信息字典
        """
        try:
            stat = self.mo_file_path.stat()
            valve_count = self.get_valve_count()
            
            return {
                'file_path': str(self.mo_file_path),
                'file_size': stat.st_size,
                'modified_time': time.ctime(stat.st_mtime),
                'valve_count': valve_count,
                'backup_enabled': self.backup_enabled
            }
        except Exception as e:
            self.logger.error(f"获取文件信息失败: {e}")
            return {}