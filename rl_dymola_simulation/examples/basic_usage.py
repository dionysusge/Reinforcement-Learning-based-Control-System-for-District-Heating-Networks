#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
基础使用示例

作者: Dionysus
"""

import sys
from pathlib import Path

# 添加项目路径
sys.path.append(str(Path(__file__).parent.parent))

from ..config.simulation_config import SimulationConfig
from ..core.rl_model_loader import RLModelLoader
from ..core.dymola_interface import DymolaInterface
from ..core.strategy_search_controller import StrategySearchController
from ..utils.data_processor import DataProcessor
from ..utils.visualizer import ResultVisualizer
from ..utils.logger import create_session_logger, SimulationLogger

def basic_simulation_example():
    """
    基础仿真示例
    
    演示如何使用强化学习模型控制Dymola仿真
    """
    # 1. 创建配置
    config_dict = {
        'base_dir': str(Path.cwd().parent),  # 项目根目录
        'rl_model': {
            'model_path': 'reinforcement_learning/models/ppo_model.pth',
            'model_type': 'ppo',
            'state_dim': 60,
            'action_dim': 30,
            'state_mean_path': 'reinforcement_learning/models/state_mean.npy',
            'state_std_path': 'reinforcement_learning/models/state_std.npy',
            'action_mean_path': 'reinforcement_learning/models/action_mean.npy',
            'action_std_path': 'reinforcement_learning/models/action_std.npy'
        },
        'dymola': {
            'model_file': '../models/HeatingNetwork_20250316.mo',
            'simulation_time': 3600,
            'time_step': 60
        },
        'control': {
            'max_iterations': 20,
            'convergence_threshold': 0.005,
            'target_temperature': 45.0,
            'min_valve_opening': 0.1,
            'max_valve_opening': 1.0
        }
    }
    
    config = SimulationConfig(config_dict)
    
    # 2. 设置日志
    logger = create_session_logger(config.base_dir, 'basic_example')
    sim_logger = SimulationLogger(logger)
    
    try:
        logger.info("开始基础仿真示例")
        
        # 3. 验证配置
        config.validate()
        logger.info("配置验证通过")
        
        # 4. 初始化组件
        logger.info("初始化系统组件...")
        
        # 加载强化学习模型
        model_loader = RLModelLoader(
            model_path=config.get_model_path(),
            model_type=config.rl_model['model_type']
        )
        logger.info(f"模型加载完成: {model_loader.get_model_info()}")
        
        # 初始化Dymola接口
        dymola_interface = DymolaInterface(
            model_file=config.dymola['model_file'],
            work_dir=config.base_dir / 'simulation_temp',
            result_dir=config.base_dir / 'simulation_results'
        )
        logger.info("Dymola接口初始化完成")
        
        # 创建策略搜索控制器
        controller = StrategySearchController(
            model_loader=model_loader,
            dymola_interface=dymola_interface,
            config=config,
            logger=sim_logger
        )
        logger.info("策略搜索控制器创建完成")
        
        # 5. 运行策略搜索和仿真
        logger.info("开始运行策略搜索和仿真...")
        result = controller.run_simulation()
        
        # 6. 分析结果
        logger.info("分析仿真结果...")
        data_processor = DataProcessor(config.base_dir / 'analysis')
        analysis_result = data_processor.analyze_simulation_results(result)
        
        # 7. 生成可视化
        logger.info("生成可视化图表...")
        visualizer = ResultVisualizer(config.base_dir / 'plots')
        plots = visualizer.generate_all_plots(result)
        
        # 8. 输出结果摘要
        print("\n" + "=" * 50)
        print("仿真结果摘要:")
        print(f"总迭代次数: {len(result['iteration_history'])}")
        print(f"最佳性能: {result['best_performance']:.4f}")
        print(f"收敛状态: {'已收敛' if result['converged'] else '未收敛'}")
        
        if result['iteration_history']:
            final_iteration = result['iteration_history'][-1]
            print(f"最终温度: {final_iteration.get('avg_return_temp', 0):.2f}°C")
            print(f"温度标准差: {final_iteration.get('std_return_temp', 0):.2f}°C")
            print(f"平均阀门开度: {final_iteration.get('avg_valve_opening', 0):.3f}")
        
        print(f"\n生成的图表: {len(plots)} 个")
        for plot_type, plot_path in plots.items():
            print(f"  {plot_type}: {plot_path}")
        
        print("=" * 50)
        
        logger.info("基础仿真示例完成")
        return result
        
    except Exception as e:
        sim_logger.log_error("基础仿真示例失败", e)
        raise

def quick_test_example():
    """
    快速测试示例
    
    用于快速验证系统功能
    """
    print("开始快速测试...")
    
    # 简化配置，用于快速测试
    config_dict = {
        'base_dir': str(Path.cwd().parent),
        'rl_model': {
            'model_path': 'reinforcement_learning/models/ppo_model.pth',
            'model_type': 'ppo'
        },
        'dymola': {
            'model_file': '../models/HeatingNetwork_20250316.mo',
            'simulation_time': 1800,  # 缩短仿真时间
            'time_step': 120
        },
        'control': {
            'max_iterations': 5,  # 减少迭代次数
            'convergence_threshold': 0.01,
            'target_temperature': 45.0
        }
    }
    
    config = SimulationConfig(config_dict)
    
    # 设置日志
    logger = create_session_logger(config.base_dir, 'quick_test')
    sim_logger = SimulationLogger(logger)
    
    try:
        # 验证配置
        config.validate()
        print("✓ 配置验证通过")
        
        # 测试模型加载
        model_loader = RLModelLoader(
            model_path=config.get_model_path(),
            model_type=config.rl_model['model_type']
        )
        print("✓ 强化学习模型加载成功")
        
        # 测试Dymola接口
        dymola_interface = DymolaInterface(
            model_file=config.dymola['model_file'],
            work_dir=config.base_dir / 'test_temp',
            result_dir=config.base_dir / 'test_results'
        )
        print("✓ Dymola接口初始化成功")
        
        # 运行简短的策略搜索
        controller = StrategySearchController(
            model_loader=model_loader,
            dymola_interface=dymola_interface,
            config=config,
            logger=sim_logger
        )
        
        result = controller.run_simulation()
        
        print(f"✓ 控制循环完成，共 {len(result['iteration_history'])} 次迭代")
        print(f"✓ 最佳性能: {result['best_performance']:.4f}")
        
        print("\n快速测试完成！系统功能正常。")
        return True
        
    except Exception as e:
        print(f"✗ 快速测试失败: {e}")
        return False

def custom_config_example():
    """
    自定义配置示例
    
    演示如何创建和使用自定义配置
    """
    print("自定义配置示例")
    
    # 创建自定义配置
    custom_config = {
        'base_dir': str(Path.cwd().parent),
        'rl_model': {
            'model_path': 'reinforcement_learning/models/ppo_model.pth',
            'model_type': 'ppo',
            'state_dim': 60,
            'action_dim': 30
        },
        'dymola': {
            'model_file': '../models/HeatingNetwork_20250316.mo',
            'simulation_time': 7200,  # 2小时仿真
            'time_step': 30,  # 30秒步长
            'tolerance': 1e-6
        },
        'control': {
            'max_iterations': 50,  # 更多迭代
            'convergence_threshold': 0.001,  # 更严格的收敛条件
            'target_temperature': 43.0,  # 不同的目标温度
            'temperature_tolerance': 1.0,
            'min_valve_opening': 0.05,
            'max_valve_opening': 0.95,
            'valve_change_limit': 0.1  # 限制阀门变化幅度
        },
        'buildings': {
            'count': 30,
            'valve_prefix': 'valve_',
            'temp_sensor_prefix': 'temp_'
        },
        'output': {
            'save_intermediate': True,
            'save_plots': True,
            'plot_format': 'png',
            'excel_report': True
        }
    }
    
    config = SimulationConfig(custom_config)
    
    print(f"✓ 自定义配置创建完成")
    print(f"  - 目标温度: {config.target_temperature}°C")
    print(f"  - 最大迭代: {config.max_iterations}")
    print(f"  - 收敛阈值: {config.convergence_threshold}")
    print(f"  - 楼栋数量: {config.buildings['count']}")
    
    # 验证配置
    try:
        config.validate()
        print("✓ 自定义配置验证通过")
    except Exception as e:
        print(f"✗ 配置验证失败: {e}")
    
    return config

if __name__ == '__main__':
    print("强化学习-Dymola闭环仿真系统使用示例")
    print("=" * 50)
    
    # 选择运行的示例
    import argparse
    parser = argparse.ArgumentParser(description='运行使用示例')
    parser.add_argument('--example', choices=['basic', 'quick', 'custom'], 
                       default='quick', help='选择运行的示例')
    args = parser.parse_args()
    
    try:
        if args.example == 'basic':
            basic_simulation_example()
        elif args.example == 'quick':
            quick_test_example()
        elif args.example == 'custom':
            custom_config_example()
    except KeyboardInterrupt:
        print("\n用户中断")
    except Exception as e:
        print(f"\n示例运行失败: {e}")