#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
多进程训练副本创建器

作者: Dionysus
日期: 2025-01-16

为避免Dymola编译文件冲突，创建完全独立的工作目录副本。
每个副本都有独立的编译环境和保存目录。
"""

import os
import shutil
import json
import argparse
from pathlib import Path
from typing import List, Dict, Any


class MultiProcessCopier:
    """
    多进程副本创建器

    创建完全独立的工作目录，避免Dymola编译文件冲突。
    """

    def __init__(self, source_dir: str = None):
        """
        初始化副本创建器

        参数:
            source_dir: 源目录路径，默认为当前目录
        """
        self.source_dir = Path(source_dir) if source_dir else Path.cwd()
        self.parent_dir = self.source_dir.parent

    def get_files_to_copy(self) -> List[str]:
        """
        获取需要复制的文件列表

        返回:
            List[str]: 文件路径列表
        """
        # 需要复制的文件扩展名
        include_extensions = {
            '.py',  # Python文件
            '.json',  # 配置文件
            '.mo',  # Modelica文件
            '.txt',  # 文本文件
            '.md',  # 文档文件
        }

        # 需要复制的目录
        include_dirs = {
            'web',  # Web界面
            'analysis_results',  # 分析结果（可选）
        }

        # 排除的文件和目录
        exclude_patterns = {
            '__pycache__',
            '.git',
            '.vscode',
            'training_result',  # 训练结果目录不复制
            'offline_data',  # 离线数据不复制（太大）
            'simulation_results',  # 仿真结果不复制
            '.pyc',
            '.log',
            'dslog.txt',  # Dymola日志
            'dsfinal.txt',  # Dymola结果
            'dsmodel.c',  # Dymola编译文件
            'dymosim.exe',  # Dymola可执行文件
        }

        files_to_copy = []

        for item in self.source_dir.iterdir():
            # 跳过排除的项目
            if any(pattern in item.name for pattern in exclude_patterns):
                continue

            if item.is_file():
                # 检查文件扩展名
                if item.suffix in include_extensions:
                    files_to_copy.append(str(item.relative_to(self.source_dir)))
            elif item.is_dir():
                # 检查目录名
                if item.name in include_dirs:
                    files_to_copy.append(str(item.relative_to(self.source_dir)))

        return files_to_copy

    def create_process_copy(self, process_id: int, config_modifications: Dict[str, Any] = None,
                            base_name: str = "efficient_rl_process") -> str:
        """
        创建单个进程的副本目录，避免覆盖已存在目录

        参数:
            process_id: 进程ID
            config_modifications: 配置文件修改项
            base_name: 目录名前缀

        返回:
            str: 新创建的目录路径
        """
        target_dir_name = f"{base_name}_{process_id}"
        target_dir = self.parent_dir / target_dir_name

        # 如果目录存在，自动寻找一个新目录名，比如加后缀 "_1", "_2" 等
        suffix = 1
        while target_dir.exists():
            target_dir = self.parent_dir / f"{target_dir_name}_{suffix}"
            suffix += 1

        # 创建新目录
        target_dir.mkdir(parents=True, exist_ok=True)
        print(f"创建目录: {target_dir}")

        # 获取要复制的文件
        files_to_copy = self.get_files_to_copy()

        # 复制文件和目录
        for file_path in files_to_copy:
            source_path = self.source_dir / file_path
            target_path = target_dir / file_path

            if source_path.is_file():
                # 复制文件
                target_path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source_path, target_path)
                print(f"  复制文件: {file_path}")
            elif source_path.is_dir():
                # 复制目录
                shutil.copytree(source_path, target_path, dirs_exist_ok=True)
                print(f"  复制目录: {file_path}")

        # 修改配置文件
        self._modify_config_file(target_dir, process_id, config_modifications)

        # 创建启动脚本
        self._create_start_script(target_dir, process_id)

        return str(target_dir)

    def _modify_config_file(self, target_dir: Path, process_id: int,
                            config_modifications: Dict[str, Any] = None):
        """
        修改配置文件

        参数:
            target_dir: 目标目录
            process_id: 进程ID
            config_modifications: 配置修改项
        """
        config_file = target_dir / "config_efficient.json"

        if not config_file.exists():
            print(f"  警告: 配置文件 {config_file} 不存在")
            return

        # 读取配置
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)

        # 修改保存目录
        config['save_dir'] = f"efficient_training_results_p{process_id}"

        # 应用用户指定的修改
        if config_modifications:
            config.update(config_modifications)

        # 保存修改后的配置
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2, ensure_ascii=False)

        print(f"  修改配置文件: save_dir = {config['save_dir']}")
        if config_modifications:
            for key, value in config_modifications.items():
                print(f"  修改配置: {key} = {value}")

    def _create_start_script(self, target_dir: Path, process_id: int):
        """
        创建启动脚本

        参数:
            target_dir: 目标目录
            process_id: 进程ID
        """
        # Windows批处理脚本
        bat_script = f"""@echo off
