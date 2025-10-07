#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
IQL-Dymola仿真控制循环主程序

功能: 基于根目录HeatingEnvironmentEfficient环境实现IQL强化学习的仿真控制循环
"""

import os
import sys
import time
import logging
import json
import signal
import numpy as np
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime

# 添加项目根目录到路径
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# 导入本地仿真环境
from heating_environment_efficient import HeatingEnvironmentEfficient

# 导入IQL相关模块
from reinforcement_learning.agents.iql_agent import IQLAgent
from reinforcement_learning.config.rl_config import RLConfig

# 导入本地模块
from core.rl_model_loader import RLModelLoader
from core.mo_file_handler import MoFileHandler


class IQLDymolaSimulationLoop:
    """
    IQL-Dymola仿真控制循环
    
    基于根目录HeatingEnvironmentEfficient环境实现的仿真控制循环
    """
    
    def __init__(self, config_path: str = None):
        """
        初始化仿真控制循环
        
        Args:
            config_path: 配置文件路径
        """
        # 先初始化基础配置以便日志设置
        if config_path is None:
            # 自动检测配置文件路径
            current_dir = Path(__file__).parent
            config_path = current_dir / 'config' / 'simulation_config.json'
        else:
            # 如果是相对路径，相对于当前模块目录
            config_path = Path(config_path)
            if not config_path.is_absolute():
                current_dir = Path(__file__).parent
                config_path = current_dir / config_path
        
        self.config = self._load_config(str(config_path))
        self.logger = self._setup_logging()
        
        # 控制标志
        self.running = False
        self.paused = False
        self.stop_requested = False
        
        # 仿真参数
        self.simulation_interval = self.config.get('simulation_interval', 5.0)  # 秒
        self.max_iterations = self.config.get('max_iterations', 100)
        self.current_iteration = 0
        
        # 初始化组件
        self._initialize_components()
        
        # 仿真结果存储
        self.simulation_results = []
        self.results_save_path = self.config.get('results_save_path', 'iql_simulation_results.json')
        
        # 性能监控
        self.performance_stats = {
            'total_iterations': 0,
            'successful_decisions': 0,
            'successful_simulations': 0,
            'total_simulation_time': 0.0,
            'avg_iteration_time': 0.0,
            'avg_reward': 0.0,
            'total_reward': 0.0
        }
        
        # 注册信号处理
        signal.signal(signal.SIGINT, self._signal_handler)
        signal.signal(signal.SIGTERM, self._signal_handler)
        
        self.logger.info("IQL-Dymola仿真控制循环初始化完成")
    
    def start_simulation_loop(self) -> None:
        """
        启动仿真控制循环
        """
        if self.running:
            self.logger.warning("仿真循环已在运行中")
            return
        
        self.logger.info("启动IQL-Dymola仿真控制循环")
        self.logger.info(f"仿真间隔: {self.simulation_interval}秒")
        self.logger.info(f"最大迭代次数: {self.max_iterations}")
        
        self.running = True
        self.stop_requested = False
        self.current_iteration = 0
        
        try:
            # 重置环境
            initial_state = self.env.reset()
            self.logger.info(f"环境重置完成，初始状态维度: {len(initial_state)}")
            
            # 执行主循环
            self._run_simulation_loop()
            
        except Exception as e:
            self.logger.error(f"仿真循环执行失败: {e}")
            import traceback
            self.logger.error(f"详细错误: {traceback.format_exc()}")
        finally:
            self._cleanup()
    
    def stop_simulation_loop(self) -> None:
        """
        停止仿真循环
        """
        self.logger.info("请求停止仿真循环")
        self.stop_requested = True
        self.running = False
    
    def pause_simulation_loop(self) -> None:
        """
        暂停仿真循环
        """
        self.logger.info("暂停仿真循环")
        self.paused = True
    
    def resume_simulation_loop(self) -> None:
        """
        恢复仿真循环
        """
        self.logger.info("恢复仿真循环")
        self.paused = False
    
    def get_simulation_status(self) -> Dict[str, Any]:
        """
        获取仿真状态信息
        
        Returns:
            Dict[str, Any]: 状态信息
        """
        return {
            'running': self.running,
            'paused': self.paused,
            'current_iteration': self.current_iteration,
            'max_iterations': self.max_iterations,
            'progress': self.current_iteration / self.max_iterations if self.max_iterations > 0 else 0,
            'performance_stats': self.performance_stats.copy()
        }
    
    def _run_simulation_loop(self) -> None:
        """
        执行主仿真循环
        """
        start_time = time.time()
        current_state = self.env.reset()
        
        self.logger.info(f"开始仿真循环 - running: {self.running}, stop_requested: {self.stop_requested}, current_iteration: {self.current_iteration}, max_iterations: {self.max_iterations}")
        
        while (self.running and 
               not self.stop_requested and 
               self.current_iteration < self.max_iterations):
            
            self.logger.info(f"进入循环迭代 {self.current_iteration + 1}/{self.max_iterations}")
            
            # 检查暂停状态
            while self.paused and not self.stop_requested:
                time.sleep(0.1)
            
            if self.stop_requested:
                self.logger.info("检测到停止请求，退出循环")
                break
            
            iteration_start_time = time.time()
            
            try:
                # 执行单次仿真迭代
                iteration_result, current_state = self._execute_simulation_iteration(current_state)
                
                # 记录结果
                self.simulation_results.append(iteration_result)
                
                # 更新性能统计
                self._update_performance_stats(iteration_result, iteration_start_time)
                
                # 日志输出
                self._log_iteration_result(iteration_result)
                
                # 保存中间结果（每10次迭代）
                if self.current_iteration % 10 == 0:
                    self._save_intermediate_results()
                
            except Exception as e:
                self.logger.error(f"第 {self.current_iteration + 1} 次迭代失败: {e}")
                import traceback
                self.logger.error(f"详细错误: {traceback.format_exc()}")
                
                # 记录错误但继续执行
                error_result = {
                    'iteration': self.current_iteration + 1,
                    'timestamp': time.time(),
                    'success': False,
                    'error': str(e)
                }
                self.simulation_results.append(error_result)
            
            self.current_iteration += 1
            self.logger.info(f"迭代 {self.current_iteration} 完成")
            
            # 等待下一次迭代
            if not self.stop_requested and self.current_iteration < self.max_iterations:
                self.logger.debug(f"等待下一次迭代，当前: {self.current_iteration}, 最大: {self.max_iterations}")
                self._wait_for_next_iteration(iteration_start_time)
            else:
                self.logger.info(f"循环结束条件满足 - stop_requested: {self.stop_requested}, current_iteration: {self.current_iteration}, max_iterations: {self.max_iterations}")
        
        # 仿真循环结束
        total_time = time.time() - start_time
        self.logger.info(f"仿真循环结束，总耗时: {total_time:.2f}秒")
        self.logger.info(f"完成迭代: {self.current_iteration}/{self.max_iterations}")
        self.logger.info(f"最终状态 - running: {self.running}, stop_requested: {self.stop_requested}")
        
        # 保存最终结果
        self._save_final_results()
    
    def _execute_simulation_iteration(self, current_state: np.ndarray) -> Tuple[Dict[str, Any], np.ndarray]:
        """
        执行单次仿真迭代
        
        Args:
            current_state: 当前环境状态
            
        Returns:
            Tuple[Dict[str, Any], np.ndarray]: (迭代结果, 新状态)
        """
        iteration_result = {
            'iteration': self.current_iteration + 1,
            'timestamp': time.time(),
            'success': False
        }
        
        try:
            # 记录当前状态
            iteration_result['current_state'] = current_state.tolist()
            
            # 每次迭代开始时，随机提高阀门开度0.2-0.3，如果提高后不足0.5则强制设为0.5
            self._initialize_valve_openings_for_iteration()
            
            # 进行第一次仿真，获取回水温度
            first_simulation_state = self._run_first_simulation()
            if first_simulation_state is None:
                raise Exception("第一次仿真失败")
            
            # IQL智能体基于第一次仿真结果决策
            action, matched_reward, matched_distance = self.model_loader.get_action(
                state=first_simulation_state,
                deterministic=True
            )
            
            iteration_result['action'] = action.tolist()
            iteration_result['matched_reward'] = matched_reward
            iteration_result['matched_distance'] = matched_distance
            iteration_result['first_simulation_state'] = first_simulation_state.tolist()
            
            # 根据智能体输出的动作调整mo文件，进行第二次仿真
            next_state, reward, done, info = self.env.step(action)
            
            iteration_result['next_state'] = next_state.tolist()
            iteration_result['reward'] = float(reward)
            iteration_result['done'] = bool(done)
            iteration_result['info'] = info
            iteration_result['success'] = True
            
            # 如果episode结束，重置环境
            if done:
                self.logger.info(f"Episode结束，重置环境。奖励: {reward:.3f}")
                next_state = self.env.reset()
                iteration_result['reset'] = True
            
            return iteration_result, next_state
            
        except Exception as e:
            iteration_result['error'] = str(e)
            self.logger.error(f"仿真迭代执行失败: {e}")
            return iteration_result, current_state
    
    def _wait_for_next_iteration(self, iteration_start_time: float) -> None:
        """
        等待下一次迭代
        
        Args:
            iteration_start_time: 当前迭代开始时间
        """
        elapsed_time = time.time() - iteration_start_time
        sleep_time = max(0, self.simulation_interval - elapsed_time)
        
        if sleep_time > 0:
            self.logger.debug(f"等待 {sleep_time:.2f} 秒进行下一次迭代")
            time.sleep(sleep_time)
    
    def _update_performance_stats(self, iteration_result: Dict[str, Any], iteration_start_time: float) -> None:
        """
        更新性能统计信息
        
        Args:
            iteration_result: 迭代结果
            iteration_start_time: 迭代开始时间
        """
        iteration_time = time.time() - iteration_start_time
        
        self.performance_stats['total_iterations'] += 1
        self.performance_stats['total_simulation_time'] += iteration_time
        
        if iteration_result.get('success', False):
            self.performance_stats['successful_simulations'] += 1
            
            # 更新奖励统计
            reward = iteration_result.get('reward', 0.0)
            self.performance_stats['total_reward'] += reward
            self.performance_stats['avg_reward'] = (
                self.performance_stats['total_reward'] / 
                self.performance_stats['successful_simulations']
            )
        
        # 计算平均迭代时间
        self.performance_stats['avg_iteration_time'] = (
            self.performance_stats['total_simulation_time'] / 
            self.performance_stats['total_iterations']
        )
    
    def _log_iteration_result(self, iteration_result: Dict[str, Any]) -> None:
        """
        记录迭代结果日志
        
        Args:
            iteration_result: 迭代结果
        """
        iteration = iteration_result['iteration']
        success = iteration_result.get('success', False)
        
        if success:
            reward = iteration_result.get('reward', 0.0)
            done = iteration_result.get('done', False)
            reset = iteration_result.get('reset', False)
            
            status_msg = f"迭代 {iteration}: 奖励={reward:.3f}"
            if done:
                status_msg += ", Episode结束"
            if reset:
                status_msg += ", 环境已重置"
                
            self.logger.info(status_msg)
            
            # 输出环境状态详细信息
            self._log_environment_state(iteration_result)
        else:
            error = iteration_result.get('error', '未知错误')
            self.logger.error(f"迭代 {iteration} 失败: {error}")
    
    def _log_environment_state(self, iteration_result: Dict[str, Any]) -> None:
        """
        输出环境状态详细信息
        
        Args:
            iteration_result: 迭代结果
        """
        try:
            next_state = iteration_result.get('next_state', [])
            if not next_state:
                return
            
            print("\n=== 环境状态详细信息 ===")
            
            # 阀门编号列表（按实际顺序）
            valve_numbers = [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27]
            
            # 状态向量结构：每个阀门有4个状态值 [流量, 压力, 供水温度, 回水温度]
            # 索引计算：阀门i的状态从索引 i*4 开始
            
            print("\n流量 (V_flow):")
            flow_values = []
            for i, valve_num in enumerate(valve_numbers):
                flow_idx = i * 4  # 流量在每组的第0个位置
                if flow_idx < len(next_state):
                    # 流量已经是L/s，直接显示
                    flow_values.append(f"{next_state[flow_idx]:.6f}")
            print(" ".join(flow_values))
            
            print("\n回水温度 (port_b_T):")
            return_temp_values = []
            for i, valve_num in enumerate(valve_numbers):
                temp_idx = i * 4 + 3  # 回水温度在每组的第3个位置
                if temp_idx < len(next_state):
                    # 反归一化回水温度（从[0,1]转换为摄氏度）
                    temp_normalized = next_state[temp_idx]
                    temp_celsius = temp_normalized * 100.0
                    return_temp_values.append(f"{temp_celsius:.1f}")
            print(" ".join(return_temp_values))
            
            print("\n供水温度 (port_a_T):")
            supply_temp_values = []
            for i, valve_num in enumerate(valve_numbers):
                temp_idx = i * 4 + 2  # 供水温度在每组的第2个位置
                if temp_idx < len(next_state):
                    # 反归一化供水温度（从[0,1]转换为摄氏度）
                    temp_normalized = next_state[temp_idx]
                    temp_celsius = temp_normalized * 100.0
                    supply_temp_values.append(f"{temp_celsius:.1f}")
            if supply_temp_values:
                print(" ".join(supply_temp_values))
            else:
                print("无数据")
            
            print("\n阀门开度 (opening):")
            # 阀门开度需要从当前mo文件中读取，而不是从状态向量中
            try:
                valve_openings = self.mo_handler.get_valve_opening_list()
                opening_values = []
                for opening in valve_openings:
                    # 转换为百分比显示
                    opening_percent = opening * 100.0
                    opening_values.append(f"{opening_percent:.1f}")
                print(" ".join(opening_values))
            except Exception as e:
                self.logger.warning(f"无法读取阀门开度: {e}")
                print("无数据")
            
            print("\n========================\n")
            
        except Exception as e:
            self.logger.error(f"输出环境状态失败: {e}")
    
    def _save_intermediate_results(self) -> None:
        """
        保存中间结果
        """
        try:
            intermediate_data = {
                'timestamp': datetime.now().isoformat(),
                'current_iteration': self.current_iteration,
                'performance_stats': self.performance_stats.copy(),
                'recent_results': self.simulation_results[-10:]  # 最近10次结果
            }
            
            intermediate_path = self.results_save_path.replace('.json', '_intermediate.json')
            with open(intermediate_path, 'w', encoding='utf-8') as f:
                json.dump(intermediate_data, f, indent=2, ensure_ascii=False)
                
            self.logger.debug(f"保存中间结果到: {intermediate_path}")
            
        except Exception as e:
            self.logger.error(f"保存中间结果失败: {e}")
    
    def _save_final_results(self) -> None:
        """
        保存最终结果
        """
        try:
            final_data = {
                'timestamp': datetime.now().isoformat(),
                'config': self.config,
                'total_iterations': self.current_iteration,
                'performance_stats': self.performance_stats,
                'simulation_results': self.simulation_results
            }
            
            with open(self.results_save_path, 'w', encoding='utf-8') as f:
                json.dump(final_data, f, indent=2, ensure_ascii=False)
                
            self.logger.info(f"保存最终结果到: {self.results_save_path}")
            
            # 清理backup文件
            self._cleanup_backup_files()
            
        except Exception as e:
            self.logger.error(f"保存最终结果失败: {e}")
    
    def _initialize_components(self) -> None:
        """
        初始化各个组件
        """
        try:
            # 初始化RL配置
            self.rl_config = RLConfig()
            
            # 初始化仿真环境
            env_config_path = self.config.get('env_config_path', 'config/config_efficient.json')
            # 如果是相对路径，相对于当前模块目录
            if not Path(env_config_path).is_absolute():
                current_dir = Path(__file__).parent
                env_config_path = current_dir / env_config_path
            self.env = HeatingEnvironmentEfficient(str(env_config_path))
            self.logger.info("仿真环境初始化完成")
            
            # 初始化IQL智能体
            # 构建完整的配置字典，包含IQLAgent期望的所有配置
            complete_config = {
                'env_config': self.rl_config.env_config,
                'iql_config': self.rl_config.iql_config,
                'network_config': self.rl_config.network_config,
                'training_config': self.rl_config.training_config,
                'device': self.rl_config.device
            }
            self.iql_agent = IQLAgent(complete_config)
            
            # 初始化模型加载器
            # 使用与IQL智能体相同的完整配置
            self.model_loader = RLModelLoader(complete_config)
            self.logger.info("IQL模型加载器初始化完成")
            
            # 初始化mo文件处理器
            mo_file_path = self.config.get('mo_file_path', 'models/HeatingNetwork_20250316.mo')
            # 如果是相对路径，相对于当前模块目录
            if not Path(mo_file_path).is_absolute():
                current_dir = Path(__file__).parent
                mo_file_path = current_dir / mo_file_path
            self.mo_handler = MoFileHandler(mo_file_path, backup_enabled=True)
            self.logger.info("Mo文件处理器初始化完成")
            
        except Exception as e:
            self.logger.error(f"组件初始化失败: {e}")
            raise
    
    def _cleanup_backup_files(self) -> None:
        """
        清理根目录下的backup文件
        """
        try:
            import glob
            import os
            
            # 获取当前工作目录
            current_dir = Path.cwd()
            
            # 查找所有backup文件
            backup_pattern = str(current_dir / "*.backup_*.mo")
            backup_files = glob.glob(backup_pattern)
            
            if backup_files:
                self.logger.info(f"发现 {len(backup_files)} 个backup文件，开始清理...")
                
                cleaned_count = 0
                for backup_file in backup_files:
                    try:
                        os.remove(backup_file)
                        cleaned_count += 1
                        self.logger.debug(f"已删除backup文件: {Path(backup_file).name}")
                    except Exception as e:
                        self.logger.warning(f"删除backup文件失败 {Path(backup_file).name}: {e}")
                
                self.logger.info(f"backup文件清理完成，共清理 {cleaned_count} 个文件")
            else:
                self.logger.debug("未发现需要清理的backup文件")
                
        except Exception as e:
            self.logger.error(f"清理backup文件失败: {e}")
    
    def _load_config(self, config_path: str) -> Dict[str, Any]:
        """
        加载配置文件
        
        Args:
            config_path: 配置文件路径
            
        Returns:
            Dict[str, Any]: 配置字典
        """
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
            return config
        except Exception as e:
            # 如果logger还未初始化，使用print输出错误
            if hasattr(self, 'logger'):
                self.logger.error(f"加载配置文件失败: {e}")
            else:
                print(f"加载配置文件失败: {e}")
            # 返回默认配置
            return {
                'simulation_interval': 5.0,
                'max_iterations': 100,
                'results_save_path': 'iql_simulation_results.json'
            }
    
    def _setup_logging(self) -> logging.Logger:
        """
        设置日志记录
        
        Returns:
            logging.Logger: 日志记录器
        """
        logger = logging.getLogger(self.__class__.__name__)
        
        if not logger.handlers:
            # 设置日志级别
            log_level = self.config.get('log_level', 'INFO')
            logger.setLevel(getattr(logging, log_level.upper()))
            
            # 创建控制台处理器
            console_handler = logging.StreamHandler()
            console_handler.setLevel(logging.INFO)
            
            # 创建文件处理器
            log_file = self.config.get('log_file', 'iql_simulation.log')
            file_handler = logging.FileHandler(log_file, encoding='utf-8')
            file_handler.setLevel(logging.DEBUG)
            
            # 设置日志格式
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            console_handler.setFormatter(formatter)
            file_handler.setFormatter(formatter)
            
            # 添加处理器
            logger.addHandler(console_handler)
            logger.addHandler(file_handler)
        
        return logger
    
    def _signal_handler(self, signum, frame):
        """
        信号处理器
        
        Args:
            signum: 信号编号
            frame: 当前栈帧
        """
        self.logger.info(f"接收到信号 {signum}，准备停止仿真循环")
        self.stop_simulation_loop()
    
    def _initialize_valve_openings_for_iteration(self) -> None:
        """
        每次迭代开始时，每个阀门独立随机调整开度
        确保const12、const13在0.9以上，平均开度在0.75左右
        """
        try:
            import random
            import numpy as np
            
            # 获取当前阀门开度（字典格式）
            current_openings = self.mo_handler.read_valve_openings()
            if not current_openings:
                self.logger.warning("未找到阀门开度，跳过随机调整")
                return
            
            # 创建新的开度字典
            new_openings = {}
            
            # 为每个阀门独立随机调整
            for valve_name, current_value in current_openings.items():
                if valve_name in ['const12', 'const13']:
                    # const12和const13确保在0.9以上
                    new_openings[valve_name] = random.uniform(0.9, 1.0)
                else:
                    # 其他阀门随机调整0.1-0.3
                    offset = random.uniform(0.1, 0.3)
                    if random.choice([True, False]):  # 50%概率增加或减少
                        new_value = current_value + offset
                    else:
                        new_value = current_value - offset
                    
                    # 确保在合理范围内
                    new_value = max(0.5, min(1.0, new_value))
                    new_openings[valve_name] = new_value
            
            # 计算当前平均开度（排除const12和const13）
            other_valves = {k: v for k, v in new_openings.items() if k not in ['const12', 'const13']}
            if other_valves:
                current_avg = np.mean(list(other_valves.values()))
                target_avg = 0.75
                
                # 如果平均开度偏离目标太多，进行调整
                if abs(current_avg - target_avg) > 0.1:
                    adjustment = (target_avg - current_avg) / len(other_valves)
                    for valve_name in other_valves.keys():
                        new_value = new_openings[valve_name] + adjustment
                        new_openings[valve_name] = max(0.5, min(1.0, new_value))
            
            # 将字典转换为按阀门编号顺序的数组
            valve_openings_array = np.zeros(len(self.mo_handler.valve_numbers))
            for i, valve_num in enumerate(self.mo_handler.valve_numbers):
                const_param = f"const{valve_num}"
                if const_param in new_openings:
                    valve_openings_array[i] = new_openings[const_param]
                else:
                    valve_openings_array[i] = 0.75  # 默认值
            
            # 应用新的阀门开度
            success = self.mo_handler.modify_valve_openings(valve_openings_array)
            
            if success:
                final_avg = np.mean(list(new_openings.values()))
                self.logger.info(f"阀门开度调整成功，平均开度: {final_avg:.3f}")
                self.logger.debug(f"调整后的阀门开度: {new_openings}")
            else:
                self.logger.warning("阀门开度随机调整失败")
                
        except Exception as e:
            self.logger.error(f"阀门开度随机调整失败: {e}")
    
    def _run_first_simulation(self) -> np.ndarray:
        """
        进行第一次仿真，获取回水温度等状态信息
        
        Returns:
            np.ndarray: 第一次仿真的状态向量，如果失败返回None
        """
        try:
            # 直接调用环境的仿真方法获取当前状态
            # 这里我们需要触发一次仿真来获取当前mo文件设置下的状态
            
            # 获取当前阀门开度
            current_openings = self.mo_handler.get_valve_opening_list()
            current_openings_array = np.array(current_openings)
            
            # 使用环境的内部方法进行仿真
            if hasattr(self.env, '_run_simulation') and hasattr(self.env, '_read_simulation_results') and hasattr(self.env, '_calculate_state'):
                # 运行仿真
                simulation_success = self.env._run_simulation()
                if not simulation_success:
                    self.logger.error("第一次仿真运行失败")
                    return None
                
                # 读取仿真结果
                results = self.env._read_simulation_results()
                if not results:
                    self.logger.error("第一次仿真结果读取失败")
                    return None
                
                # 计算状态
                state = self.env._calculate_state(results)
                
                self.logger.info(f"第{self.current_iteration + 1}次仿真完成，获取到回水温度等状态信息")
                return state
            else:
                self.logger.error("环境对象缺少必要的仿真方法")
                return None
                
        except Exception as e:
            self.logger.error(f"第一次仿真失败: {e}")
            return None
    
    def _cleanup(self) -> None:
        """
        清理资源
        """
        try:
            if hasattr(self, 'env'):
                self.env.close()
                self.logger.info("仿真环境已关闭")
        except Exception as e:
            self.logger.error(f"清理资源失败: {e}")
        
        self.running = False
        self.logger.info("资源清理完成")


def main():
    """
    主函数
    """
    import argparse
    
    parser = argparse.ArgumentParser(description='IQL-Dymola仿真控制循环')
    parser.add_argument('--config', '-c', 
                       default='config/simulation_config.json',
                       help='配置文件路径')
    parser.add_argument('--iterations', '-i', 
                       type=int, 
                       help='最大迭代次数')
    parser.add_argument('--interval', '-t', 
                       type=float, 
                       help='仿真间隔（秒）')
    parser.add_argument('--log-level', '-l', 
                       choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
                       default='INFO',
                       help='日志级别')
    
    args = parser.parse_args()
    
    # 设置基础日志
    logging.basicConfig(
        level=getattr(logging, args.log_level),
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    try:
        # 创建仿真循环
        simulation_loop = IQLDymolaSimulationLoop(args.config)
        
        # 覆盖命令行参数
        if args.iterations:
            simulation_loop.max_iterations = args.iterations
        if args.interval:
            simulation_loop.simulation_interval = args.interval
        
        # 启动仿真循环
        simulation_loop.start_simulation_loop()
        
    except KeyboardInterrupt:
        print("\n用户中断，正在退出...")
    except Exception as e:
        print(f"程序执行失败: {e}")
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    main()