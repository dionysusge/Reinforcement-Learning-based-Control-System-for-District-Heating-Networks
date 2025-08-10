#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
离线训练数据转换和可视化脚本（改进版）

作者: Dionysus（基于用户原始脚本）
日期: 2025-08-09（修改版）

改动点:
- 保留 CSV 导出
- 自动选择中文字体（常见字体优先）
- 强制数值类型转换以防绘图出错
- 每幅图添加详细解释文字、统计注释、关键点标注
- 更稳健的异常处理和友好提示
"""

import json
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from pathlib import Path
import os
from datetime import datetime
import seaborn as sns
from typing import List, Dict, Tuple, Optional

# 图形样式
plt.rcParams['axes.unicode_minus'] = False
sns.set_style("whitegrid")


class OfflineDataConverter:
    """
    离线训练数据转换器（改进版）
    """

    def __init__(self, input_dir: str, output_dir: str):
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

        # 创建子目录（保持 csv_data，因为你要保留 CSV）
        (self.output_dir / 'csv_data').mkdir(exist_ok=True)
        (self.output_dir / 'visualizations').mkdir(exist_ok=True)
        (self.output_dir / 'analysis_reports').mkdir(exist_ok=True)

        # 尝试设置中文字体（更稳健）
        self._set_chinese_font()

        # 状态变量索引映射
        self.state_mapping = self._create_state_mapping()

    def _set_chinese_font(self) -> None:
        """
        尝试自动设置一个可用的中文字体，优先列表：Microsoft YaHei, SimHei, PingFang, Noto Sans CJK, WenQuanYi
        如果找不到，会打印警告（中文可能乱码），你可安装相应字体或在此函数中指定字体路径。
        """
        preferred = [
            "Microsoft YaHei", "微软雅黑",  # Windows 常见
            "SimHei", "黑体",             # 常见备选
            "PingFang", "PingFang SC",    # macOS
            "Noto Sans CJK", "NotoSansCJK",# Noto（Linux 发行版上）
            "WenQuanYi Zen Hei", "WenQuanYi"  # Linux 社区字体
        ]

        found = None
        for f in fm.fontManager.ttflist:
            fname = f.name.lower()
            fpath = f.fname.lower()
            for p in preferred:
                if p.lower() in fname or p.lower() in fpath:
                    found = f.name
                    found_path = f.fname
                    break
            if found:
                break

        if found:
            # 使用找到的字体 family 名称
            plt.rcParams['font.sans-serif'] = [found]
            plt.rcParams['font.family'] = 'sans-serif'
            print(f"✅ 已设置中文字体为: {found} （{found_path}）")
        else:
            # 没找到合适中文字体，给出提示
            print("⚠️ 未检测到常见中文字体，图中中文可能出现乱码。"
                  "建议安装 'Microsoft YaHei' 或 'SimHei'，或在脚本中指定字体文件路径。")

    def _create_state_mapping(self) -> Dict[str, List[int]]:
        """
        创建状态变量索引映射（保留原有假设）
        """
        mapping = {
            'flow_rates': [],
            'temperatures': [],
            'pressures': [],
            'return_temps': []
        }

        total_states = 69  # 原始观察到的状态变量总数
        nodes = total_states // 4
        for i in range(nodes):
            base_idx = i * 4
            mapping['flow_rates'].append(base_idx)
            mapping['temperatures'].append(base_idx + 1)
            mapping['return_temps'].append(base_idx + 2)
            mapping['pressures'].append(base_idx + 3)

        return mapping

    def load_json_data(self, file_path: Path) -> List[Dict]:
        """
        加载 JSON 数据文件
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            print(f"✅ 成功加载数据文件: {file_path.name}，包含 {len(data)} 个训练步骤")
            return data
        except Exception as e:
            print(f"❌ 加载数据文件失败: {file_path.name}，错误: {e}")
            return []

    def convert_to_dataframe(self, json_data: List[Dict], file_name: str) -> pd.DataFrame:
        """
        将 JSON 数据转换为 DataFrame（并提取关键指标）
        """
        records = []

        for entry in json_data:
            # 保护性取值（避免 KeyError）
            step = entry.get('step')
            actions = entry.get('action', [])
            states = entry.get('state', [])
            reward = entry.get('reward')
            done = entry.get('done', False)
            timestamp = entry.get('timestamp', '')

            record = {
                'file_name': file_name,
                'step': step,
                'reward': reward,
                'done': done,
                'timestamp': timestamp
            }

            # 添加动作字段
            for i, action in enumerate(actions):
                record[f'action_{i+1}'] = action

            # 添加状态字段
            for i, state in enumerate(states):
                record[f'state_{i+1}'] = state

            # 提取关键指标（如果动作或状态为空，会抛出 NumPy 警告 —— 但这里假设训练数据合理）
            try:
                record.update(self._extract_key_metrics(states, actions))
            except Exception as e:
                print(f"⚠️ 提取关键指标时遇到问题（文件 {file_name}，step {step}）：{e}")

            records.append(record)

        df = pd.DataFrame(records)
        if len(df) == 0:
            print("⚠️ DataFrame 为空（没有有效记录）")
            return df

        # 强制有关列为数值类型，避免绘图错误
        numeric_cols = ['step', 'reward',
                        'action_mean', 'action_std', 'action_min', 'action_max',
                        'avg_flow_rate', 'max_flow_rate', 'min_flow_rate',
                        'avg_temperature', 'max_temperature', 'min_temperature',
                        'avg_return_temp', 'max_return_temp', 'min_return_temp']
        for col in numeric_cols:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors='coerce')

        # 对所有单独动作/action_* 列也做强制数值转换
        action_cols = [c for c in df.columns if c.startswith('action_')]
        for c in action_cols:
            df[c] = pd.to_numeric(df[c], errors='coerce')

        # 对 step 做排序（若 step 存在）
        if 'step' in df.columns:
            df = df.sort_values(by='step').reset_index(drop=True)

        print(f"📊 转换完成，生成 {len(df)} 行 × {len(df.columns)} 列的数据表")
        return df

    def _extract_key_metrics(self, states: List[float], actions: List[float]) -> Dict[str, float]:
        """
        提取关键性能指标（和原始逻辑一致）
        """
        metrics: Dict[str, float] = {}

        # 动作统计
        arr_actions = np.array(actions, dtype=float) if len(actions) > 0 else np.array([np.nan])
        metrics['action_mean'] = float(np.nanmean(arr_actions))
        metrics['action_std'] = float(np.nanstd(arr_actions))
        metrics['action_min'] = float(np.nanmin(arr_actions))
        metrics['action_max'] = float(np.nanmax(arr_actions))

        # 状态统计
        if len(states) >= 4:
            flow_indices = self.state_mapping['flow_rates'][:min(5, len(self.state_mapping['flow_rates']))]
            flows = [states[i] for i in flow_indices if i < len(states)]
            if flows:
                arr = np.array(flows, dtype=float)
                metrics['avg_flow_rate'] = float(np.nanmean(arr))
                metrics['max_flow_rate'] = float(np.nanmax(arr))
                metrics['min_flow_rate'] = float(np.nanmin(arr))

            temp_indices = self.state_mapping['temperatures'][:min(5, len(self.state_mapping['temperatures']))]
            temps = [states[i] for i in temp_indices if i < len(states)]
            if temps:
                arr = np.array(temps, dtype=float)
                metrics['avg_temperature'] = float(np.nanmean(arr))
                metrics['max_temperature'] = float(np.nanmax(arr))
                metrics['min_temperature'] = float(np.nanmin(arr))

            return_temp_indices = self.state_mapping['return_temps'][:min(5, len(self.state_mapping['return_temps']))]
            rtemps = [states[i] for i in return_temp_indices if i < len(states)]
            if rtemps:
                arr = np.array(rtemps, dtype=float)
                metrics['avg_return_temp'] = float(np.nanmean(arr))
                metrics['max_return_temp'] = float(np.nanmax(arr))
                metrics['min_return_temp'] = float(np.nanmin(arr))

        return metrics

    def save_to_csv(self, df: pd.DataFrame, file_name: str) -> Path:
        """
        保存 DataFrame 到 CSV（保留）
        """
        csv_name = f"{Path(file_name).stem}_converted.csv"
        csv_path = self.output_dir / 'csv_data' / csv_name

        try:
            df.to_csv(csv_path, index=False, encoding='utf-8-sig')
            print(f"💾 CSV 文件已保存: {csv_path}")
        except Exception as e:
            print(f"❌ 保存 CSV 失败: {e}")

        return csv_path

    # ---------- 绘图辅助函数 ----------
    @staticmethod
    def _annotate_box(ax, text: str, loc: Tuple[float, float] = (0.98, 0.02)):
        """
        在子图右下角放一个半透明说明框
        loc: 相对于 axes 的坐标 (x, y)，右下角为默认
        """
        ax.text(
            loc[0], loc[1], text,
            transform=ax.transAxes,
            fontsize=9,
            ha='right', va='bottom',
            bbox=dict(facecolor='white', alpha=0.75, edgecolor='none', boxstyle='round,pad=0.3')
        )

    @staticmethod
    def _last_valid_point(df: pd.DataFrame, col: str) -> Optional[Tuple[float, float]]:
        """
        返回列 col 的最后一个有效（非 NaN）点 (step, value)，没有则返回 None
        """
        if col not in df.columns:
            return None
        series = df[col].dropna()
        if series.empty:
            return None
        idx = series.index[-1]
        step = float(df.loc[idx, 'step']) if 'step' in df.columns else float(idx)
        val = float(series.iloc[-1])
        return step, val

    # ---------- 可视化方法（在每张子图上增加说明与标注） ----------
    def create_action_visualization(self, df: pd.DataFrame, file_name: str) -> None:
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))
        suptitle = (f'动作调整分析 - {Path(file_name).stem}\n'
                    '说明：每个动作表示对应阀门的开度调整（数值范围依数据而定）；下方统计框显示该子图的均值/最小/最大等信息。')
        fig.suptitle(suptitle, fontsize=14, fontweight='bold')

        # 保证需要列存在并为数值
        if 'action_mean' in df.columns:
            axes[0, 0].plot(df['step'], df['action_mean'], linewidth=2, alpha=0.9)
            axes[0, 0].set_title('动作均值变化趋势（所有阀门开度的平均值）', fontsize=11, fontweight='bold')
            axes[0, 0].set_xlabel('训练步数')
            axes[0, 0].set_ylabel('动作均值')
            axes[0, 0].grid(True, alpha=0.3)

            # 注释均值/最大/最小
            m = df['action_mean'].mean()
            mn = df['action_mean'].min()
            mx = df['action_mean'].max()
            self._annotate_box(axes[0, 0], f"均值: {m:.4f}\n最小: {mn:.4f}\n最大: {mx:.4f}")

        if 'action_std' in df.columns:
            axes[0, 1].plot(df['step'], df['action_std'], linewidth=2, alpha=0.9)
            axes[0, 1].set_title('动作标准差（开度波动性）', fontsize=11, fontweight='bold')
            axes[0, 1].set_xlabel('训练步数')
            axes[0, 1].set_ylabel('动作标准差')
            axes[0, 1].grid(True, alpha=0.3)

            m = df['action_std'].mean()
            self._annotate_box(axes[0, 1], f"均值(Std): {m:.4f}")

        # 动作范围
        if all(c in df.columns for c in ['action_min', 'action_max']):
            axes[1, 0].fill_between(df['step'], df['action_min'], df['action_max'], alpha=0.25)
            axes[1, 0].plot(df['step'], df['action_min'], '--', alpha=0.7, label='最小值')
            axes[1, 0].plot(df['step'], df['action_max'], '-', alpha=0.7, label='最大值')
            axes[1, 0].set_title('动作范围（最小/最大阀门开度区间）', fontsize=11, fontweight='bold')
            axes[1, 0].set_xlabel('训练步数')
            axes[1, 0].set_ylabel('动作值')
            axes[1, 0].legend()
            axes[1, 0].grid(True, alpha=0.3)

            # 标注全局最大/最小出现的位置
            try:
                idx_max = df['action_max'].idxmax()
                axes[1, 0].annotate(
                    f"全局最大: {df.loc[idx_max, 'action_max']:.3f}\n(step={int(df.loc[idx_max, 'step'])})",
                    xy=(df.loc[idx_max, 'step'], df.loc[idx_max, 'action_max']),
                    xytext=(10, 10), textcoords='offset points',
                    arrowprops=dict(arrowstyle='->', lw=0.8)
                )
            except Exception:
                pass

        # 前若干阀门单独曲线（默认前5）
        ax_valves = axes[1, 1]
        max_valves_to_show = 5
        plotted = 0
        for i in range(0, 23):  # 保留原来的上限 23
            col = f'action_{i+1}'
            if col in df.columns and plotted < max_valves_to_show:
                ax_valves.plot(df['step'], df[col], label=f'阀门{i+1}', linewidth=1.2, alpha=0.8)
                # 在每条曲线最后标注数值
                last = self._last_valid_point(df, col)
                if last:
                    x_last, y_last = last
                    ax_valves.annotate(f"{y_last:.2f}", xy=(x_last, y_last),
                                       xytext=(6, 0), textcoords='offset points', fontsize=8)
                plotted += 1

        ax_valves.set_title(f'前{max_valves_to_show}个阀门动作变化（每条曲线为对应阀门开度随步数变化）', fontsize=11, fontweight='bold')
        ax_valves.set_xlabel('训练步数')
        ax_valves.set_ylabel('阀门开度')
        ax_valves.legend(loc='upper left', bbox_to_anchor=(1.02, 1.0))
        ax_valves.grid(True, alpha=0.3)

        plt.tight_layout(rect=[0, 0, 1, 0.95])
        plot_path = self.output_dir / 'visualizations' / f'{Path(file_name).stem}_actions.png'
        fig.savefig(plot_path, dpi=300, bbox_inches='tight')
        plt.close(fig)
        print(f"📈 动作分析图表已保存: {plot_path}")

    def create_temperature_visualization(self, df: pd.DataFrame, file_name: str) -> None:
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))
        suptitle = (f'温度变化分析 - {Path(file_name).stem}\n'
                    '说明：图中“平均温度”取若干代表节点的平均，回水温度为系统回水侧温度平均值。')
        fig.suptitle(suptitle, fontsize=14, fontweight='bold')

        # 平均温度
        if 'avg_temperature' in df.columns:
            ax = axes[0, 0]
            ax.plot(df['step'], df['avg_temperature'], linewidth=2)
            ax.set_title('平均温度随训练步数变化（°C）', fontsize=11, fontweight='bold')
            ax.set_xlabel('训练步数')
            ax.set_ylabel('平均温度 (°C)')
            ax.grid(True, alpha=0.3)
            mean_v = df['avg_temperature'].mean()
            ax.text(0.02, 0.95, f"总体均值: {mean_v:.2f}°C", transform=ax.transAxes, va='top',
                    bbox=dict(facecolor='white', alpha=0.75))

            # 标注最大点
            try:
                idx_max = df['avg_temperature'].idxmax()
                ax.annotate(f"峰值: {df.loc[idx_max,'avg_temperature']:.2f}°C\n(step={int(df.loc[idx_max,'step'])})",
                            xy=(df.loc[idx_max,'step'], df.loc[idx_max,'avg_temperature']),
                            xytext=(10, -30), textcoords='offset points',
                            arrowprops=dict(arrowstyle='->', lw=0.8))
            except Exception:
                pass

        # 平均回水温度
        if 'avg_return_temp' in df.columns:
            ax = axes[0, 1]
            ax.plot(df['step'], df['avg_return_temp'], linewidth=2)
            ax.set_title('平均回水温度随训练步数变化（°C）', fontsize=11, fontweight='bold')
            ax.set_xlabel('训练步数')
            ax.set_ylabel('回水温度 (°C)')
            ax.grid(True, alpha=0.3)
            mean_v = df['avg_return_temp'].mean()
            self._annotate_box(ax, f"回水均值: {mean_v:.2f}°C")

        # 温度范围
        if all(col in df.columns for col in ['min_temperature', 'max_temperature']):
            ax = axes[1, 0]
            ax.fill_between(df['step'], df['min_temperature'], df['max_temperature'], alpha=0.25)
            ax.plot(df['step'], df['min_temperature'], '--', alpha=0.7)
            ax.plot(df['step'], df['max_temperature'], '-', alpha=0.7)
            ax.set_title('温度范围（最低/最高）', fontsize=11, fontweight='bold')
            ax.set_xlabel('训练步数')
            ax.set_ylabel('温度 (°C)')
            ax.grid(True, alpha=0.3)
            self._annotate_box(ax, f"最小(总体): {df['min_temperature'].min():.2f}°C\n最大(总体): {df['max_temperature'].max():.2f}°C")

        # 回水温度范围
        if all(col in df.columns for col in ['min_return_temp', 'max_return_temp']):
            ax = axes[1, 1]
            ax.fill_between(df['step'], df['min_return_temp'], df['max_return_temp'], alpha=0.25)
            ax.plot(df['step'], df['min_return_temp'], '--', alpha=0.7)
            ax.plot(df['step'], df['max_return_temp'], '-', alpha=0.7)
            ax.set_title('回水温度范围（最低/最高）', fontsize=11, fontweight='bold')
            ax.set_xlabel('训练步数')
            ax.set_ylabel('回水温度 (°C)')
            ax.grid(True, alpha=0.3)
            self._annotate_box(ax, f"回水温度范围\n{df['min_return_temp'].min():.2f}°C - {df['max_return_temp'].max():.2f}°C")

        plt.tight_layout(rect=[0, 0, 1, 0.95])
        plot_path = self.output_dir / 'visualizations' / f'{Path(file_name).stem}_temperatures.png'
        fig.savefig(plot_path, dpi=300, bbox_inches='tight')
        plt.close(fig)
        print(f"🌡️ 温度分析图表已保存: {plot_path}")

    def create_flow_visualization(self, df: pd.DataFrame, file_name: str) -> None:
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))
        suptitle = (f'流速变化分析 - {Path(file_name).stem}\n'
                    '说明：平均流速在多个节点上的统计值，可用来观察系统供水/回水流动特征。')
        fig.suptitle(suptitle, fontsize=14, fontweight='bold')

        # 平均流速
        if 'avg_flow_rate' in df.columns:
            ax = axes[0, 0]
            ax.plot(df['step'], df['avg_flow_rate'], linewidth=2)
            ax.set_title('平均流速随训练步数变化', fontsize=11, fontweight='bold')
            ax.set_xlabel('训练步数')
            ax.set_ylabel('平均流速 (m³/h)')
            ax.grid(True, alpha=0.3)
            self._annotate_box(ax, f"平均流速: {df['avg_flow_rate'].mean():.3f} m³/h")

        # 流速范围
        if all(col in df.columns for col in ['min_flow_rate', 'max_flow_rate']):
            ax = axes[0, 1]
            ax.fill_between(df['step'], df['min_flow_rate'], df['max_flow_rate'], alpha=0.25)
            ax.plot(df['step'], df['min_flow_rate'], '--', alpha=0.7)
            ax.plot(df['step'], df['max_flow_rate'], '-', alpha=0.7)
            ax.set_title('流速范围（最小/最大）', fontsize=11, fontweight='bold')
            ax.set_xlabel('训练步数')
            ax.set_ylabel('流速 (m³/h)')
            ax.grid(True, alpha=0.3)
            self._annotate_box(ax, f"整体范围: {df['min_flow_rate'].min():.3f} - {df['max_flow_rate'].max():.3f} m³/h")

        # 奖励 vs 平均流速（散点）
        if 'avg_flow_rate' in df.columns and 'reward' in df.columns:
            ax = axes[1, 0]
            scatter = ax.scatter(df['avg_flow_rate'], df['reward'], c=df['step'], cmap='viridis', alpha=0.7)
            ax.set_title('奖励与平均流速关系（颜色表示训练步数）', fontsize=11, fontweight='bold')
            ax.set_xlabel('平均流速 (m³/h)')
            ax.set_ylabel('奖励值')
            ax.grid(True, alpha=0.3)
            fig.colorbar(scatter, ax=ax, label='训练步数')

        # 流速变化率
        if 'avg_flow_rate' in df.columns and len(df) > 1:
            ax = axes[1, 1]
            flow_change = df['avg_flow_rate'].diff().fillna(0)
            ax.plot(df['step'], flow_change, linewidth=2)
            ax.axhline(0, ls='--', alpha=0.6)
            ax.set_title('平均流速变化率（相邻步差值）', fontsize=11, fontweight='bold')
            ax.set_xlabel('训练步数')
            ax.set_ylabel('流速变化率 (m³/h/step)')
            ax.grid(True, alpha=0.3)
            self._annotate_box(ax, f"平均变化率: {flow_change.mean():.4f} m³/h/step")

        plt.tight_layout(rect=[0, 0, 1, 0.95])
        plot_path = self.output_dir / 'visualizations' / f'{Path(file_name).stem}_flows.png'
        fig.savefig(plot_path, dpi=300, bbox_inches='tight')
        plt.close(fig)
        print(f"💧 流速分析图表已保存: {plot_path}")

    def create_comprehensive_analysis(self, df: pd.DataFrame, file_name: str) -> None:
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))
        suptitle = f'综合训练分析 - {Path(file_name).stem}\n（奖励、动作均值及训练稳定性概览）'
        fig.suptitle(suptitle, fontsize=14, fontweight='bold')

        # 奖励变化趋势
        ax = axes[0, 0]
        ax.plot(df['step'], df['reward'], linewidth=2, alpha=0.9)
        ax.set_title('奖励随训练步数变化', fontsize=11, fontweight='bold')
        ax.set_xlabel('训练步数')
        ax.set_ylabel('奖励值')
        ax.grid(True, alpha=0.3)
        self._annotate_box(ax, f"平均奖励: {df['reward'].mean():.4f}\n最高奖励: {df['reward'].max():.4f}")

        # 动作均值 vs 奖励（散点）
        if 'action_mean' in df.columns:
            ax2 = axes[0, 1]
            scatter = ax2.scatter(df['action_mean'], df['reward'], c=df['step'], cmap='plasma', alpha=0.7)
            ax2.set_title('动作均值与奖励关系（颜色表示训练步数）', fontsize=11, fontweight='bold')
            ax2.set_xlabel('动作均值')
            ax2.set_ylabel('奖励值')
            ax2.grid(True, alpha=0.3)
            fig.colorbar(scatter, ax=ax2, label='训练步数')

        # 动作均值与奖励的双轴趋势对比
        ax = axes[1, 0]
        if 'action_mean' in df.columns:
            l1 = ax.plot(df['step'], df['action_mean'], label='动作均值', alpha=0.9)
            ax.set_xlabel('训练步数')
            ax.set_ylabel('动作均值', color='tab:blue')
            ax.tick_params(axis='y', labelcolor='tab:blue')

            axb = ax.twinx()
            l2 = axb.plot(df['step'], df['reward'], label='奖励值', color='tab:red', alpha=0.7)
            axb.set_ylabel('奖励值', color='tab:red')
            axb.tick_params(axis='y', labelcolor='tab:red')

            # 合并图例
            lines = l1 + l2
            labels = [ln.get_label() for ln in lines]
            ax.legend(lines, labels, loc='upper left')
        ax.set_title('动作均值与奖励趋势对比', fontsize=11, fontweight='bold')
        ax.grid(True, alpha=0.3)

        # 训练稳定性（滑动平均）
        ax = axes[1, 1]
        if len(df) > 10:
            window = min(10, max(3, len(df) // 10))
            reward_ma = df['reward'].rolling(window=window, min_periods=1).mean()
            ax.plot(df['step'], df['reward'], color='lightgray', alpha=0.6, label='原始奖励')
            ax.plot(df['step'], reward_ma, color='darkred', linewidth=2, label=f'{window} 步滑动平均')
            ax.set_title('训练稳定性（滑动平均对比）', fontsize=11, fontweight='bold')
            ax.set_xlabel('训练步数')
            ax.set_ylabel('奖励值')
            ax.legend()
            ax.grid(True, alpha=0.3)
            self._annotate_box(ax, f"最近 {window} 步滑动平均（最后值）: {reward_ma.iloc[-1]:.4f}")

        plt.tight_layout(rect=[0, 0, 1, 0.95])
        plot_path = self.output_dir / 'visualizations' / f'{Path(file_name).stem}_comprehensive.png'
        fig.savefig(plot_path, dpi=300, bbox_inches='tight')
        plt.close(fig)
        print(f"📊 综合分析图表已保存: {plot_path}")

    def generate_analysis_report(self, df: pd.DataFrame, file_name: str) -> None:
        report_path = self.output_dir / 'analysis_reports' / f'{Path(file_name).stem}_report.txt'

        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("训练数据分析报告\n")
            f.write("=" * 50 + "\n")
            f.write(f"文件名: {file_name}\n")
            f.write(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

            f.write("基础统计信息:\n")
            f.write("-" * 30 + "\n")
            f.write(f"总训练步数: {len(df)}\n")
            if 'step' in df.columns:
                try:
                    duration = int(df['step'].max() - df['step'].min() + 1)
                except Exception:
                    duration = len(df)
                f.write(f"训练时长 (步数): {duration}\n")
            if 'reward' in df.columns:
                f.write(f"平均奖励: {df['reward'].mean():.4f}\n")
                f.write(f"最高奖励: {df['reward'].max():.4f}\n")
                f.write(f"最低奖励: {df['reward'].min():.4f}\n")
                f.write(f"奖励标准差: {df['reward'].std():.4f}\n\n")

            # 动作统计
            if 'action_mean' in df.columns:
                f.write("动作统计信息:\n")
                f.write("-" * 30 + "\n")
                f.write(f"平均动作值: {df['action_mean'].mean():.4f}\n")
                if 'action_min' in df.columns and 'action_max' in df.columns:
                    f.write(f"动作变化范围: {df['action_min'].min():.4f} - {df['action_max'].max():.4f}\n")
                f.write(f"平均动作标准差: {df['action_std'].mean():.4f}\n\n")

            # 温度统计
            if 'avg_temperature' in df.columns:
                f.write("温度统计信息:\n")
                f.write("-" * 30 + "\n")
                f.write(f"平均温度: {df['avg_temperature'].mean():.2f}°C\n")
                if 'min_temperature' in df.columns and 'max_temperature' in df.columns:
                    f.write(f"温度范围: {df['min_temperature'].min():.2f}°C - {df['max_temperature'].max():.2f}°C\n")
                if 'avg_return_temp' in df.columns:
                    f.write(f"平均回水温度: {df['avg_return_temp'].mean():.2f}°C\n")
                f.write("\n")

            # 流速统计
            if 'avg_flow_rate' in df.columns:
                f.write("流速统计信息:\n")
                f.write("-" * 30 + "\n")
                f.write(f"平均流速: {df['avg_flow_rate'].mean():.2f} m³/h\n")
                if 'min_flow_rate' in df.columns and 'max_flow_rate' in df.columns:
                    f.write(f"流速范围: {df['min_flow_rate'].min():.2f} - {df['max_flow_rate'].max():.2f} m³/h\n")
                f.write("\n")

            # 训练趋势
            f.write("训练趋势分析:\n")
            f.write("-" * 30 + "\n")
            if 'reward' in df.columns:
                first_half = df.iloc[:len(df) // 2]['reward'].mean()
                second_half = df.iloc[len(df) // 2:]['reward'].mean()
                trend = "上升" if second_half > first_half else "下降"
                f.write(f"奖励趋势: {trend} (前半段: {first_half:.4f}, 后半段: {second_half:.4f})\n")

            if len(df) > 10 and 'reward' in df.columns:
                recent_std = df.iloc[-10:]['reward'].std()
                overall_std = df['reward'].std()
                stability = "稳定" if recent_std < overall_std else "不稳定"
                f.write(f"训练稳定性: {stability} (近期标准差: {recent_std:.4f}, 整体标准差: {overall_std:.4f})\n")

        print(f"📋 分析报告已保存: {report_path}")

    def process_single_file(self, json_file: Path) -> bool:
        try:
            print(f"\n🔄 开始处理文件: {json_file.name}")

            # 加载数据
            json_data = self.load_json_data(json_file)
            if not json_data:
                return False

            # 转换为 DataFrame
            df = self.convert_to_dataframe(json_data, json_file.name)
            if df.empty:
                print(f"⚠️ 文件 {json_file.name} 转换为 DataFrame 为空，跳过。")
                return False

            # 保存 CSV（保留）
            self.save_to_csv(df, json_file.name)

            # 生成可视化（每个函数内部会检查是否有需要的列）
            self.create_action_visualization(df, json_file.name)
            self.create_temperature_visualization(df, json_file.name)
            self.create_flow_visualization(df, json_file.name)
            self.create_comprehensive_analysis(df, json_file.name)

            # 生成报告
            self.generate_analysis_report(df, json_file.name)

            print(f"✅ 文件处理完成: {json_file.name}")
            return True

        except Exception as e:
            print(f"❌ 处理文件失败: {json_file.name}，错误: {e}")
            return False

    def process_all_files(self) -> None:
        json_files = list(self.input_dir.glob('*.json'))

        if not json_files:
            print(f"❌ 在目录 {self.input_dir} 中未找到 JSON 文件")
            return

        print(f"🚀 开始批量处理，共找到 {len(json_files)} 个 JSON 文件")

        success_count = 0
        for json_file in json_files:
            if self.process_single_file(json_file):
                success_count += 1

        print(f"\n🎉 批量处理完成！")
        print(f"📊 成功处理: {success_count}/{len(json_files)} 个文件")
        print(f"📁 结果保存在: {self.output_dir}")
        print(f"   ├── csv_data/        - CSV格式数据")
        print(f"   ├── visualizations/  - 可视化图表")
        print(f"   └── analysis_reports/ - 分析报告")


def main():
    # 路径（按需改）
    input_dir = "../offline_data"
    output_dir = "."

    converter = OfflineDataConverter(input_dir, output_dir)
    converter.process_all_files()


if __name__ == "__main__":
    main()
