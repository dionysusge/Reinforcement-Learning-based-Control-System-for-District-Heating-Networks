#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
数据处理器

作者: Dionysus
"""

import numpy as np
import pandas as pd
import json
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
import logging
from datetime import datetime

class DataProcessor:
    """
    数据处理器类
    
    负责处理仿真结果数据，进行分析和统计
    """
    
    def __init__(self, results_dir: Path):
        """
        初始化数据处理器
        
        Args:
            results_dir: 结果文件目录
        """
        self.results_dir = Path(results_dir)
        self.logger = logging.getLogger(__name__)
        
        # 确保结果目录存在
        self.results_dir.mkdir(parents=True, exist_ok=True)
        
        self.logger.info(f"数据处理器初始化完成，结果目录: {self.results_dir}")
    
    def load_simulation_results(self, result_file: Path) -> Optional[Dict[str, Any]]:
        """
        加载仿真结果文件
        
        Args:
            result_file: 结果文件路径
            
        Returns:
            Optional[Dict[str, Any]]: 仿真结果数据
        """
        try:
            if not result_file.exists():
                self.logger.error(f"结果文件不存在: {result_file}")
                return None
            
            with open(result_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            self.logger.info(f"成功加载结果文件: {result_file}")
            return data
            
        except Exception as e:
            self.logger.error(f"加载结果文件失败: {e}")
            return None
    
    def analyze_convergence(self, iteration_history: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        分析收敛性
        
        Args:
            iteration_history: 迭代历史数据
            
        Returns:
            Dict[str, Any]: 收敛性分析结果
        """
        try:
            if not iteration_history:
                return {'error': '无迭代历史数据'}
            
            # 提取性能指标序列
            performances = [item['performance'] for item in iteration_history]
            iterations = [item['iteration'] for item in iteration_history]
            
            # 计算收敛指标
            analysis = {
                'total_iterations': len(performances),
                'initial_performance': performances[0],
                'final_performance': performances[-1],
                'best_performance': min(performances),
                'worst_performance': max(performances),
                'improvement': performances[0] - performances[-1],
                'improvement_ratio': (performances[0] - performances[-1]) / performances[0] if performances[0] != 0 else 0,
                'convergence_rate': self._calculate_convergence_rate(performances),
                'stability_index': self._calculate_stability_index(performances),
                'monotonic_improvement': self._check_monotonic_improvement(performances)
            }
            
            # 找到最佳迭代
            best_idx = performances.index(analysis['best_performance'])
            analysis['best_iteration'] = iterations[best_idx]
            
            # 计算收敛点（性能改进小于阈值的点）
            convergence_point = self._find_convergence_point(performances)
            analysis['convergence_iteration'] = convergence_point
            
            return analysis
            
        except Exception as e:
            self.logger.error(f"分析收敛性失败: {e}")
            return {'error': str(e)}
    
    def _calculate_convergence_rate(self, performances: List[float]) -> float:
        """
        计算收敛速率
        
        Args:
            performances: 性能指标序列
            
        Returns:
            float: 收敛速率
        """
        if len(performances) < 2:
            return 0.0
        
        # 计算相邻迭代间的改进率
        improvements = []
        for i in range(1, len(performances)):
            if performances[i-1] != 0:
                improvement = (performances[i-1] - performances[i]) / performances[i-1]
                improvements.append(improvement)
        
        return np.mean(improvements) if improvements else 0.0
    
    def _calculate_stability_index(self, performances: List[float]) -> float:
        """
        计算稳定性指数
        
        Args:
            performances: 性能指标序列
            
        Returns:
            float: 稳定性指数（越小越稳定）
        """
        if len(performances) < 2:
            return 0.0
        
        # 计算后半段的标准差
        half_point = len(performances) // 2
        latter_half = performances[half_point:]
        
        return np.std(latter_half) if len(latter_half) > 1 else 0.0
    
    def _check_monotonic_improvement(self, performances: List[float]) -> bool:
        """
        检查是否单调改进
        
        Args:
            performances: 性能指标序列
            
        Returns:
            bool: 是否单调改进
        """
        for i in range(1, len(performances)):
            if performances[i] > performances[i-1]:
                return False
        return True
    
    def _find_convergence_point(self, performances: List[float], threshold: float = 0.01) -> Optional[int]:
        """
        找到收敛点
        
        Args:
            performances: 性能指标序列
            threshold: 改进阈值
            
        Returns:
            Optional[int]: 收敛点迭代次数
        """
        for i in range(1, len(performances)):
            if abs(performances[i] - performances[i-1]) < threshold:
                # 检查后续几个点是否也满足条件
                converged = True
                for j in range(i+1, min(i+5, len(performances))):
                    if abs(performances[j] - performances[j-1]) >= threshold:
                        converged = False
                        break
                
                if converged:
                    return i + 1  # 返回迭代次数（从1开始）
        
        return None
    
    def analyze_temperature_performance(self, iteration_history: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        分析温度性能
        
        Args:
            iteration_history: 迭代历史数据
            
        Returns:
            Dict[str, Any]: 温度性能分析结果
        """
        try:
            if not iteration_history:
                return {'error': '无迭代历史数据'}
            
            # 提取温度数据
            return_temps = [item.get('avg_return_temp', 0) for item in iteration_history]
            temp_stds = [item.get('std_return_temp', 0) for item in iteration_history]
            
            analysis = {
                'temperature_trend': {
                    'initial_temp': return_temps[0],
                    'final_temp': return_temps[-1],
                    'min_temp': min(return_temps),
                    'max_temp': max(return_temps),
                    'avg_temp': np.mean(return_temps),
                    'temp_range': max(return_temps) - min(return_temps)
                },
                'temperature_consistency': {
                    'initial_std': temp_stds[0],
                    'final_std': temp_stds[-1],
                    'min_std': min(temp_stds),
                    'max_std': max(temp_stds),
                    'avg_std': np.mean(temp_stds),
                    'consistency_improvement': temp_stds[0] - temp_stds[-1]
                },
                'target_achievement': {
                    'target_temp': 45.0,  # 目标回水温度
                    'final_deviation': abs(return_temps[-1] - 45.0),
                    'avg_deviation': np.mean([abs(temp - 45.0) for temp in return_temps]),
                    'within_tolerance_ratio': sum(1 for temp in return_temps if abs(temp - 45.0) <= 2.0) / len(return_temps)
                }
            }
            
            return analysis
            
        except Exception as e:
            self.logger.error(f"分析温度性能失败: {e}")
            return {'error': str(e)}
    
    def analyze_valve_performance(self, iteration_history: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        分析阀门性能
        
        Args:
            iteration_history: 迭代历史数据
            
        Returns:
            Dict[str, Any]: 阀门性能分析结果
        """
        try:
            if not iteration_history:
                return {'error': '无迭代历史数据'}
            
            # 提取阀门开度数据
            valve_openings_history = [item.get('valve_openings', []) for item in iteration_history]
            avg_openings = [item.get('avg_valve_opening', 0) for item in iteration_history]
            
            analysis = {
                'opening_trend': {
                    'initial_avg': avg_openings[0],
                    'final_avg': avg_openings[-1],
                    'min_avg': min(avg_openings),
                    'max_avg': max(avg_openings),
                    'overall_avg': np.mean(avg_openings),
                    'adjustment_range': max(avg_openings) - min(avg_openings)
                },
                'valve_stability': {
                    'opening_std': np.std(avg_openings),
                    'total_adjustments': len(valve_openings_history) - 1,
                    'avg_adjustment_magnitude': self._calculate_avg_adjustment_magnitude(valve_openings_history)
                },
                'individual_valves': self._analyze_individual_valves(valve_openings_history)
            }
            
            return analysis
            
        except Exception as e:
            self.logger.error(f"分析阀门性能失败: {e}")
            return {'error': str(e)}
    
    def _calculate_avg_adjustment_magnitude(self, valve_openings_history: List[List[float]]) -> float:
        """
        计算平均调整幅度
        
        Args:
            valve_openings_history: 阀门开度历史
            
        Returns:
            float: 平均调整幅度
        """
        if len(valve_openings_history) < 2:
            return 0.0
        
        adjustments = []
        for i in range(1, len(valve_openings_history)):
            if len(valve_openings_history[i]) == len(valve_openings_history[i-1]):
                current = np.array(valve_openings_history[i])
                previous = np.array(valve_openings_history[i-1])
                adjustment = np.mean(np.abs(current - previous))
                adjustments.append(adjustment)
        
        return np.mean(adjustments) if adjustments else 0.0
    
    def _analyze_individual_valves(self, valve_openings_history: List[List[float]]) -> Dict[str, Any]:
        """
        分析单个阀门的性能
        
        Args:
            valve_openings_history: 阀门开度历史
            
        Returns:
            Dict[str, Any]: 单个阀门分析结果
        """
        if not valve_openings_history or not valve_openings_history[0]:
            return {}
        
        num_valves = len(valve_openings_history[0])
        valve_analysis = {}
        
        for valve_idx in range(num_valves):
            valve_data = [openings[valve_idx] for openings in valve_openings_history if valve_idx < len(openings)]
            
            if valve_data:
                valve_analysis[f'valve_{valve_idx+1}'] = {
                    'initial_opening': valve_data[0],
                    'final_opening': valve_data[-1],
                    'min_opening': min(valve_data),
                    'max_opening': max(valve_data),
                    'avg_opening': np.mean(valve_data),
                    'opening_std': np.std(valve_data),
                    'total_adjustment': abs(valve_data[-1] - valve_data[0]),
                    'adjustment_count': sum(1 for i in range(1, len(valve_data)) if abs(valve_data[i] - valve_data[i-1]) > 0.01)
                }
        
        return valve_analysis
    
    def generate_summary_report(self, result_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        生成汇总报告
        
        Args:
            result_data: 结果数据
            
        Returns:
            Dict[str, Any]: 汇总报告
        """
        try:
            if 'iteration_history' not in result_data:
                return {'error': '缺少迭代历史数据'}
            
            iteration_history = result_data['iteration_history']
            
            # 各项分析
            convergence_analysis = self.analyze_convergence(iteration_history)
            temperature_analysis = self.analyze_temperature_performance(iteration_history)
            valve_analysis = self.analyze_valve_performance(iteration_history)
            
            # 生成汇总报告
            report = {
                'simulation_info': {
                    'total_iterations': result_data.get('total_iterations', 0),
                    'total_time': result_data.get('total_time', 0),
                    'converged': result_data.get('converged', False),
                    'success': result_data.get('success', False)
                },
                'performance_summary': {
                    'best_performance': result_data.get('best_performance', float('inf')),
                    'final_performance': iteration_history[-1]['performance'] if iteration_history else 0,
                    'improvement_achieved': convergence_analysis.get('improvement', 0),
                    'convergence_iteration': convergence_analysis.get('convergence_iteration')
                },
                'temperature_summary': {
                    'final_avg_temp': temperature_analysis.get('temperature_trend', {}).get('final_temp', 0),
                    'target_deviation': temperature_analysis.get('target_achievement', {}).get('final_deviation', 0),
                    'consistency_improvement': temperature_analysis.get('temperature_consistency', {}).get('consistency_improvement', 0),
                    'within_tolerance_ratio': temperature_analysis.get('target_achievement', {}).get('within_tolerance_ratio', 0)
                },
                'valve_summary': {
                    'final_avg_opening': valve_analysis.get('opening_trend', {}).get('final_avg', 0),
                    'opening_stability': valve_analysis.get('valve_stability', {}).get('opening_std', 0),
                    'total_adjustments': valve_analysis.get('valve_stability', {}).get('total_adjustments', 0),
                    'avg_adjustment_magnitude': valve_analysis.get('valve_stability', {}).get('avg_adjustment_magnitude', 0)
                },
                'detailed_analysis': {
                    'convergence': convergence_analysis,
                    'temperature': temperature_analysis,
                    'valve': valve_analysis
                },
                'recommendations': self._generate_recommendations(convergence_analysis, temperature_analysis, valve_analysis)
            }
            
            return report
            
        except Exception as e:
            self.logger.error(f"生成汇总报告失败: {e}")
            return {'error': str(e)}
    
    def _generate_recommendations(self, convergence_analysis: Dict[str, Any], 
                                temperature_analysis: Dict[str, Any], 
                                valve_analysis: Dict[str, Any]) -> List[str]:
        """
        生成改进建议
        
        Args:
            convergence_analysis: 收敛性分析
            temperature_analysis: 温度分析
            valve_analysis: 阀门分析
            
        Returns:
            List[str]: 建议列表
        """
        recommendations = []
        
        # 收敛性建议
        if not convergence_analysis.get('monotonic_improvement', True):
            recommendations.append("建议调整学习率或增加正则化以改善收敛稳定性")
        
        if convergence_analysis.get('convergence_iteration') is None:
            recommendations.append("建议增加最大迭代次数或调整收敛阈值")
        
        # 温度控制建议
        temp_deviation = temperature_analysis.get('target_achievement', {}).get('final_deviation', 0)
        if temp_deviation > 2.0:
            recommendations.append(f"回水温度偏差较大({temp_deviation:.2f}°C)，建议调整控制策略")
        
        consistency_improvement = temperature_analysis.get('temperature_consistency', {}).get('consistency_improvement', 0)
        if consistency_improvement < 0:
            recommendations.append("温度一致性有所下降，建议增加温度一致性权重")
        
        # 阀门控制建议
        opening_std = valve_analysis.get('valve_stability', {}).get('opening_std', 0)
        if opening_std > 0.1:
            recommendations.append(f"阀门开度变化较大({opening_std:.3f})，建议增加平滑性约束")
        
        avg_adjustment = valve_analysis.get('valve_stability', {}).get('avg_adjustment_magnitude', 0)
        if avg_adjustment > 0.05:
            recommendations.append(f"阀门调整幅度较大({avg_adjustment:.3f})，建议减小调整步长")
        
        if not recommendations:
            recommendations.append("控制性能良好，可考虑进一步优化以提高效率")
        
        return recommendations
    
    def save_analysis_report(self, report: Dict[str, Any], filename: Optional[str] = None) -> Path:
        """
        保存分析报告
        
        Args:
            report: 分析报告
            filename: 文件名（可选）
            
        Returns:
            Path: 保存的文件路径
        """
        try:
            if filename is None:
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                filename = f'analysis_report_{timestamp}.json'
            
            filepath = self.results_dir / filename
            
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(report, f, indent=2, ensure_ascii=False)
            
            self.logger.info(f"分析报告已保存: {filepath}")
            return filepath
            
        except Exception as e:
            self.logger.error(f"保存分析报告失败: {e}")
            raise
    
    def export_to_excel(self, result_data: Dict[str, Any], filename: Optional[str] = None) -> Path:
        """
        导出结果到Excel文件
        
        Args:
            result_data: 结果数据
            filename: 文件名（可选）
            
        Returns:
            Path: 导出的文件路径
        """
        try:
            if filename is None:
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                filename = f'simulation_results_{timestamp}.xlsx'
            
            filepath = self.results_dir / filename
            
            with pd.ExcelWriter(filepath, engine='openpyxl') as writer:
                # 迭代历史
                if 'iteration_history' in result_data:
                    df_history = pd.DataFrame(result_data['iteration_history'])
                    df_history.to_excel(writer, sheet_name='迭代历史', index=False)
                
                # 汇总信息
                summary_data = {
                    '指标': ['总迭代次数', '总耗时(秒)', '是否收敛', '最佳性能', '最终性能'],
                    '值': [
                        result_data.get('total_iterations', 0),
                        result_data.get('total_time', 0),
                        result_data.get('converged', False),
                        result_data.get('best_performance', 0),
                        result_data['iteration_history'][-1]['performance'] if result_data.get('iteration_history') else 0
                    ]
                }
                df_summary = pd.DataFrame(summary_data)
                df_summary.to_excel(writer, sheet_name='汇总信息', index=False)
                
                # 最佳阀门开度
                if 'best_valve_openings' in result_data and result_data['best_valve_openings']:
                    valve_data = {
                        '阀门编号': [f'阀门{i+1}' for i in range(len(result_data['best_valve_openings']))],
                        '最佳开度': result_data['best_valve_openings']
                    }
                    df_valves = pd.DataFrame(valve_data)
                    df_valves.to_excel(writer, sheet_name='最佳阀门开度', index=False)
            
            self.logger.info(f"结果已导出到Excel: {filepath}")
            return filepath
            
        except Exception as e:
            self.logger.error(f"导出Excel失败: {e}")
            raise