echo 启动进程 {process_id} 的训练...
echo 工作目录: %cd%
echo.

REM 激活虚拟环境（如果存在）
if exist "..\\.venv\\Scripts\\activate.bat" (
    echo 激活虚拟环境...
    call "..\\.venv\\Scripts\\activate.bat"
)

REM 启动训练
python main_efficient.py --mode train

echo.
echo 训练完成，按任意键退出...
pause
"""

        bat_file = target_dir / f"start_training_p{process_id}.bat"
        with open(bat_file, 'w', encoding='gbk') as f:
            f.write(bat_script)

        # PowerShell脚本
        ps1_script = f"""# 启动进程 {process_id} 的训练
Write-Host "启动进程 {process_id} 的训练..." -ForegroundColor Green
Write-Host "工作目录: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

# 激活虚拟环境（如果存在）
if (Test-Path "../.venv/Scripts/Activate.ps1") {{
    Write-Host "激活虚拟环境..." -ForegroundColor Cyan
    & "../.venv/Scripts/Activate.ps1"
}}

# 启动训练
python main_efficient.py --mode train

Write-Host ""
Write-Host "训练完成" -ForegroundColor Green
Read-Host "按回车键退出"
"""

        ps1_file = target_dir / f"start_training_p{process_id}.ps1"
        with open(ps1_file, 'w', encoding='utf-8') as f:
            f.write(ps1_script)

        print(f"  创建启动脚本: {bat_file.name}, {ps1_file.name}")

    def create_multiple_copies(self, num_processes: int, start_id: int = 0,
                               config_variations: List[Dict[str, Any]] = None) -> List[str]:
        """
        创建多个进程副本，支持从start_id开始编号

        参数:
            num_processes: 进程数量
            start_id: 起始进程ID（默认0）
            config_variations: 每个进程的配置变化

        返回:
            List[str]: 创建的目录路径列表
        """
        created_dirs = []

        print(f"开始创建 {num_processes} 个进程副本，编号从 {start_id} 开始...")
        print(f"源目录: {self.source_dir}")
        print(f"目标父目录: {self.parent_dir}")
        print("=" * 60)

        for i in range(start_id, start_id + num_processes):
            print(f"\n创建进程 {i} 的副本:")

            # 获取配置修改
            config_mod = {}
            if config_variations and i - start_id < len(config_variations):
                config_mod = config_variations[i - start_id]

            # 创建副本
            target_dir = self.create_process_copy(process_id=i, config_modifications=config_mod)
            created_dirs.append(target_dir)

        print("\n所有进程副本创建完成。")
        return created_dirs


def main():
    parser = argparse.ArgumentParser(description="多进程训练副本创建器")
    parser.add_argument('-n', '--num', type=int, default=4,
                        help='需要创建的进程副本数量，默认4')
    parser.add_argument('-s', '--start', type=int, default=0,
                        help='起始进程编号，默认0')
    parser.add_argument('-d', '--dir', type=str, default=None,
                        help='源目录路径，默认当前目录')
    args = parser.parse_args()

    copier = MultiProcessCopier(source_dir=args.dir)
    copier.create_multiple_copies(num_processes=args.num, start_id=args.start)


if __name__ == "__main__":
    main()
