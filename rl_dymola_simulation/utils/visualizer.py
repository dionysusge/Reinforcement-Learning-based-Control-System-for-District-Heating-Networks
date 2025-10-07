#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
结果可视化工具

作者: Dionysus
"""

import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns
import numpy as np
import pandas as pd
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
import logging
from datetime import datetime

# 设置中文字体
plt.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False

class ResultVisualizer:
    """
    结果可视化器类
    
    负责生成各种图表来展示仿真结果
    """
    
    def __init__(self, output_dir: Path):
        """
        初始化可视化器
        
        Args:
            output_dir: 输出目录
        """
        self.output_dir = Path(output_dir)
        self.logger = logging.getLogger(__name__)
        
        # 确保输出目录存在
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # 设置绘图样式
        sns.set_style("whitegrid")
        plt.style.use('seaborn-v0_8')
        
        self.logger.info(f"可视化器初始化完成，输出目录: {self.output_dir}")
    
    def plot_convergence_curve(self, iteration_history: List[Dict[str, Any]], 
                              save_path: Optional[Path] = None) -> Path:
        """
        绘制收敛曲线
        
        Args:
            iteration_history: 迭代历史数据
            save_path: 保存路径（可选）
            
        Returns:
            Path: 图片保存路径
        """
        try:
            if not iteration_history:
                raise ValueError("无迭代历史数据")
            
            # 提取数据
            iterations = [item['iteration'] for item in iteration_history]
            performances = [item['performance'] for item in iteration_history]
            
            # 创建图形
            fig, ax = plt.subplots(figsize=(12, 8))
            
            # 绘制收敛曲线
            ax.plot(iterations, performances, 'b-', linewidth=2, marker='o', markersize=4, label='性能指标')
            
            # 添加最佳点标记
            best_idx = performances.index(min(performances))
            ax.plot(iterations[best_idx], performances[best_idx], 'r*', markersize=15, label=f'最佳点 (迭代{iterations[best_idx]})')
            
            # 添加趋势线
            if len(iterations) > 2:
                z = np.polyfit(iterations, performances, 1)
                p = np.poly1d(z)
                ax.plot(iterations, p(iterations), 'r--', alpha=0.7, label='趋势线')
            
            # 设置标签和标题
            ax.set_xlabel('迭代次数', fontsize=12)
            ax.set_ylabel('性能指标', fontsize=12)
            ax.set_title('控制算法收敛曲线', fontsize=14, fontweight='bold')
            ax.legend()
            ax.grid(True, alpha=0.3)
            
            # 添加统计信息
            stats_text = f'总迭代: {len(iterations)}\n最佳性能: {min(performances):.4f}\n改进: {performances[0] - min(performances):.4f}'
            ax.text(0.02, 0.98, stats_text, transform=ax.transAxes, fontsize=10, 
                   verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
            
            plt.tight_layout()
            
            # 保存图片
            if save_path is None:
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                save_path = self.output_dir / f'convergence_curve_{timestamp}.png'
            
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            plt.close()
            
            self.logger.info(f"收敛曲线已保存: {save_path}")
            return save_path
            
        except Exception as e:
            self.logger.error(f"绘制收敛曲线失败: {e}")
            raise
    
    def plot_temperature_trends(self, iteration_history: List[Dict[str, Any]], 
                               save_path: Optional[Path] = None) -> Path:
        """
        绘制温度变化趋势
        
        Args:
            iteration_history: 迭代历史数据
            save_path: 保存路径（可选）
            
        Returns:
            Path: 图片保存路径
        """
        try:
            if not iteration_history:
                raise ValueError("无迭代历史数据")
            
            # 提取数据
            iterations = [item['iteration'] for item in iteration_history]
            avg_temps = [item.get('avg_return_temp', 0) for item in iteration_history]
            std_temps = [item.get('std_return_temp', 0) for item in iteration_history]
            
            # 创建子图
            fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))
            
            # 绘制平均温度
            ax1.plot(iterations, avg_temps, 'b-', linewidth=2, marker='o', markersize=4, label='平均回水温度')
            ax1.axhline(y=45, color='r', linestyle='--', alpha=0.7, label='目标温度 (45°C)')
            ax1.fill_between(iterations, [43]*len(iterations), [47]*len(iterations), 
                           alpha=0.2, color='green', label='容差范围 (±2°C)')
            
            ax1.set_xlabel('迭代次数', fontsize=12)
            ax1.set_ylabel('温度 (°C)', fontsize=12)
            ax1.set_title('平均回水温度变化趋势', fontsize=14, fontweight='bold')
            ax1.legend()
            ax1.grid(True, alpha=0.3)
            
            # 绘制温度标准差
            ax2.plot(iterations, std_temps, 'g-', linewidth=2, marker='s', markersize=4, label='温度标准差')
            ax2.set_xlabel('迭代次数', fontsize=12)
            ax2.set_ylabel('标准差 (°C)', fontsize=12)
            ax2.set_title('温度一致性变化趋势', fontsize=14, fontweight='bold')
            ax2.legend()
            ax2.grid(True, alpha=0.3)
            
            # 添加统计信息
            final_temp = avg_temps[-1]
            final_std = std_temps[-1]
            temp_deviation = abs(final_temp - 45)
            
            stats_text = f'最终平均温度: {final_temp:.2f}°C\n目标偏差: {temp_deviation:.2f}°C\n最终标准差: {final_std:.2f}°C'
            ax1.text(0.02, 0.98, stats_text, transform=ax1.transAxes, fontsize=10, 
                    verticalalignment='top', bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
            
            plt.tight_layout()
            
            # 保存图片
            if save_path is None:
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                save_path = self.output_dir / f'temperature_trends_{timestamp}.png'
            
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            plt.close()
            
            self.logger.info(f"温度趋势图已保存: {save_path}")
            return save_path
            
        except Exception as e:
            self.logger.error(f"绘制温度趋势图失败: {e}")
            raise
    
    def plot_valve_openings(self, iteration_history: List[Dict[str, Any]], 
                           save_path: Optional[Path] = None) -> Path:
        """
        绘制阀门开度变化
        
        Args:
            iteration_history: 迭代历史数据
            save_path: 保存路径（可选）
            
        Returns:
            Path: 图片保存路径
        """
        try:
            if not iteration_history:
                raise ValueError("无迭代历史数据")
            
            # 提取数据
            iterations = [item['iteration'] for item in iteration_history]
            avg_openings = [item.get('avg_valve_opening', 0) for item in iteration_history]
            
            # 提取所有阀门的开度数据
            valve_openings_data = []
            for item in iteration_history:
                if 'valve_openings' in item and item['valve_openings']:
                    valve_openings_data.append(item['valve_openings'])
            
            # 创建图形
            fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 12))
            
            # 绘制平均阀门开度
            ax1.plot(iterations, avg_openings, 'b-', linewidth=2, marker='o', markersize=4, label='平均阀门开度')
            ax1.axhline(y=0.75, color='r', linestyle='--', alpha=0.7, label='理想开度 (75%)')
            ax1.fill_between(iterations, [0.5]*len(iterations), [1.0]*len(iterations), 
                           alpha=0.1, color='gray', label='允许范围 (50%-100%)')
            
            ax1.set_xlabel('迭代次数', fontsize=12)
            ax1.set_ylabel('阀门开度', fontsize=12)
            ax1.set_title('平均阀门开度变化趋势', fontsize=14, fontweight='bold')
            ax1.legend()
            ax1.grid(True, alpha=0.3)
            
            # 绘制所有阀门的开度热力图
            if valve_openings_data:
                valve_matrix = np.array(valve_openings_data).T  # 转置，使阀门为行，迭代为列
                
                im = ax2.imshow(valve_matrix, cmap='RdYlBu_r', aspect='auto', interpolation='nearest')
                ax2.set_xlabel('迭代次数', fontsize=12)
                ax2.set_ylabel('阀门编号', fontsize=12)
                ax2.set_title('各阀门开度热力图', fontsize=14, fontweight='bold')
                
                # 设置刻度
                ax2.set_xticks(range(0, len(iterations), max(1, len(iterations)//10)))
                ax2.set_xticklabels([iterations[i] for i in range(0, len(iterations), max(1, len(iterations)//10))])
                ax2.set_yticks(range(0, valve_matrix.shape[0], max(1, valve_matrix.shape[0]//10)))
                ax2.set_yticklabels([f'阀门{i+1}' for i in range(0, valve_matrix.shape[0], max(1, valve_matrix.shape[0]//10))])
                
                # 添加颜色条
                cbar = plt.colorbar(im, ax=ax2)
                cbar.set_label('阀门开度', fontsize=12)
            
            # 添加统计信息
            final_avg = avg_openings[-1]
            opening_range = max(avg_openings) - min(avg_openings)
            
            stats_text = f'最终平均开度: {final_avg:.3f}\n开度变化范围: {opening_range:.3f}\n总调整次数: {len(iterations)-1}'
            ax1.text(0.02, 0.98, stats_text, transform=ax1.transAxes, fontsize=10, 
                    verticalalignment='top', bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
            
            plt.tight_layout()
            
            # 保存图片
            if save_path is None:
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                save_path = self.output_dir / f'valve_openings_{timestamp}.png'
            
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            plt.close()
            
            self.logger.info(f"阀门开度图已保存: {save_path}")
            return save_path
            
        except Exception as e:
            self.logger.error(f"绘制阀门开度图失败: {e}")
            raise
    
    def plot_performance_dashboard(self, result_data: Dict[str, Any], 
                                  save_path: Optional[Path] = None) -> Path:
        """
        绘制性能仪表板
        
        Args:
            result_data: 结果数据
            save_path: 保存路径（可选）
            
        Returns:
            Path: 图片保存路径
        """
        try:
            if 'iteration_history' not in result_data:
                raise ValueError("缺少迭代历史数据")
            
            iteration_history = result_data['iteration_history']
            
            # 创建2x2子图
            fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(16, 12))
            
            # 提取数据
            iterations = [item['iteration'] for item in iteration_history]
            performances = [item['performance'] for item in iteration_history]
            avg_temps = [item.get('avg_return_temp', 0) for item in iteration_history]
            std_temps = [item.get('std_return_temp', 0) for item in iteration_history]
            avg_openings = [item.get('avg_valve_opening', 0) for item in iteration_history]
            
            # 1. 收敛曲线
            ax1.plot(iterations, performances, 'b-', linewidth=2, marker='o', markersize=3)
            best_idx = performances.index(min(performances))
            ax1.plot(iterations[best_idx], performances[best_idx], 'r*', markersize=12)
            ax1.set_xlabel('迭代次数')
            ax1.set_ylabel('性能指标')
            ax1.set_title('收敛曲线')
            ax1.grid(True, alpha=0.3)
            
            # 2. 温度控制效果
            ax2.plot(iterations, avg_temps, 'g-', linewidth=2, label='平均回水温度')
            ax2.axhline(y=45, color='r', linestyle='--', alpha=0.7, label='目标温度')
            ax2.fill_between(iterations, [43]*len(iterations), [47]*len(iterations), 
                           alpha=0.2, color='green')
            ax2.set_xlabel('迭代次数')
            ax2.set_ylabel('温度 (°C)')
            ax2.set_title('温度控制效果')
            ax2.legend()
            ax2.grid(True, alpha=0.3)
            
            # 3. 温度一致性
            ax3.plot(iterations, std_temps, 'orange', linewidth=2, marker='s', markersize=3)
            ax3.set_xlabel('迭代次数')
            ax3.set_ylabel('温度标准差 (°C)')
            ax3.set_title('温度一致性')
            ax3.grid(True, alpha=0.3)
            
            # 4. 阀门开度变化
            ax4.plot(iterations, avg_openings, 'purple', linewidth=2, marker='^', markersize=3)
            ax4.axhline(y=0.75, color='r', linestyle='--', alpha=0.7, label='理想开度')
            ax4.set_xlabel('迭代次数')
            ax4.set_ylabel('平均阀门开度')
            ax4.set_title('阀门开度变化')
            ax4.legend()
            ax4.grid(True, alpha=0.3)
            
            # 添加总体标题
            fig.suptitle('强化学习控制性能仪表板', fontsize=16, fontweight='bold')
            
            # 添加总体统计信息
            stats_text = f"""控制结果汇总:
