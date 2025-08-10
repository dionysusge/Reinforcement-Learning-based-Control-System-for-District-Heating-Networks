#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
训练结果查看器启动脚本
作者: Dionysus
日期: 2025-01-09

快速启动训练结果查看器Web服务
"""

import os
import sys
import subprocess
import time


def check_dependencies():
    """
    检查依赖包是否已安装
    
    Returns:
        bool: 是否所有依赖都已安装
    """
    required_packages = [
        'flask',
        'flask-cors',
        'tensorboard'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        print("❌ 缺少以下依赖包:")
        for package in missing_packages:
            print(f"   - {package}")
        print("\n请运行以下命令安装:")
        print(f"pip install {' '.join(missing_packages)}")
        return False
    
    return True


def activate_venv():
    """
    激活虚拟环境（如果存在）
    
    Returns:
        bool: 是否成功激活虚拟环境
    """
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 查找虚拟环境目录
    possible_venv_dirs = ['.venv', 'venv', 'env']
    
    for venv_dir in possible_venv_dirs:
        venv_path = os.path.join(current_dir, venv_dir)
        if os.path.exists(venv_path):
            # Windows
            if os.name == 'nt':
                activate_script = os.path.join(venv_path, 'Scripts', 'activate.bat')
                python_exe = os.path.join(venv_path, 'Scripts', 'python.exe')
            # Unix/Linux/macOS
            else:
                activate_script = os.path.join(venv_path, 'bin', 'activate')
                python_exe = os.path.join(venv_path, 'bin', 'python')
            
            if os.path.exists(python_exe):
                print(f"✅ 找到虚拟环境: {venv_path}")
                # 更新sys.executable为虚拟环境的Python
                sys.executable = python_exe
                return True
    
    print("⚠️  未找到虚拟环境，使用系统Python")
    return False


def start_web_server():
    """
    启动Web服务器
    """
    print("=== 训练结果查看器启动脚本 ===")
    print("作者: Dionysus")
    print("日期: 2025-01-09\n")
    
    # 激活虚拟环境
    activate_venv()
    
    # 检查依赖
    print("🔍 检查依赖包...")
    if not check_dependencies():
        print("\n❌ 依赖检查失败，请先安装所需依赖包")
        input("按回车键退出...")
        return
    
    print("✅ 依赖检查通过")
    
    # 检查web_server.py是否存在
    current_dir = os.path.dirname(os.path.abspath(__file__))
    web_server_path = os.path.join(current_dir, 'web_server.py')
    
    if not os.path.exists(web_server_path):
        print(f"❌ 未找到web_server.py文件: {web_server_path}")
        input("按回车键退出...")
        return
    
    # 启动Web服务器
    print("🚀 启动Web服务器...")
    print("\n" + "="*50)
    
    try:
        # 使用当前Python解释器运行web_server.py
        subprocess.run([sys.executable, web_server_path], cwd=current_dir)
    except KeyboardInterrupt:
        print("\n\n👋 用户中断，正在退出...")
    except Exception as e:
        print(f"\n❌ 启动失败: {e}")
        input("按回车键退出...")


if __name__ == '__main__':
    start_web_server()