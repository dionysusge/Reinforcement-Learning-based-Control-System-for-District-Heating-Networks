#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
日志配置工具

作者: Dionysus
"""

import logging
import sys
from pathlib import Path
from typing import Optional
from datetime import datetime

def setup_logger(name: str = 'rl_dymola_simulation', 
                 log_level: str = 'INFO',
                 log_file: Optional[Path] = None,
                 console_output: bool = True) -> logging.Logger:
    """
    设置日志记录器
    
    Args:
        name: 日志记录器名称
        log_level: 日志级别 ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL')
        log_file: 日志文件路径（可选）
        console_output: 是否输出到控制台
        
    Returns:
        logging.Logger: 配置好的日志记录器
    """
    # 创建日志记录器
    logger = logging.getLogger(name)
    
    # 避免重复添加处理器
    if logger.handlers:
        return logger
    
    # 设置日志级别
    level_map = {
        'DEBUG': logging.DEBUG,
        'INFO': logging.INFO,
        'WARNING': logging.WARNING,
        'ERROR': logging.ERROR,
        'CRITICAL': logging.CRITICAL
    }
    logger.setLevel(level_map.get(log_level.upper(), logging.INFO))
    
    # 创建格式化器
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    # 控制台处理器
    if console_output:
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.INFO)
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
    
    # 文件处理器
    if log_file:
        log_file = Path(log_file)
        log_file.parent.mkdir(parents=True, exist_ok=True)
        
        file_handler = logging.FileHandler(log_file, encoding='utf-8')
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    
    return logger

def create_session_logger(base_dir: Path, session_name: Optional[str] = None) -> logging.Logger:
    """
    为仿真会话创建专用日志记录器
    
    Args:
        base_dir: 基础目录
        session_name: 会话名称（可选，默认使用时间戳）
        
    Returns:
        logging.Logger: 会话日志记录器
    """
    if session_name is None:
        session_name = datetime.now().strftime('%Y%m%d_%H%M%S')
    
    log_dir = base_dir / 'logs'
    log_file = log_dir / f'session_{session_name}.log'
    
    return setup_logger(
        name=f'rl_dymola_session_{session_name}',
        log_level='DEBUG',
        log_file=log_file,
        console_output=True
    )

class SimulationLogger:
    """
    仿真专用日志记录器类
    
    提供结构化的日志记录功能
    """
    
    def __init__(self, logger: logging.Logger):
        """
        初始化仿真日志记录器
        
        Args:
            logger: 基础日志记录器
        """
        self.logger = logger
        self.iteration_count = 0
    
    def log_iteration_start(self, iteration: int, valve_openings: list):
        """
        记录迭代开始
        
        Args:
            iteration: 迭代次数
            valve_openings: 当前阀门开度
        """
        self.iteration_count = iteration
        self.logger.info(f"=== 开始第 {iteration} 次迭代 ===")
        self.logger.info(f"当前阀门开度: 平均={sum(valve_openings)/len(valve_openings):.3f}, "
                        f"范围=[{min(valve_openings):.3f}, {max(valve_openings):.3f}]")
    
    def log_simulation_start(self, model_path: str):
        """
        记录仿真开始
        
        Args:
            model_path: 模型文件路径
        """
        self.logger.info(f"开始Dymola仿真: {model_path}")
    
    def log_simulation_result(self, result: dict):
        """
        记录仿真结果
        
        Args:
            result: 仿真结果字典
        """
        if 'avg_return_temp' in result:
            self.logger.info(f"仿真完成 - 平均回水温度: {result['avg_return_temp']:.2f}°C, "
                           f"温度标准差: {result.get('std_return_temp', 0):.2f}°C")
        
        if 'performance' in result:
            self.logger.info(f"性能指标: {result['performance']:.4f}")
    
    def log_rl_prediction(self, state: list, action: list):
        """
        记录强化学习预测
        
        Args:
            state: 当前状态
            action: 预测动作
        """
        self.logger.debug(f"RL预测 - 状态维度: {len(state)}, 动作维度: {len(action)}")
        self.logger.debug(f"预测动作: 平均={sum(action)/len(action):.3f}, "
                         f"范围=[{min(action):.3f}, {max(action):.3f}]")
    
    def log_convergence_check(self, converged: bool, performance_history: list):
        """
        记录收敛检查
        
        Args:
            converged: 是否收敛
            performance_history: 性能历史
        """
        if converged:
            self.logger.info(f"算法已收敛！当前性能: {performance_history[-1]:.4f}")
        else:
            recent_improvement = performance_history[-2] - performance_history[-1] if len(performance_history) > 1 else 0
            self.logger.info(f"继续优化 - 本次改进: {recent_improvement:.4f}")
    
    def log_iteration_end(self, performance: float, best_performance: float):
        """
        记录迭代结束
        
        Args:
            performance: 当前性能
            best_performance: 最佳性能
        """
        is_best = performance <= best_performance
        status = "★ 新最佳" if is_best else "继续优化"
        self.logger.info(f"第 {self.iteration_count} 次迭代完成 - 性能: {performance:.4f} ({status})")
        self.logger.info(f"=== 第 {self.iteration_count} 次迭代结束 ===\n")
    
    def log_final_results(self, total_iterations: int, best_performance: float, 
                         final_temp: float, converged: bool):
        """
        记录最终结果
        
        Args:
            total_iterations: 总迭代次数
            best_performance: 最佳性能
            final_temp: 最终温度
            converged: 是否收敛
        """
        self.logger.info("=" * 50)
        self.logger.info("仿真控制完成！")
        self.logger.info(f"总迭代次数: {total_iterations}")
        self.logger.info(f"最佳性能指标: {best_performance:.4f}")
        self.logger.info(f"最终平均温度: {final_temp:.2f}°C")
        self.logger.info(f"收敛状态: {'已收敛' if converged else '未收敛'}")
        self.logger.info("=" * 50)
    
    def log_error(self, error_msg: str, exception: Exception = None):
        """
        记录错误信息
        
        Args:
            error_msg: 错误消息
            exception: 异常对象（可选）
        """
        self.logger.error(f"错误: {error_msg}")
        if exception:
            self.logger.error(f"异常详情: {str(exception)}")
    
    def log_warning(self, warning_msg: str):
        """
        记录警告信息
        
        Args:
            warning_msg: 警告消息
        """
        self.logger.warning(f"警告: {warning_msg}")
    
    def log_debug(self, debug_msg: str):
        """
        记录调试信息
        
        Args:
            debug_msg: 调试消息
        """
        self.logger.debug(debug_msg)