总迭代: {len(iterations)}
收敛状态: {'已收敛' if result_data.get('converged', False) else '未收敛'}
最佳性能: {min(performances):.4f}
最终温度: {avg_temps[-1]:.2f}°C
温度偏差: {abs(avg_temps[-1] - 45):.2f}°C
最终一致性: {std_temps[-1]:.2f}°C"""
            
            fig.text(0.02, 0.02, stats_text, fontsize=10, 
                    bbox=dict(boxstyle='round', facecolor='lightgray', alpha=0.8))
            
            plt.tight_layout()
            plt.subplots_adjust(bottom=0.15)  # 为统计信息留出空间
            
            # 保存图片
            if save_path is None:
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                save_path = self.output_dir / f'performance_dashboard_{timestamp}.png'
            
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            plt.close()
            
            self.logger.info(f"性能仪表板已保存: {save_path}")
            return save_path
            
        except Exception as e:
            self.logger.error(f"绘制性能仪表板失败: {e}")
            raise
    
    def plot_valve_distribution(self, final_valve_openings: List[float], 
                               save_path: Optional[Path] = None) -> Path:
        """
        绘制最终阀门开度分布
        
        Args:
            final_valve_openings: 最终阀门开度列表
            save_path: 保存路径（可选）
            
        Returns:
            Path: 图片保存路径
        """
        try:
            if not final_valve_openings:
                raise ValueError("无阀门开度数据")
            
            # 创建图形
            fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
            
            # 1. 柱状图
            valve_numbers = [f'阀门{i+1}' for i in range(len(final_valve_openings))]
            bars = ax1.bar(range(len(final_valve_openings)), final_valve_openings, 
                          color='skyblue', edgecolor='navy', alpha=0.7)
            
            # 添加数值标签
            for i, bar in enumerate(bars):
                height = bar.get_height()
                ax1.text(bar.get_x() + bar.get_width()/2., height + 0.01,
                        f'{height:.3f}', ha='center', va='bottom', fontsize=8)
            
            ax1.set_xlabel('阀门编号')
            ax1.set_ylabel('开度')
            ax1.set_title('最终阀门开度分布')
            ax1.set_xticks(range(0, len(final_valve_openings), max(1, len(final_valve_openings)//10)))
            ax1.set_xticklabels([valve_numbers[i] for i in range(0, len(final_valve_openings), max(1, len(final_valve_openings)//10))], rotation=45)
            ax1.grid(True, alpha=0.3)
            
            # 2. 直方图
            ax2.hist(final_valve_openings, bins=20, color='lightgreen', edgecolor='darkgreen', alpha=0.7)
            ax2.axvline(np.mean(final_valve_openings), color='red', linestyle='--', 
                       label=f'平均值: {np.mean(final_valve_openings):.3f}')
            ax2.axvline(np.median(final_valve_openings), color='blue', linestyle='--', 
                       label=f'中位数: {np.median(final_valve_openings):.3f}')
            
            ax2.set_xlabel('阀门开度')
            ax2.set_ylabel('频次')
            ax2.set_title('阀门开度分布直方图')
            ax2.legend()
            ax2.grid(True, alpha=0.3)
            
            # 添加统计信息
            stats_text = f"""统计信息:
