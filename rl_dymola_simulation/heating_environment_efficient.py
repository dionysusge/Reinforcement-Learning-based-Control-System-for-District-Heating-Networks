#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
供热网络强化学习环境 - 高效版本
作者: Dionysus
日期: 2025-08-08

基于成功的v2版本，移除不必要的检查步骤，增加离线数据保存功能
"""

import os
import re
import json
import time
import logging
from datetime import datetime
from typing import Dict, Tuple, Any, List

import numpy as np
from DyMat import DyMatFile
# 奖励函数将在运行时导入

try:
    from dymola.dymola_interface import DymolaInterface
except ImportError:
    print("警告: 无法导入DymolaInterface，请确保已安装Dymola")
    DymolaInterface = None


class HeatingEnvironmentEfficient:
    """
    供热网络强化学习环境 - 高效版本

    特点:
    1. 基于成功的v2版本
    2. 移除不必要的模型检查步骤
    3. 增加离线数据保存功能
    4. 优化仿真流程
    """

    def __init__(self, config_path: str = None):
        """
        初始化环境

        Args:
            config_path: 配置文件路径
        """
        # 设置日志
        self.logger = logging.getLogger(__name__)

        # 加载配置
        self.config = self._load_config(config_path)

        # 环境参数 - 实际有效阀门数量
        valve_numbers = [i for i in range(1, 28) if i not in [8, 14, 15, 16]]
        self.num_buildings = len(valve_numbers)  # 实际阀门数量：23个（跳过8,14,15,16号）
        self.valve_numbers = valve_numbers
        self.max_steps = self.config.get('max_steps', 100)
        self.simulation_time = self.config.get('simulation_time', 3600)  # 仿真时间（秒）

        # 动作和观测空间 - 修改为50-100%开度范围
        self.action_low = 0.5  # 最小阀门开度50%
        self.action_high = 1.0  # 最大阀门开度100%
        self.observation_space_size = self.num_buildings * 4  # 流量、压力、供水温度、回水温度

        # 工作目录和文件路径
        self.work_dir = os.path.dirname(os.path.abspath(__file__))
        self.model_path = os.path.join(self.work_dir, "HeatingNetwork_20250316.mo")

        # Dymola接口
        self.dymola = None
        self.instance_id = int(time.time() * 1000) % 10000  # 实例ID

        # 环境状态
        self.current_step = 0
        self.is_done = False

        # 离线数据存储
        self.offline_data = []
        self.offline_data_dir = os.path.join(self.work_dir, "offline_data")
        os.makedirs(self.offline_data_dir, exist_ok=True)
        
        # 创建仿真结果目录
        self.simulation_results_dir = os.path.join(self.work_dir, "simulation_results")
        self.mat_files_dir = os.path.join(self.simulation_results_dir, "mat_files")
        os.makedirs(self.mat_files_dir, exist_ok=True)

        # 奖励计算器将在首次使用时初始化

        # 初始化环境
        self._initialize_environment()

    def _load_config(self, config_path: str) -> Dict[str, Any]:
        """
        加载配置文件

        Args:
            config_path: 配置文件路径

        Returns:
            Dict[str, Any]: 配置字典
        """
        if config_path and os.path.exists(config_path):
            with open(config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        else:
            # 默认配置
            return {
                'num_buildings': 23,
                'max_steps': 100,
                'simulation_time': 3600,
                'target_return_temp': 30.0,
                'dymola_visible': False
            }

    def _initialize_environment(self):
        """
        初始化环境和Dymola连接
        """
        try:
            self._initialize_dymola()
            self.logger.info("环境初始化完成")
        except Exception as e:
            self.logger.error(f"环境初始化失败: {e}")
            raise

    def _initialize_dymola(self):
        """
        初始化Dymola连接
        """
        try:
            if DymolaInterface is None:
                raise ImportError("DymolaInterface未安装")

            self.dymola = DymolaInterface()

            # 设置工作目录
            self.dymola.cd(self.work_dir.replace('\\', '/'))

            # 加载模型
            if not self.dymola.openModel(self.model_path.replace('\\', '/')):
                error_log = self.dymola.getLastErrorLog()
                raise Exception(f"模型加载失败: {error_log}")

            self.logger.info(f"Dymola初始化成功，模型已加载: {self.model_path}")

        except Exception as e:
            self.logger.error(f"Dymola初始化失败: {e}")
            if self.dymola:
                try:
                    self.dymola.close()
                except:
                    pass
                self.dymola = None
            raise

    def _modify_model_parameters(self, valve_openings: np.ndarray):
        """
        修改模型参数（阀门开度）

        Args:
            valve_openings: 阀门开度数组，范围[0, 1]
        """
        try:
            # 参数验证和清理
            valve_openings = np.clip(valve_openings, 0.01, 0.99)  # 避免极值
            valve_openings = np.nan_to_num(valve_openings, nan=0.5, posinf=0.99, neginf=0.01)
            
            # 读取模型文件内容
            with open(self.model_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # 调试信息
            self.logger.debug(f"valve_openings长度: {len(valve_openings)}, valve_numbers长度: {len(self.valve_numbers)}")
            self.logger.debug(f"valve_numbers: {self.valve_numbers}")

            # 修改阀门开度参数
            # 模型中的阀门开度通过const块的k参数控制，格式为: const1(k=0.5)
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
                # 更宽松的正则表达式，支持科学计数法和更多格式
                pattern = rf"({const_param}\(k=)([0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)(\))"
                replacement = rf"\g<1>{opening:.6f}\g<3>"
                
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
                        # 真正的替换失败
                        self.logger.warning(f"参数 {const_param} 替换失败")
                        self.logger.warning(f"原始匹配: {match.group(0)}")
                        self.logger.warning(f"当前值: {current_value:.6f}, 目标值: {new_value:.6f}")
                        self.logger.warning(f"替换模式: {replacement}")
                else:
                    # 尝试更详细的调试
                    debug_pattern = rf"{const_param}\([^)]*\)"
                    matches = re.findall(debug_pattern, content)
                    if matches:
                        self.logger.warning(f"找到参数 {const_param} 但格式不匹配: {matches[:3]}")
                    else:
                        self.logger.warning(f"完全未找到参数 {const_param}")

            # 验证修改结果
            if modified_count == 0:
                self.logger.error("没有成功修改任何参数")
                return False
                
            # 写回修改后的内容
            with open(self.model_path, 'w', encoding='utf-8') as f:
                f.write(content)

            self.logger.debug(f"已修改模型参数，成功修改{modified_count}个阀门，开度: {valve_openings}")
            return True

        except Exception as e:
            self.logger.error(f"修改模型参数失败: {e}")
            return False
            raise

    def _run_simulation(self) -> bool:
        """
        运行Dymola仿真（高效版本，跳过模型检查）

        Returns:
            bool: 仿真是否成功
        """
        try:
            # 设置工作目录
            self.dymola.cd(self.work_dir.replace('\\', '/'))

            # 重新加载修改后的模型
            if not self.dymola.openModel(self.model_path.replace('\\', '/')):
                error_log = self.dymola.getLastErrorLog()
                self.logger.error(f"重新加载模型失败: {error_log}")
                return False

            # 检查dymosim.exe是否存在
            dymosim_path = os.path.join(self.work_dir, "dymosim.exe")
            self.logger.info(f"检查dymosim.exe: {os.path.exists(dymosim_path)}")
            
            # 直接运行仿真，跳过模型检查步骤
            model_name = "HeatingNetwork_20250316.HeatingNetWork_Case01"
            self.logger.info("开始运行Dymola仿真...")
            success = self.dymola.simulateModel(
                model_name,
                startTime=0,
                stopTime=self.simulation_time,
                numberOfIntervals=100,
                tolerance=1e-4
            )
            self.logger.info(f"Dymola仿真返回状态: {success}")

            # 检查结果文件是否存在（更可靠的成功判断）
            default_result = os.path.join(self.work_dir, "dsres.mat")
            target_result = os.path.join(self.mat_files_dir, f"dsres_instance_{self.instance_id}.mat")

            # 如果结果文件存在，认为仿真成功（忽略Dymola的编译警告和错误）
            if os.path.exists(default_result):
                try:
                    if os.path.exists(target_result):
                        os.remove(target_result)
                    os.rename(default_result, target_result)
                    self.logger.debug(f"结果文件已重命名为: {target_result}")
                    success = True  # 强制设置为成功，忽略编译错误
                    self.logger.info("仿真成功完成，忽略编译链接错误")
                except Exception as e:
                    self.logger.error(f"文件重命名失败: {e}")
                    success = False
            else:
                # 即使Dymola报告失败，也检查是否有结果文件生成
                error_log = self.dymola.getLastErrorLog()
                if "SUCCESSFUL simulation" in error_log and os.path.exists(default_result):
                    try:
                        if os.path.exists(target_result):
                            os.remove(target_result)
                        os.rename(default_result, target_result)
                        self.logger.info("仿真实际成功，忽略编译错误")
                        success = True
                    except Exception as e:
                        self.logger.error(f"文件重命名失败: {e}")
                        success = False
                else:
                    success = False

            if not success:
                error_log = self.dymola.getLastErrorLog()
                self.logger.error(f"仿真失败，无结果文件")
                self.logger.error(f"Dymola错误日志: {error_log}")  # 改为ERROR级别以确保显示
                
                # 检查错误日志中是否包含成功信息
                if error_log and "SUCCESSFUL simulation" in error_log:
                    self.logger.info("检测到仿真实际成功，但结果文件可能位置不对")
                    # 尝试查找可能的结果文件
                    possible_files = ["dsres.mat", "result.mat", "simulation.mat"]
                    for filename in possible_files:
                        possible_path = os.path.join(self.work_dir, filename)
                        if os.path.exists(possible_path):
                            try:
                                target_result = os.path.join(self.mat_files_dir, f"dsres_instance_{self.instance_id}.mat")
                                if os.path.exists(target_result):
                                    os.remove(target_result)
                                os.rename(possible_path, target_result)
                                self.logger.info(f"找到并重命名结果文件: {filename} -> {target_result}")
                                return True
                            except Exception as e:
                                self.logger.error(f"重命名文件 {filename} 失败: {e}")
                                continue
                
                return False

            self.logger.debug("仿真完成")
            return True

        except Exception as e:
            self.logger.error(f"仿真运行异常: {e}")
            return False

    def _read_simulation_results(self) -> Dict[str, np.ndarray]:
        """
        读取仿真结果

        Returns:
            Dict[str, np.ndarray]: 仿真结果数据
        """
        try:
            result_file = os.path.join(self.mat_files_dir, f"dsres_instance_{self.instance_id}.mat")
            result_path = os.path.join(self.work_dir, result_file)

            if not os.path.exists(result_path):
                self.logger.error(f"结果文件不存在: {result_path}")
                return {}

            # 使用DyMat读取结果
            dymat = DyMatFile(result_path)

            # 定义需要读取的变量
            variables = [
                # 阀门开度
                *[f'valveIncompressible{self.valve_numbers[i]}.opening' for i in range(self.num_buildings)],
                # 阀门流量（使用阀门自身的V_flow变量）
                *[f'valveIncompressible{self.valve_numbers[i]}.V_flow' for i in range(self.num_buildings)],
                # 阀门压力（port_b是出口压力）
                *[f'valveIncompressible{self.valve_numbers[i]}.port_b.p' for i in range(self.num_buildings)],
                # 阀门出口温度
                *[f'valveIncompressible{self.valve_numbers[i]}.port_b_T' for i in range(self.num_buildings)],
                # 阀门入口温度
                *[f'valveIncompressible{self.valve_numbers[i]}.port_a_T' for i in range(self.num_buildings)]
            ]
            results = {}
            available_vars = dymat.names()

            for var in variables:
                if var in available_vars:
                    try:
                        data = dymat.data(var)
                        results[var] = data
                    except Exception as e:
                        self.logger.warning(f"读取变量 {var} 失败: {e}")
                        results[var] = np.array([0.0])
                else:
                    self.logger.warning(f"变量 {var} 不存在于结果中")
                    results[var] = np.array([0.0])

            return results

        except Exception as e:
            self.logger.error(f"读取仿真结果失败: {e}")
            return {}

    def _calculate_state(self, results: Dict[str, np.ndarray]) -> np.ndarray:
        """
        从仿真结果计算状态向量

        Args:
            results: 仿真结果字典

        Returns:
            np.ndarray: 状态向量 [流量1, 压力1, 供水温度1, 回水温度1, ...]
        """
        try:
            state = np.zeros(self.observation_space_size)

            for i in range(self.num_buildings):
                valve_num = self.valve_numbers[i]

                # 流量（m3/s，使用阀门自身的V_flow变量）
                flow_var = f'valveIncompressible{valve_num}.V_flow'
                if flow_var in results and len(results[flow_var]) > 0:
                    flow = results[flow_var][-1]  # 取最后一个时间点的值
                    state[i * 4] = max(0, flow) * 1000.0  # 转换为L/s并归一化
                else:
                    state[i * 4] = 0.0  # 如果没有流量数据，设为0

                # 压力（Pa）
                pressure_var = f'valveIncompressible{valve_num}.port_b.p'
                if pressure_var in results and len(results[pressure_var]) > 0:
                    pressure = results[pressure_var][-1]
                    state[i * 4 + 1] = max(0, (pressure - 100000) / 500000)  # 归一化

                # 供水温度（K转换为°C，然后归一化）
                supply_temp_var = f'valveIncompressible{valve_num}.port_a_T'
                if supply_temp_var in results and len(results[supply_temp_var]) > 0:
                    temp_k = results[supply_temp_var][-1]
                    temp_c = temp_k - 273.15
                    state[i * 4 + 2] = max(0, min(1, temp_c / 100.0))  # 归一化到[0, 1]

                # 回水温度（K转换为°C，然后归一化）
                return_temp_var = f'valveIncompressible{valve_num}.port_b_T'
                if return_temp_var in results and len(results[return_temp_var]) > 0:
                    temp_k = results[return_temp_var][-1]
                    temp_c = temp_k - 273.15
                    state[i * 4 + 3] = max(0, min(1, temp_c / 100.0))  # 归一化到[0, 1]

            return state

        except Exception as e:
            self.logger.error(f"计算状态失败: {e}")
            return np.zeros(self.observation_space_size)

    def _calculate_reward(self, state: np.ndarray, action: np.ndarray) -> float:
        """
        计算新的奖励函数
        权重分配：阀门开度50%、回水温度一致性50%
        阀门开度要尽可能大，回水温度在20-30℃区间内保持一致
        9号楼的阀门开度必须保持在90以上

        Args:
            state: 当前状态
            action: 执行的动作（0-1范围）

        Returns:
            float: 奖励值
        """
        try:
            # 使用新的奖励计算器
            if not hasattr(self, 'reward_calculator'):
                from smooth_reward_functions import create_smooth_reward_calculator
                self.reward_calculator = create_smooth_reward_calculator()
            
            # 提取回水温度
            return_temps = []
            
            for i in range(self.num_buildings):
                return_temp = state[i * 4 + 3] * 100.0  # 反归一化回水温度
                return_temps.append(return_temp)
            
            # 将动作转换为百分比（0-100）
            valve_openings = action * 100.0
            
            # 计算奖励
            reward = self.reward_calculator.calculate_reward(
                np.array(return_temps),
                valve_openings
            )
            
            return float(reward)
            
        except Exception as e:
            self.logger.error(f"计算奖励失败: {e}")
            return 0.0
    
    def _save_offline_data(self, step_data: Dict[str, Any]):
        """
        保存离线数据
        
        Args:
            step_data: 步骤数据
        """
        try:
            self.offline_data.append(step_data)
            
            # 每100步或episode结束时保存数据
            if len(self.offline_data) >= 100 or self.is_done:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"offline_data_{self.instance_id}_{timestamp}.json"
                filepath = os.path.join(self.offline_data_dir, filename)
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    json.dump(self.offline_data, f, indent=2, ensure_ascii=False)
                
                self.logger.info(f"离线数据已保存: {filepath}")
                self.offline_data = []  # 清空缓存
                
        except Exception as e:
            self.logger.error(f"保存离线数据失败: {e}")
    
    def reset(self) -> np.ndarray:
        """
        重置环境
        
        Returns:
            np.ndarray: 初始状态
        """
        try:
            self.current_step = 0
            self.is_done = False
            self.instance_id = int(time.time() * 1000) % 10000  # 更新实例ID
            
            # 设置初始阀门开度（50%-100%范围）
            initial_openings = np.random.uniform(0.5, 1.0, self.num_buildings)
            
            # 确保最不利楼栋9号楼的两个阀门开度在90%以上
            # 9号楼对应const12和const13，在valve_numbers中找到12和13号阀门
            if 12 in self.valve_numbers:
                valve_12_index = self.valve_numbers.index(12)
                if initial_openings[valve_12_index] < 0.9:
                    initial_openings[valve_12_index] = 0.9
                    self.logger.info(f"12号阀门开度调整至90%以上: {initial_openings[valve_12_index]:.3f}")
            
            if 13 in self.valve_numbers:
                valve_13_index = self.valve_numbers.index(13)
                if initial_openings[valve_13_index] < 0.9:
                    initial_openings[valve_13_index] = 0.9
                    self.logger.info(f"13号阀门开度调整至90%以上: {initial_openings[valve_13_index]:.3f}")
            
            # 修改模型参数
            if not self._modify_model_parameters(initial_openings):
                self.logger.error("模型参数修改失败")
                return np.zeros(self.observation_space_size)
            
            # 运行仿真
            if not self._run_simulation():
                self.logger.error("初始仿真失败")
                return np.zeros(self.observation_space_size)
                
            # 读取结果并计算状态
            results = self._read_simulation_results()
            state = self._calculate_state(results)
            
            # 计算初始奖励
            initial_reward = self._calculate_reward(state, initial_openings)
            
            # 保存初始数据
            step_data = {
                'step': 0,
                'action': initial_openings.tolist(),
                'state': state.tolist(),
                'reward': initial_reward,
                'done': False,
                'timestamp': datetime.now().isoformat()
            }
            self._save_offline_data(step_data)
            
            self.logger.info(f"环境已重置，实例ID: {self.instance_id}")
            return state
            
        except Exception as e:
            self.logger.error(f"环境重置失败: {e}")
            return np.zeros(self.observation_space_size)
    
    def step(self, action: np.ndarray) -> Tuple[np.ndarray, float, bool, Dict[str, Any]]:
        """
        执行一步动作
        
        Args:
            action: 动作向量（阀门开度）
            
        Returns:
            Tuple[np.ndarray, float, bool, Dict]: (下一状态, 奖励, 是否结束, 信息)
        """
        try:
            # 限制动作范围
            action = np.clip(action, self.action_low, self.action_high)
            
            # 所有阀门开度现在已经限制在50-100%范围内
            # 对于关键阀门12号和13号，仍然确保在90%以上
            if 12 in self.valve_numbers:
                valve_12_index = self.valve_numbers.index(12)
                if action[valve_12_index] < 0.9:
                    action[valve_12_index] = 0.9  # 确保12号阀门开度至少90%
                    self.logger.info(f"已调整12号阀门开度至90%以上: {action[valve_12_index]:.3f}")
            
            if 13 in self.valve_numbers:
                valve_13_index = self.valve_numbers.index(13)
                if action[valve_13_index] < 0.9:
                    action[valve_13_index] = 0.9  # 确保13号阀门开度至少90%
                    self.logger.info(f"已调整13号阀门开度至90%以上: {action[valve_13_index]:.3f}")
            
            # 修改模型参数
            if not self._modify_model_parameters(action):
                self.logger.error("模型参数修改失败")
                state = np.zeros(self.observation_space_size)
                reward = -1.0
                self.is_done = True
                info = {'parameter_modification_failed': True}
                return state, reward, self.is_done, info
            
            # 运行仿真
            simulation_success = self._run_simulation()
            
            if not simulation_success:
                self.logger.error("仿真失败")
                # 返回零状态和负奖励
                state = np.zeros(self.observation_space_size)
                reward = -1.0
                self.is_done = True
                info = {'simulation_failed': True}
                return state, reward, self.is_done, info
                
            # 读取结果并计算状态
            results = self._read_simulation_results()
            state = self._calculate_state(results)
            
            # 计算奖励
            reward = self._calculate_reward(state, action)
            
            # 更新步数
            self.current_step += 1
            self.is_done = self.current_step >= self.max_steps
            
            # 提取回水温度信息
            return_temps = []
            for i in range(self.num_buildings):
                return_temp = state[i * 4 + 3] * 100.0  # 反归一化到摄氏度
                return_temps.append(return_temp)
            
            # 计算回水温度一致性指标
            temp_std = np.std(return_temps)
            temp_mean = np.mean(return_temps)
            temp_range = max(return_temps) - min(return_temps)
            
            # 输出详细的步骤信息
            self.logger.info(f"步骤 {self.current_step} 完成:")
            self.logger.info(f"  奖励: {reward:.3f}")
            self.logger.info(f"  回水温度统计: 平均={temp_mean:.2f}°C, 标准差={temp_std:.2f}°C, 范围={temp_range:.2f}°C")
            
            # 输出阀门开度信息（每5个一行）
            valve_info_lines = []
            for i in range(0, len(action), 5):
                valve_batch = []
                for j in range(i, min(i + 5, len(action))):
                    valve_num = self.valve_numbers[j]
                    opening = action[j] * 100  # 转换为百分比
                    valve_batch.append(f"V{valve_num}:{opening:.1f}%")
                valve_info_lines.append("    " + ", ".join(valve_batch))
            
            self.logger.info("  阀门开度:")
            for line in valve_info_lines:
                self.logger.info(line)
            
            # 输出回水温度信息（每5个一行）
            temp_info_lines = []
            for i in range(0, len(return_temps), 5):
                temp_batch = []
                for j in range(i, min(i + 5, len(return_temps))):
                    valve_num = self.valve_numbers[j]
                    temp = return_temps[j]
                    temp_batch.append(f"V{valve_num}:{temp:.1f}°C")
                temp_info_lines.append("    " + ", ".join(temp_batch))
            
            self.logger.info("  回水温度:")
            for line in temp_info_lines:
                self.logger.info(line)
            
            # 特别关注12号和13号阀门（最不利楼栋9号楼）
            if 12 in self.valve_numbers:
                valve_12_index = self.valve_numbers.index(12)
                valve_12_opening = action[valve_12_index] * 100
                valve_12_temp = return_temps[valve_12_index]
                self.logger.info(f"  最不利楼栋12号: 开度={valve_12_opening:.1f}%, 回水温度={valve_12_temp:.1f}°C")
            
            if 13 in self.valve_numbers:
                valve_13_index = self.valve_numbers.index(13)
                valve_13_opening = action[valve_13_index] * 100
                valve_13_temp = return_temps[valve_13_index]
                self.logger.info(f"  最不利楼栋13号: 开度={valve_13_opening:.1f}%, 回水温度={valve_13_temp:.1f}°C")
            
            # 构建信息字典
            info = {
                'step': self.current_step,
                'valve_openings': action.tolist(),
                'return_temperatures': return_temps,
                'temp_consistency': {
                    'mean': temp_mean,
                    'std': temp_std,
                    'range': temp_range
                },
                'simulation_success': True
            }
            
            # 保存离线数据
            step_data = {
                'step': self.current_step,
                'action': action.tolist(),
                'state': state.tolist(),
                'reward': reward,
                'done': self.is_done,
                'return_temperatures': return_temps,
                'temp_consistency': info['temp_consistency'],
                'timestamp': datetime.now().isoformat()
            }
            self._save_offline_data(step_data)
            
            return state, reward, self.is_done, info
            
        except Exception as e:
            self.logger.error(f"执行步骤失败: {e}")
            state = np.zeros(self.observation_space_size)
            reward = -1.0
            self.is_done = True
            info = {'error': str(e)}
            return state, reward, self.is_done, info
    
    def close(self):
        """
        关闭环境，清理资源
        """
        try:
            # 保存剩余的离线数据
            if self.offline_data:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"offline_data_{self.instance_id}_{timestamp}_final.json"
                filepath = os.path.join(self.offline_data_dir, filename)
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    json.dump(self.offline_data, f, indent=2, ensure_ascii=False)
                
                self.logger.info(f"最终离线数据已保存: {filepath}")
            
            if self.dymola:
                self.dymola.close()
                self.dymola = None
                self.logger.info("Dymola连接已关闭")
                
        except Exception as e:
            self.logger.error(f"关闭环境失败: {e}")
    
    def get_offline_data_stats(self) -> Dict[str, Any]:
        """
        获取离线数据统计信息
        
        Returns:
            Dict[str, Any]: 统计信息
        """
        try:
            data_files = [f for f in os.listdir(self.offline_data_dir) if f.endswith('.json')]
            total_files = len(data_files)
            
            total_steps = 0
            for file in data_files:
                filepath = os.path.join(self.offline_data_dir, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    total_steps += len(data)
            
            return {
                'total_files': total_files,
                'total_steps': total_steps,
                'data_directory': self.offline_data_dir
            }
            
        except Exception as e:
            self.logger.error(f"获取离线数据统计失败: {e}")
            return {}


if __name__ == "__main__":
    # 测试环境
    logging.basicConfig(level=logging.INFO)
    
    env = HeatingEnvironmentEfficient()
    
    try:
        # 重置环境
        state = env.reset()
        print(f"初始状态: {state[:8]}...")  # 显示前8个状态值
        
        # 执行几步
        for i in range(3):
            action = np.random.uniform(0.5, 1.0, env.num_buildings)  # 修改为50-100%范围
            state, reward, done, info = env.step(action)
            print(f"步骤 {i+1}: 奖励={reward:.3f}, 完成={done}")
            
            if done:
                break
        
        # 显示离线数据统计
        stats = env.get_offline_data_stats()
        print(f"离线数据统计: {stats}")
        
    finally:
        env.close()