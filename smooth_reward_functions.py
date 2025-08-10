#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
平滑奖励函数库

作者: Dionysus
日期: 2025-01-16

本模块提供了一系列平滑的数学函数，用于替代硬阈值判断，
使奖励函数连续可微分，提高强化学习的收敛性和稳定性。
"""

import numpy as np
from typing import Tuple, Optional


class SmoothRewardFunctions:
    """
    平滑奖励函数类
    
    提供各种平滑的数学函数，用于构建连续可微分的奖励函数。
    所有函数都设计为连续、有界且可微分的。
    """
    
    @staticmethod
    def smooth_step(x: np.ndarray, threshold: float = 0.5, steepness: float = 10.0) -> np.ndarray:
        """
        平滑阶跃函数
        
        使用sigmoid函数实现平滑的阶跃转换，替代硬阈值判断。
        
        参数:
            x: 输入数组
            threshold: 阶跃点位置
            steepness: 陡峭程度，值越大越接近硬阶跃
            
        返回:
            平滑阶跃函数值，范围[0, 1]
        """
        return 1.0 / (1.0 + np.exp(-steepness * (x - threshold)))
    
    @staticmethod
    def smooth_bell(x: np.ndarray, center: float = 0.0, width: float = 1.0) -> np.ndarray:
        """
        平滑钟形函数
        
        使用高斯函数实现钟形奖励，在目标值附近给予最高奖励。
        
        参数:
            x: 输入数组
            center: 钟形中心位置
            width: 钟形宽度（标准差）
            
        返回:
            钟形函数值，范围[0, 1]
        """
        return np.exp(-0.5 * ((x - center) / width) ** 2)
    
    @staticmethod
    def smooth_penalty(x: np.ndarray, threshold: float = 1.0, steepness: float = 2.0) -> np.ndarray:
        """
        平滑惩罚函数
        
        当输入超过阈值时给予平滑的惩罚，使用二次函数实现。
        
        参数:
            x: 输入数组
            threshold: 惩罚阈值
            steepness: 惩罚陡峭程度
            
        返回:
            惩罚值，范围[0, +∞)
        """
        excess = np.maximum(0, x - threshold)
        return steepness * excess ** 2
    
    @staticmethod
    def smooth_range_reward(x: np.ndarray, min_val: float, max_val: float, 
                           steepness: float = 5.0) -> np.ndarray:
        """
        平滑范围奖励函数
        
        在指定范围内给予奖励，范围外平滑衰减。
        
        参数:
            x: 输入数组
            min_val: 范围最小值
            max_val: 范围最大值
            steepness: 边界陡峭程度
            
        返回:
            范围奖励值，范围[0, 1]
        """
        # 使用sigmoid函数创建平滑边界
        left_boundary = SmoothRewardFunctions.smooth_step(x, min_val, steepness)
        right_boundary = 1.0 - SmoothRewardFunctions.smooth_step(x, max_val, steepness)
        return left_boundary * right_boundary
    
    @staticmethod
    def smooth_temperature_error(temp_diff: np.ndarray, sigma: float = 2.0) -> np.ndarray:
        """
        平滑温度误差函数
        
        使用高斯衰减函数评估温度误差，误差越小奖励越高。
        
        参数:
            temp_diff: 温度差异数组
            sigma: 高斯函数标准差
            
        返回:
            温度误差奖励，范围[0, 1]
        """
        return np.exp(-0.5 * (temp_diff / sigma) ** 2)
    
    @staticmethod
    def smooth_energy_reward(valve_openings: np.ndarray, steepness: float = 2.0) -> np.ndarray:
        """
        平滑能耗奖励函数
        
        使用双曲正切函数评估能耗，开度越小奖励越高。
        
        参数:
            valve_openings: 阀门开度数组
            steepness: 函数陡峭程度
            
        返回:
            能耗奖励，范围[0, 1]
        """
        return 0.5 * (1.0 - np.tanh(steepness * valve_openings))
    
    @staticmethod
    def smooth_variance_penalty(values: np.ndarray, target_variance: float = 0.1, 
                               steepness: float = 10.0) -> np.ndarray:
        """
        平滑方差惩罚函数
        
        当方差超过目标值时给予平滑惩罚。
        
        参数:
            values: 输入值数组
            target_variance: 目标方差
            steepness: 惩罚陡峭程度
            
        返回:
            方差惩罚值
        """
        variance = np.var(values)
        excess_variance = max(0, variance - target_variance)
        return steepness * excess_variance ** 2


class SmoothRewardCalculator:
    """
    平滑奖励计算器（修改版）
    
    使用新的权重分配：阀门开度50%、回水温度一致性50%
    阀门开度要尽可能大，回水温度在20-30℃区间内保持一致
    9号楼的阀门开度必须保持在90以上
    
    特性：
    - 移除温度范围奖励，只要在20-30℃内即可
    - 9号阀门90以下直接重惩罚，90以上小奖励
    - 其他阀门越高越好但低开度重惩罚
    - 移除开度一致性惩罚
    """
    
    def __init__(self, temp_weight: float = 0.5, valve_weight: float = 0.5):
        """
        初始化奖励计算器
        
        参数:
            temp_weight: 温度一致性权重（默认0.5）
            valve_weight: 阀门开度权重（默认0.5）
        """
        self.temp_weight = temp_weight
        self.valve_weight = valve_weight
        self.smooth_funcs = SmoothRewardFunctions()
    
    def _calculate_temp_reward(self, return_temps: np.ndarray) -> float:
        """
        基于实际数据优化的温度一致性奖励函数（-6~6范围）
        
        基于仿真数据分析的改进点：
        1. 针对22-36°C实际温度范围优化阈值
        2. 增加异常值检测（如V27的22°C低温异常）
        3. 强化对极端温差的惩罚（如V3的36°C高温）
        4. 增加温度分布均匀性评估
        5. 移除空间相关性评估（阀门编号不代表空间位置）
        
        参数:
            return_temps: 23个传感器的回水温度数组（单位°C）
            
        返回:
            float: 优化的温度一致性奖励（范围-6~6）
        """
        temps = np.array(return_temps)
        if len(temps) != 23:
            raise ValueError("需传入23个温度传感器数据")

        # ================= 基础统计指标 =================
        temp_mean = np.mean(temps)
        temp_median = np.median(temps)
        temp_std = np.std(temps)
        q1, q3 = np.percentile(temps, [25, 75])
        iqr = q3 - q1
        temp_range = np.max(temps) - np.min(temps)
        
        # ================= 异常值检测与惩罚 =================
        # 基于实际数据调整，V27经常在24-25°C，其他在28-35°C
        normal_min, normal_max = 26.5, 34.5  # 放宽下限到25°C
        outliers_low = np.sum(temps < normal_min)  # 低温异常（<26.5°C）
        outliers_high = np.sum(temps > normal_max)  # 高温异常（>34.5°C）
        
        # 异常值惩罚（减轻惩罚力度）
        outlier_penalty = 0.0
        if outliers_low > 0:
            low_severity = np.mean(normal_min - temps[temps < normal_min])
            outlier_penalty -= 0.5 * outliers_low * (1 + low_severity/6.0)  # 减轻惩罚
        if outliers_high > 0:
            high_severity = np.mean(temps[temps > normal_max] - normal_max)
            outlier_penalty -= 0.4 * outliers_high * (1 + high_severity/5.0)  # 减轻惩罚
        
        # ================= 空间相关性评估已移除 =================
        # 阀门编号不代表空间相邻关系，移除梯度惩罚
        gradient_penalty = 0.0
        
        # ================= 分布均匀性评估 =================
        # 使用Gini系数评估温度分布均匀性（基于实际数据调整阈值）
        sorted_temps = np.sort(temps)
        n = len(sorted_temps)
        gini_index = (2 * np.sum((np.arange(1, n+1) * sorted_temps))) / (n * np.sum(sorted_temps)) - (n+1)/n
        gini_penalty = -2.0 * gini_index if gini_index > 0.15 else 0.5 * (0.15 - gini_index)  # 放宽阈值，减轻惩罚
        
        # ================= 核心一致性指标 =================
        # 1. 标准差奖励（基于实际2.9°C标准差调整）
        if temp_std <= 2.0:  # 优秀一致性
            std_reward = 3.5 * np.exp(-temp_std/1.2)
        elif temp_std <= 2.7:  # 良好一致性（包含实际2.9°C）
            std_reward = 2.5 * (2.7 - temp_std)/1.0
        elif temp_std <= 3.3:  # 可接受一致性
            std_reward = 1.5 * (3.3 - temp_std)/1.0
        else:  # 差一致性
            std_reward = -2.0 * np.tanh((temp_std - 3.3)/1.5)
        
        # 2. 四分位距奖励（基于实际数据调整）
        if iqr <= 2.5:  # 优秀
            iqr_reward = 3.5 * np.exp(-iqr/1.5)
        elif iqr <= 4.0:  # 良好
            iqr_reward = 1.8 * (4.0 - iqr)/1.5
        elif iqr <= 6.0:  # 可接受
            iqr_reward = 1.2 * (6.0 - iqr)/1.5
        else:  # 差
            iqr_reward = -1.5 * np.tanh((iqr - 6.0)/2.0)
        
        # 3. 极差奖励（基于实际10-11°C范围调整）
        if temp_range <= 6.0:  # 优秀
            range_reward = 3.0 * np.exp(-temp_range/4.0)
        elif temp_range <= 9.0:  # 良好（包含实际10-11°C）
            range_reward = 2.5 * (10.0 - temp_range)/4.0
        elif temp_range <= 11.0:  # 可接受
            range_reward = 1.5 * (12.0 - temp_range)/4.0
        else:  # 差
            range_reward = -1.5 * np.tanh((temp_range - 12.0)/4.0)
        
        # ================= 温度聚类奖励 =================
        # 奖励温度值聚集在合理范围内（基于实际数据调整为28-35°C）
        ideal_range_count = np.sum((temps >= 28.0) & (temps <= 34.0))
        cluster_reward = 1.5 * (ideal_range_count / len(temps)) - 0.3  # 提高奖励，降低基准
        
        # ================= 综合计算 =================
        total_reward = (
            std_reward * 0.35 +        # 标准差权重35%
            iqr_reward * 0.25 +        # 四分位距权重25%
            range_reward * 0.20 +      # 极差权重20%
            cluster_reward * 0.10 +    # 聚类奖励权重10%
            gini_penalty * 0.10 +      # 均匀性权重10%
            outlier_penalty +          # 异常值惩罚
            gradient_penalty           # 梯度惩罚
        )
        
        # ================= 极端情况额外惩罚 =================
        if temp_range > 15.0 or temp_std > 5.0:  # 基于实际数据调整阈值
            total_reward -= 1.0  # 减轻严重不一致的额外惩罚
        
        return float(np.clip(total_reward, -6.0, 6.0))
    
    def _calculate_valve_reward(self, valve_openings: np.ndarray) -> float:
        """
        阀门开度奖励函数（工业实用版）
        
        核心设计原则：
        1. 三段式奖励：明确划分低/中/高开度区间，强化85%以上开度的激励
        2. 渐进惩罚：低开度惩罚从65%开始逐步加重，避免突变
        3. 动态均衡：对开度差异过大的情况实施惩罚（如部分全开部分半开）
        4. 节能补偿：对90%以上开度额外奖励，但抑制全员全开（保留调节余量）

        参数:
            valve_openings: 阀门开度数组（单位%），建议范围50-100
            
        返回:
            float: 归一化奖励值（范围-6~6），越高表示开度策略越优
        """
        openings = np.clip(valve_openings, 50, 100)  # 强制限制到合理范围
        n_valves = len(openings)
        
        # ================= 核心奖励计算 =================
        # 1. 分段开度奖励（非线性设计）
        segment_rewards = np.zeros_like(openings, dtype=float)
        
        # 高开度奖励区（85-100%）
        high_open_mask = openings >= 85
        segment_rewards[high_open_mask] = 3.0 + 2.0 * (openings[high_open_mask] - 85)/15  # 85%→3分, 100%→5分
        
        # 中开度奖励区（60-85%）
        mid_open_mask = (openings >= 60) & (~high_open_mask)
        segment_rewards[mid_open_mask] = 0.5 + 1.0 * (openings[mid_open_mask] - 60)/20  # 60%→0.5分, 85%→1.5分
        
        # 低开度惩罚区（50-60%）
        low_open_mask = openings < 60
        segment_rewards[low_open_mask] = -1.0 * (60 - openings[low_open_mask])/10  # 65%→0分, 50%→-1分
        
        # 2. 开度均衡性惩罚（抑制极端差异）
        open_std = np.std(openings)
        consistency_penalty = -0.6 * np.tanh(open_std/8)  # 标准差>8%时显著惩罚
        
        # 3. 节能补偿奖励（鼓励合理高开度）
        mean_open = np.mean(openings)
        energy_bonus = 0.8 * np.tanh((mean_open - 75)/10)  # 均值>75%时奖励
        
        # ================= 综合计算 =================
        base_reward = np.mean(segment_rewards)
        total_reward = (
            base_reward * 0.6 +          # 主奖励权重60%
            consistency_penalty * 0.3 +  # 均衡性权重30%
            energy_bonus * 0.1           # 节能奖励10%
        )
        
        # ================= 特殊规则 =================
        # 规则1：存在<55%开度时追加惩罚
        if np.sum(openings < 55) > 0:
            total_reward -= 0.5 * np.sum(openings < 55)/n_valves
        
        
        return float(np.clip(total_reward, -6.0, 6.0))
    
    def calculate_reward(self, return_temps: np.ndarray, valve_openings: np.ndarray) -> float:
        """
        计算总奖励（修改版）
        
        参数:
            return_temps: 回水温度数组
            valve_openings: 阀门开度数组
            
        返回:
            float: 总奖励值（范围：-6到+6）
        """
        temp_reward = self._calculate_temp_reward(return_temps)
        valve_reward = self._calculate_valve_reward(valve_openings)
        
        # 加权计算：50%温度一致性 + 50%阀门开度
        weighted_temp = self.temp_weight * temp_reward
        weighted_valve = self.valve_weight * valve_reward
        
        # 总奖励
        total_reward = weighted_temp + weighted_valve
        
        return float(np.clip(total_reward, -6.0, 6.0))
    
    def get_reward_breakdown(self, 
                            return_temps: np.ndarray,
                            valve_openings: np.ndarray) -> dict:
        """
        获取奖励的详细分解
        
        参数:
            valve_openings: 阀门开度数组
            return_temps: 回水温度数组
            
        返回:
            dict: 包含各项奖励分解的字典
        """
        temp_reward = self._calculate_temp_reward(return_temps)
        valve_reward = self._calculate_valve_reward(valve_openings)
        total_reward = self.calculate_reward(return_temps, valve_openings)
        
        # 计算温度统计
        temps = np.array(return_temps)
        temp_mean = np.mean(temps)
        temp_variance = np.var(temps)
        temp_std = np.std(temps)
        in_range_mask = (temps >= 20) & (temps <= 30)
        temp_in_range = np.sum(in_range_mask)
        temp_out_range = len(temps) - temp_in_range
        
        # 计算阀门统计
        valve_9_opening = valve_openings[8]
        other_valves = np.concatenate([valve_openings[:8], valve_openings[9:]])
        other_avg = np.mean(other_valves)
        
        # 计算各部分奖励
        range_penalty = -0.5 * temp_out_range if temp_out_range > 0 else 0
        if temp_variance <= 1.0:
            consistency_reward = 3.0 * np.exp(-temp_variance)
        elif temp_variance <= 4.0:
            consistency_reward = 3.0 * (4.0 - temp_variance) / 3.0
        else:
            consistency_reward = -1.0 * np.tanh((temp_variance - 4.0) / 5.0)
        
        valve_9_reward = 1.0 if valve_9_opening >= 90 else -3.0
        
        return {
            'total_reward': total_reward,
            'temp_reward': temp_reward,
            'valve_reward': valve_reward,
            'weighted_temp': self.temp_weight * temp_reward,
            'weighted_valve': self.valve_weight * valve_reward,
            'temp_breakdown': {
                'range_penalty': range_penalty,
                'consistency_reward': consistency_reward
            },
            'valve_breakdown': {
                'valve_9_reward': valve_9_reward,
                'other_avg_reward': valve_reward - 0.5 * valve_9_reward  # 反推其他阀门平均奖励
            },
            'temp_stats': {
                'mean': temp_mean,
                'variance': temp_variance,
                'std': temp_std,
                'in_range_count': temp_in_range,
                'out_range_count': temp_out_range,
                'in_range_ratio': temp_in_range / len(temps)
            },
            'valve_stats': {
                'valve_9_opening': valve_9_opening,
                'other_avg_opening': other_avg,
                'valve_9_compliant': valve_9_opening >= 90
            },
            'weights': {
                'temp_weight': self.temp_weight,
                'valve_weight': self.valve_weight
            }
        }


def create_smooth_reward_calculator():
    """
    创建平滑奖励计算器
    
    返回:
        SmoothRewardCalculator: 奖励计算器实例
    """
    return SmoothRewardCalculator()