平均值: {np.mean(final_valve_openings):.3f}
标准差: {np.std(final_valve_openings):.3f}
最小值: {np.min(final_valve_openings):.3f}
最大值: {np.max(final_valve_openings):.3f}
范围: {np.max(final_valve_openings) - np.min(final_valve_openings):.3f}"""
            
            ax1.text(0.02, 0.98, stats_text, transform=ax1.transAxes, fontsize=10, 
                    verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
            
            plt.tight_layout()
            
            # 保存图片
            if save_path is None:
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                save_path = self.output_dir / f'valve_distribution_{timestamp}.png'
            
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            plt.close()
            
            self.logger.info(f"阀门分布图已保存: {save_path}")
            return save_path
            
        except Exception as e:
            self.logger.error(f"绘制阀门分布图失败: {e}")
            raise
    
    def generate_all_plots(self, result_data: Dict[str, Any]) -> Dict[str, Path]:
        """
        生成所有图表
        
        Args:
            result_data: 结果数据
            
        Returns:
            Dict[str, Path]: 图表文件路径字典
        """
        try:
            plots = {}
            
            if 'iteration_history' in result_data and result_data['iteration_history']:
                # 收敛曲线
                plots['convergence'] = self.plot_convergence_curve(result_data['iteration_history'])
                
                # 温度趋势
                plots['temperature'] = self.plot_temperature_trends(result_data['iteration_history'])
                
                # 阀门开度
                plots['valve_openings'] = self.plot_valve_openings(result_data['iteration_history'])
                
                # 性能仪表板
                plots['dashboard'] = self.plot_performance_dashboard(result_data)
            
            # 阀门分布
            if 'best_valve_openings' in result_data and result_data['best_valve_openings']:
                plots['valve_distribution'] = self.plot_valve_distribution(result_data['best_valve_openings'])
            
            self.logger.info(f"已生成{len(plots)}个图表")
            return plots
            
        except Exception as e:
            self.logger.error(f"生成图表失败: {e}")
            return {}