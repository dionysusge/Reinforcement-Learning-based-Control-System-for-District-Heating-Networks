#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Dymola仿真接口
作者: Dionysus

提供与Dymola的交互功能，包括模型加载、参数修改和仿真运行
"""

import os
import re
import shutil
import subprocess
import time
import logging
import pandas as pd
import numpy as np
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any

try:
    from dymola.dymola_interface import DymolaInterface as DymolaLib
except ImportError:
    print("警告: 无法导入DymolaInterface，请确保已安装Dymola")
    DymolaLib = None

class DymolaInterface:
    """
    Dymola仿真接口类
    
    负责修改mo文件参数、运行仿真并提取结果
    """
    
    def __init__(self, config: Dict[str, Any]):
        """
        初始化Dymola接口
        
        Args:
            config: Dymola配置字典
        """
        self.config = config
        self.logger = logging.getLogger(__name__)
        
        # 文件路径
        self.model_file = Path(config['model_file'])
        self.work_dir = self.model_file.parent
        
        # 仿真参数
        self.simulation_time = config['simulation_time']
        self.time_step = config['time_step']
        self.output_interval = config['output_interval']
        self.tolerance = config['tolerance']
        
        # 结果文件
        self.result_file = self.work_dir / 'dsres.mat'
        self.log_file = self.work_dir / 'dslog.txt'
        
        # 楼栋配置
        self.active_buildings = [i for i in range(1, 28) if i not in [8, 14, 15, 16]]
        
        # 初始化Dymola连接
        self.dymola = None
        self._initialize_dymola()
        
        self.logger.info(f"Dymola接口初始化完成，工作目录: {self.work_dir}")
    
    def _initialize_dymola(self):
        """
        初始化Dymola连接
        """
        try:
            if DymolaLib is None:
                raise ImportError("DymolaInterface未安装")

            self.dymola = DymolaLib()

            # 设置工作目录
            self.dymola.cd(str(self.work_dir).replace('\\', '/'))

            # 加载模型
            if not self.dymola.openModel(str(self.model_file).replace('\\', '/')):
                error_log = self.dymola.getLastErrorLog()
                raise Exception(f"模型加载失败: {error_log}")

            self.logger.info(f"Dymola初始化成功，模型已加载: {self.model_file}")

        except Exception as e:
            self.logger.error(f"Dymola初始化失败: {e}")
            if self.dymola:
                try:
                    self.dymola.close()
                except:
                    pass
                self.dymola = None
            raise
    
    def backup_original_model(self) -> bool:
        """
        备份原始模型文件
        
        Returns:
            bool: 是否备份成功
        """
        try:
            backup_file = self.model_file.with_suffix('.mo.backup')
            if not backup_file.exists():
                shutil.copy2(self.model_file, backup_file)
                self.logger.info(f"已备份原始模型文件: {backup_file}")
            return True
        except Exception as e:
            self.logger.error(f"备份模型文件失败: {e}")
            return False
    
    def modify_valve_openings(self, valve_openings: np.ndarray) -> bool:
        """
        修改mo文件中的阀门开度参数
        
        Args:
            valve_openings: 阀门开度数组，长度为23
            
        Returns:
            bool: 是否修改成功
        """
        try:
            if len(valve_openings) != len(self.active_buildings):
                self.logger.error(f"阀门开度数组长度不匹配: {len(valve_openings)} vs {len(self.active_buildings)}")
                return False
            
            # 读取模型文件
            with open(self.model_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 修改每个活跃楼栋的阀门开度
            modified_content = content
            for i, building_num in enumerate(self.active_buildings):
                valve_opening = float(valve_openings[i])
                
                # 确保阀门开度在有效范围内
                valve_opening = max(0.5, min(1.0, valve_opening))
                
                # 构建参数名模式
                param_pattern = f'valve{building_num}\\.opening'
                
                # 查找并替换参数值
                pattern = rf'({param_pattern}\s*=\s*)([0-9]*\.?[0-9]+)'
                replacement = rf'\g<1>{valve_opening:.6f}'
                
                new_content = re.sub(pattern, replacement, modified_content)
                
                if new_content != modified_content:
                    modified_content = new_content
                    self.logger.debug(f"已修改楼栋{building_num}阀门开度: {valve_opening:.6f}")
                else:
                    self.logger.warning(f"未找到楼栋{building_num}的阀门开度参数")
            
            # 写回文件
            with open(self.model_file, 'w', encoding='utf-8') as f:
                f.write(modified_content)
            
            self.logger.info(f"成功修改{len(self.active_buildings)}个阀门开度参数")
            return True
            
        except Exception as e:
            self.logger.error(f"修改阀门开度失败: {e}")
            return False
    

    
    def run_simulation(self) -> bool:
        """
        运行Dymola仿真
        
        Returns:
            bool: 仿真是否成功
        """
        try:
            # 检查Dymola连接
            if self.dymola is None:
                self.logger.error("Dymola未初始化")
                return False
            
            # 清理之前的结果文件
            if self.result_file.exists():
                self.result_file.unlink()
            if self.log_file.exists():
                self.log_file.unlink()
            
            self.logger.info("开始运行Dymola仿真...")
            start_time = time.time()
            
            # 设置仿真参数
            self.dymola.experimentSetupOutput(events=False)
            
            # 运行仿真
            result = self.dymola.simulateExtendedModel(
                problem="HeatingNetwork",
                startTime=0,
                stopTime=self.simulation_time,
                numberOfIntervals=int(self.simulation_time / self.output_interval),
                tolerance=self.tolerance,
                method="Dassl",
                resultFile=str(self.result_file).replace('\\', '/')
            )
            
            end_time = time.time()
            simulation_duration = end_time - start_time
            
            if result:
                self.logger.info(f"仿真完成，耗时: {simulation_duration:.2f}秒")
                
                # 检查结果文件是否生成
                if self.result_file.exists():
                    self.logger.info(f"仿真结果文件已生成: {self.result_file}")
                    return True
                else:
                    self.logger.error("仿真结果文件未生成")
                    return False
            else:
                error_log = self.dymola.getLastErrorLog()
                self.logger.error(f"仿真失败: {error_log}")
                return False
                
        except Exception as e:
            self.logger.error(f"运行仿真失败: {e}")
            return False
    
    def extract_simulation_results(self) -> Optional[Dict[str, Any]]:
        """
        提取仿真结果
        
        Returns:
            Optional[Dict[str, Any]]: 仿真结果字典，包含温度、流量等数据
        """
        try:
            if not self.result_file.exists():
                self.logger.error(f"结果文件不存在: {self.result_file}")
                return None
            
            # 使用scipy读取MAT文件
            try:
                from scipy.io import loadmat
                mat_data = loadmat(str(self.result_file))
            except ImportError:
                self.logger.error("需要安装scipy来读取MAT文件")
                return None
            
            # 提取时间序列
            time_data = mat_data.get('time', [])
            if len(time_data) == 0:
                self.logger.error("未找到时间数据")
                return None
            
            results = {
                'time': time_data.flatten(),
                'return_temperatures': {},
                'supply_temperatures': {},
                'flow_rates': {},
                'valve_openings': {},
                'summary': {}
            }
            
            # 提取各楼栋的数据
            for building_num in self.active_buildings:
                # 回水温度
                return_temp_key = f'building{building_num}.returnTemperature'
                if return_temp_key in mat_data:
                    results['return_temperatures'][building_num] = mat_data[return_temp_key].flatten()
                
                # 供水温度
                supply_temp_key = f'building{building_num}.supplyTemperature'
                if supply_temp_key in mat_data:
                    results['supply_temperatures'][building_num] = mat_data[supply_temp_key].flatten()
                
                # 流量
                flow_key = f'building{building_num}.flowRate'
                if flow_key in mat_data:
                    results['flow_rates'][building_num] = mat_data[flow_key].flatten()
                
                # 阀门开度
                valve_key = f'valve{building_num}.opening'
                if valve_key in mat_data:
                    results['valve_openings'][building_num] = mat_data[valve_key].flatten()
            
            # 计算汇总统计
            self._calculate_summary_statistics(results)
            
            self.logger.info("成功提取仿真结果")
            return results
            
        except Exception as e:
            self.logger.error(f"提取仿真结果失败: {e}")
            return None
    
    def _calculate_summary_statistics(self, results: Dict[str, Any]):
        """
        计算汇总统计信息
        
        Args:
            results: 结果字典
        """
        try:
            # 计算平均回水温度
            all_return_temps = []
            for temps in results['return_temperatures'].values():
                if len(temps) > 0:
                    all_return_temps.extend(temps[-10:])  # 取最后10个时间点
            
            if all_return_temps:
                results['summary']['avg_return_temperature'] = np.mean(all_return_temps)
                results['summary']['std_return_temperature'] = np.std(all_return_temps)
                results['summary']['min_return_temperature'] = np.min(all_return_temps)
                results['summary']['max_return_temperature'] = np.max(all_return_temps)
            
            # 计算平均供水温度
            all_supply_temps = []
            for temps in results['supply_temperatures'].values():
                if len(temps) > 0:
                    all_supply_temps.extend(temps[-10:])
            
            if all_supply_temps:
                results['summary']['avg_supply_temperature'] = np.mean(all_supply_temps)
                results['summary']['std_supply_temperature'] = np.std(all_supply_temps)
            
            # 计算总流量
            all_flows = []
            for flows in results['flow_rates'].values():
                if len(flows) > 0:
                    all_flows.extend(flows[-10:])
            
            if all_flows:
                results['summary']['total_flow_rate'] = np.sum(all_flows)
                results['summary']['avg_flow_rate'] = np.mean(all_flows)
            
            # 计算平均阀门开度
            all_openings = []
            for openings in results['valve_openings'].values():
                if len(openings) > 0:
                    all_openings.append(openings[-1])  # 取最终值
            
            if all_openings:
                results['summary']['avg_valve_opening'] = np.mean(all_openings)
                results['summary']['min_valve_opening'] = np.min(all_openings)
                results['summary']['max_valve_opening'] = np.max(all_openings)
            
            # 仿真时长
            if len(results['time']) > 0:
                results['summary']['simulation_duration'] = results['time'][-1] - results['time'][0]
                results['summary']['time_points'] = len(results['time'])
            
        except Exception as e:
            self.logger.error(f"计算汇总统计失败: {e}")
    
    def get_current_state(self, results: Dict[str, Any]) -> Optional[np.ndarray]:
        """
        从仿真结果中提取当前状态向量
        
        Args:
            results: 仿真结果字典
            
        Returns:
            Optional[np.ndarray]: 状态向量 (23个楼栋 * 4个变量)
        """
        try:
            state_vector = []
            
            for building_num in self.active_buildings:
                # 流量 (kg/s)
                flow_rate = 0.0
                if building_num in results['flow_rates'] and len(results['flow_rates'][building_num]) > 0:
                    flow_rate = results['flow_rates'][building_num][-1]
                
                # 压力 (Pa) - 如果没有压力数据，使用流量的函数
                pressure = flow_rate * 1000  # 简化的压力估算
                
                # 供水温度 (°C)
                supply_temp = 70.0  # 默认供水温度
                if building_num in results['supply_temperatures'] and len(results['supply_temperatures'][building_num]) > 0:
                    supply_temp = results['supply_temperatures'][building_num][-1]
                
                # 回水温度 (°C)
                return_temp = 45.0  # 默认回水温度
                if building_num in results['return_temperatures'] and len(results['return_temperatures'][building_num]) > 0:
                    return_temp = results['return_temperatures'][building_num][-1]
                
                # 添加到状态向量
                state_vector.extend([flow_rate, pressure, supply_temp, return_temp])
            
            return np.array(state_vector, dtype=np.float32)
            
        except Exception as e:
            self.logger.error(f"提取状态向量失败: {e}")
            return None
    
    def cleanup_files(self):
        """
        清理临时文件
        """
        try:
            temp_files = [
                self.work_dir / 'simulation_script.mos',
                self.work_dir / 'dsin.txt',
                self.work_dir / 'dsfinal.txt',
                self.work_dir / 'dsmodel.c'
            ]
            
            for file_path in temp_files:
                if file_path.exists():
                    file_path.unlink()
                    self.logger.debug(f"已删除临时文件: {file_path}")
                    
        except Exception as e:
            self.logger.warning(f"清理临时文件失败: {e}")
    
    def validate_simulation_setup(self) -> bool:
        """
        验证仿真设置
        
        Returns:
            bool: 设置是否有效
        """
        # 检查模型文件
        if not self.model_file.exists():
            self.logger.error(f"模型文件不存在: {self.model_file}")
            return False
        
        # 检查Dymola连接
        if self.dymola is None:
            self.logger.error("Dymola未初始化")
            return False
        
        # 检查工作目录权限
        if not os.access(self.work_dir, os.W_OK):
            self.logger.error(f"工作目录无写权限: {self.work_dir}")
            return False
        
        return True
    
    def close(self):
        """
        关闭Dymola连接
        """
        if self.dymola:
            try:
                self.dymola.close()
                self.logger.info("Dymola连接已关闭")
            except Exception as e:
                self.logger.error(f"关闭Dymola连接失败: {e}")
            finally:
                self.dymola = None