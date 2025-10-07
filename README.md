# 强化学习与Dymola仿真系统

## 项目简介

本项目是一个基于强化学习的供热网络仿真优化系统，结合了Dymola仿真环境和IQL（Implicit Q-Learning）算法，用于优化供热网络中阀门开度的控制策略。

PPO相关算法由于网络输出与已有的数据点匹配度较低，尝试多种方法均无法提供有效、准确的动作提示，故未训练出较优秀的模型，未集成到实际的dymola仿真循环中。但代码和思路是完整的，如果仿真数据量足够是完全可行的。但0.5-1的阀门开度是连续的，如果要求23维数据匹配距离至少小于0.3的话，数据量是几十上百万条的，这个开销不值得。

在仿真过程中，rl_dymola_simulation目录下会生成一系列的仿真文件，这是dymola编译过程的结果，可以不用在意

## 系统架构

```
交付/
├── reinforcement_learning/          # 强化学习模块
│   ├── agents/                     # 智能体实现
│   ├── config/                     # 配置文件
│   ├── environment/                # 环境定义
│   ├── trainer/                    # 训练器
│   └── utils/                      # 工具函数
└── rl_dymola_simulation/           # Dymola仿真模块
    ├── core/                       # 核心组件
    ├── config/                     # 仿真配置
    ├── utils/                      # 仿真工具
    └── models/                     # 模型文件
```

## 环境要求

### 软件依赖
- Python 3.8+
- Dymola 2023或更高版本

### Python包依赖
主要依赖包已在`reinforcement_learning/requirements.txt`中定义：
- torch
- numpy
- DyMat
- matplotlib
- 其他相关包

## 安装与配置

### 1. 环境准备

```bash
# 进入项目目录
cd f:\A1_python_project\交付

# 激活虚拟环境
.venv\Scripts\Activate.ps1

# 安装依赖
pip install -r reinforcement_learning/requirements.txt
```

### 2. Dymola配置

确保Dymola已正确安装并配置环境变量，系统能够找到Dymola的安装路径。

### 3. 模型文件准备

确保以下文件存在：
- `rl_dymola_simulation/HeatingNetwork_20250316.mo` - Dymola模型文件
- `rl_dymola_simulation/iql_model_final.pth` - 训练好的IQL模型

## 使用说明

### 主要启动方式

#### 1. 仿真循环启动

这是系统的主要入口，用于运行强化学习控制的仿真循环：

```bash
# 基本启动（默认参数）
python rl_dymola_simulation/iql_dymola_simulation_loop.py

# 自定义参数启动
python rl_dymola_simulation/iql_dymola_simulation_loop.py --iterations 5 --interval 60
```

**参数说明：**
- `--iterations`: 仿真迭代次数（默认：10）
- `--interval`: 每次迭代间隔时间，单位秒（默认：30）
- `--config`: 配置文件路径（可选）

#### 2. 强化学习训练启动

如需重新训练模型：

```bash
# 激活虚拟环境
.venv\Scripts\Activate.ps1

# 进入强化学习目录
cd reinforcement_learning

# 启动IQL训练
python start_improved_iql_training.py
```

### 配置文件说明

#### 仿真配置
- `rl_dymola_simulation/config/simulation_config.json` - 仿真参数配置
- `rl_dymola_simulation/config/config_efficient.json` - 高效仿真配置

#### 强化学习配置
- `reinforcement_learning/config/improved_iql_config.json` - IQL算法配置
- `reinforcement_learning/config/custom_config.json` - 自定义配置

### 系统运行流程

1. **初始化阶段**
   - 加载IQL模型
   - 初始化Dymola接口
   - 准备仿真环境

2. **仿真循环**
   - IQL智能体决策阀门开度
   - 更新Modelica模型文件
   - 执行Dymola仿真
   - 读取仿真结果
   - 计算奖励并记录

3. **结果输出**（根目录下）
   - 仿真日志：`iql_simulation.log`
   - 结果数据：`iql_simulation_results.json`

## 日志与监控

### 日志文件位置
- 仿真日志：`iql_simulation.log`
- 训练日志：`reinforcement_learning/logs/`
- Dymola日志：`rl_dymola_simulation/buildlog.txt`

### 监控指标
- 仿真成功率
- 回水温度
- 阀门开度调整
- 奖励值变化

## 故障排除

### 常见问题

1. **Dymola连接失败**
   - 检查Dymola是否正确安装
   - 确认Dymola许可证有效
   - 重启Dymola服务

### 查看帮助信息

```bash
python rl_dymola_simulation/iql_dymola_simulation_loop.py --help
```

## 性能优化建议

1. **仿真参数调优**
   - 根据硬件性能调整迭代间隔
   - 优化Dymola仿真精度设置

2. **系统资源管理**
   - 定期清理临时文件
   - 监控内存使用情况

3. **模型优化**
   - 调整奖励函数参数

## 扩展开发

### 添加新的强化学习算法
1. 在`reinforcement_learning/agents/`中实现新算法
2. 在`reinforcement_learning/trainer/`中添加对应训练器
3. 更新配置文件

### 修改仿真环境
1. 编辑`rl_dymola_simulation/heating_environment_efficient.py`
2. 调整状态空间和动作空间定义
3. 更新奖励函数计算

