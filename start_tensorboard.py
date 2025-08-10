#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TensorBoard启动脚本

作者: Dionysus
日期: 2025-01-09
描述: 便捷启动TensorBoard查看训练过程的脚本
"""

import os
import sys
import subprocess
import webbrowser
import time
from pathlib import Path


def find_tensorboard_dir():
    """
    查找TensorBoard日志目录
    
    Returns:
        str: TensorBoard日志目录路径，如果未找到返回None
    """
    import glob
    import re
    
    # 查找所有可能的TensorBoard目录
    all_dirs = []
    
    # 1. 带时间戳的训练结果目录（优先级最高）
    timestamp_pattern = r'training_results_\d{8}_\d{6}'
    for dir_name in os.listdir('.'):
        if re.match(timestamp_pattern, dir_name):
            tensorboard_path = os.path.join(dir_name, 'tensorboard')
            if os.path.exists(tensorboard_path):
                log_files = [f for f in os.listdir(tensorboard_path) if f.startswith('events.out.tfevents')]
                if log_files:
                    # 提取时间戳用于排序
                    timestamp = dir_name.split('_')[-2] + '_' + dir_name.split('_')[-1]
                    all_dirs.append((timestamp, os.path.abspath(tensorboard_path)))
    
    # 按时间戳降序排序（最新的在前）
    all_dirs.sort(key=lambda x: x[0], reverse=True)
    
    # 如果找到带时间戳的目录，返回最新的
    if all_dirs:
        return all_dirs[0][1]
    
    # 2. 固定名称的目录（作为备选）
    fixed_dirs = [
        'offline_training_results/tensorboard',
        'efficient_training_results/tensorboard',
        'offline_test_results/tensorboard',
        'test_model_save_results/tensorboard',
        'training_results/tensorboard'
    ]
    
    for dir_path in fixed_dirs:
        if os.path.exists(dir_path):
            # 检查是否有日志文件
            log_files = [f for f in os.listdir(dir_path) if f.startswith('events.out.tfevents')]
            if log_files:
                return os.path.abspath(dir_path)
    
    return None


def start_tensorboard(logdir, port=6006):
    """
    启动TensorBoard
    
    Args:
        logdir: 日志目录路径
        port: 端口号，默认6006
    
    Returns:
        bool: 是否启动成功
    """
    try:
        print(f"🚀 启动TensorBoard...")
        print(f"📁 日志目录: {logdir}")
        print(f"🌐 端口: {port}")
        
        # 构建命令
        cmd = ['tensorboard', '--logdir', logdir, '--port', str(port)]
        
        # 启动TensorBoard
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        # 等待一下让TensorBoard启动
        time.sleep(3)
        
        # 检查进程是否还在运行
        if process.poll() is None:
            print("✅ TensorBoard启动成功!")
            print(f"🔗 访问地址: http://localhost:{port}")
            print("\n📊 可查看的指标:")
            print("  - Loss/Policy: 策略损失")
            print("  - Loss/Value: 价值损失")
            print("  - Loss/Entropy: 熵损失")
            print("  - Episode/Reward: 每轮奖励")
            print("  - Episode/Length: 每轮长度")
            print("  - Episode/Recent_Avg_Reward: 最近平均奖励")
            print("  - Episode/Best_Reward: 历史最佳奖励")
            print("\n⚠️  按 Ctrl+C 停止TensorBoard")
            
            # 自动打开浏览器
            try:
                webbrowser.open(f'http://localhost:{port}')
                print("🌐 已自动打开浏览器")
            except:
                print("⚠️  无法自动打开浏览器，请手动访问上述地址")
            
            # 等待用户中断
            try:
                process.wait()
            except KeyboardInterrupt:
                print("\n🛑 正在停止TensorBoard...")
                process.terminate()
                process.wait()
                print("✅ TensorBoard已停止")
            
            return True
        else:
            # 获取错误信息
            stdout, stderr = process.communicate()
            print("❌ TensorBoard启动失败")
            if stderr:
                print(f"错误信息: {stderr}")
            return False
            
    except FileNotFoundError:
        print("❌ 未找到tensorboard命令")
        print("请先安装TensorBoard: pip install tensorboard")
        return False
    except Exception as e:
        print(f"❌ 启动TensorBoard时发生错误: {e}")
        return False


def main():
    """
    主函数
    """
    print("=== TensorBoard启动器 ===")
    print("作者: Dionysus")
    print("日期: 2025-01-09\n")
    
    # 查找TensorBoard目录
    logdir = find_tensorboard_dir()
    
    if logdir is None:
        print("❌ 未找到TensorBoard日志目录")
        print("\n可能的原因:")
        print("1. 还没有开始训练")
        print("2. 训练目录不在当前路径")
        print("3. TensorBoard日志文件不存在")
        print("\n建议:")
        print("1. 先运行训练: python main_efficient.py --mode train")
        print("2. 或运行测试: python test_model_save_tensorboard.py")
        return 1
    
    print(f"✅ 找到TensorBoard日志目录: {logdir}")
    
    # 检查日志文件
    log_files = [f for f in os.listdir(logdir) if f.startswith('events.out.tfevents')]
    print(f"📄 找到 {len(log_files)} 个日志文件")
    
    # 启动TensorBoard
    port = 6006
    
    # 检查端口是否被占用，如果是则尝试其他端口
    for attempt_port in range(port, port + 10):
        try:
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            result = sock.connect_ex(('localhost', attempt_port))
            sock.close()
            
            if result != 0:  # 端口可用
                port = attempt_port
                break
        except:
            pass
    
    success = start_tensorboard(logdir, port)
    
    if success:
        return 0
    else:
        return 1


if __name__ == "__main__":
    exit(main())