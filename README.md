# 供热网络强化学习系统 - 高效版本

**作者**: Dionysus  
**日期**: 2025-08-08

## 概述

这是供热网络强化学习系统的高效版本，基于成功的v2版本进行优化，主要特点包括：

- ✅ **真正的Dymola仿真**: 确保每次都启动Dymola进行实际仿真
- ✅ **移除不必要检查**: 跳过模型检查步骤，提高仿真效率
- ✅ **离线数据收集**: 自动保存每次仿真结果，方便后续算法开发
- ✅ **优化训练流程**: 减少仿真频率，批量更新策略
- ✅ **完整的日志系统**: 详细记录训练过程和仿真状态

## 系统架构

```
efficient_rl/
├── heating_environment_efficient.py  # 高效环境实现
├── trainer_efficient.py             # 高效训练器
├── main_efficient.py               # 主程序
├── test_efficient.py               # 测试脚本
├── requirements.txt                 # 依赖包列表
├── README.md                       # 说明文档
├── HeatingNetwork_20250316.mo      # Modelica模型文件
├── dymosim.exe                     # Dymola仿真执行文件
└── offline_data/                   # 离线数据存储目录
```

## 环境要求

### 软件要求
- Python 3.8+
- Dymola 2020 或更高版本
- Windows 操作系统

### Python依赖
```bash
pip install -r requirements.txt
```

### Dymola配置
确保以下文件在Python路径中可用：
- `dymola.dymola_interface`
- `DyMat`

通常这些文件位于Dymola安装目录的`Modelica/Library/python_interface/`下。

## 快速开始

### 1. 测试系统

首先运行测试脚本确保系统正常工作：

```bash
cd efficient_rl
python test_efficient.py
```

测试包括：
- 环境基本功能测试
- 训练器基本功能测试
- 环境和训练器集成测试

### 2. 训练智能体

使用默认配置开始训练：

```bash
python main_efficient.py --mode train
```

使用自定义配置：

```bash
python main_efficient.py --mode train --config my_config.json --log-level DEBUG
```

### 3. 测试环境

仅测试环境功能（不进行训练）：

```bash
python main_efficient.py --mode test
```

## 配置说明

系统使用JSON格式的配置文件，主要参数包括：

### 环境配置
```json
{
  "num_buildings": 26,           // 楼栋数量（跳过8号阀门）
  "max_steps": 50,              // 每个episode最大步数
  "simulation_time": 3600,       // 仿真时间（秒）
  "target_return_temp": 30.0,    // 目标回水温度（°C）
  "dymola_visible": false        // Dymola界面是否可见
}
```

### 训练配置
```json
{
  "state_dim": 104,              // 状态维度（26*4）
  "action_dim": 26,              // 动作维度（26个阀门）
  "hidden_dim": 128,             // 神经网络隐藏层维度
  "learning_rate": 3e-4,         // 学习率
  "batch_size": 32,              // 批次大小
  "update_frequency": 5,         // 更新频率（每5步更新一次）
  "total_episodes": 1000,        // 总训练episode数
  "save_frequency": 50           // 模型保存频率
}
```

## 核心功能

### 1. 高效环境 (HeatingEnvironmentEfficient)

**主要改进**：
- 跳过模型检查步骤，直接运行仿真
- 自动保存离线数据到JSON文件
- 优化状态计算和奖励函数
- 完善的错误处理和日志记录

**关键方法**：
- `reset()`: 重置环境，设置随机初始阀门开度
- `step(action)`: 执行动作，运行仿真，返回状态和奖励
- `_run_simulation()`: 运行Dymola仿真（跳过检查）
- `_save_offline_data()`: 保存离线数据

### 2. 高效训练器 (TrainerEfficient)

**算法**: PPO (Proximal Policy Optimization)

**网络结构**:
- Actor-Critic架构
- 共享特征提取层
- 连续动作空间（阀门开度0-1）

**训练特点**:
- GAE (Generalized Advantage Estimation)
- 梯度裁剪防止训练不稳定
- 定期保存模型和统计信息

### 3. 离线数据系统

**数据格式**:
```json
[
  {
    "step": 1,
    "action": [0.5, 0.6, ...],      // 阀门开度
    "state": [0.1, 0.2, ...],       // 系统状态
    "reward": 1.5,                  // 奖励值
    "done": false,                  // 是否结束
    "timestamp": "2025-08-08T19:30:00"
  }
]
```

**存储策略**:
- 每100步或episode结束时保存
- 文件命名：`offline_data_{instance_id}_{timestamp}.json`
- 自动创建`offline_data/`目录

## 训练目标

系统的训练目标是使所有楼栋的回水温度保持在30°C，奖励函数包括：

1. **温度控制奖励**（主要）：
   - 误差≤1°C：+1.0
   - 误差≤2°C：+0.5
   - 误差≤5°C：+0.1
   - 误差>5°C：-0.1×误差

2. **供水温度合理性**：
   - 供水温度<回水温度：-0.5
   - 供水温度>80°C：-0.2

3. **能耗控制**：
   - 阀门开度适中(0.3-0.7)：+0.1
   - 否则：-0.1

4. **流量稳定性**：
   - 所有楼栋流量>0.1：+0.2

## 监控和调试

### 日志系统
- 控制台输出：实时显示训练进度
- 文件日志：详细记录保存到`.log`文件
- 日志级别：DEBUG, INFO, WARNING, ERROR

### 训练统计
- Episode奖励和长度
- 策略更新损失
- 离线数据统计
- 模型保存记录

### 文件输出
```
efficient_training_results/
├── models/
│   ├── model_episode_50.pth
│   ├── model_episode_100.pth
│   └── ...
├── stats/
│   ├── training_stats_50.json
│   ├── training_stats_100.json
│   └── ...
offline_data/
├── offline_data_1001_20250808_193000.json
├── offline_data_1002_20250808_194500.json
└── ...
```

## 性能优化

### 已实现的优化
1. **跳过模型检查**：减少每次仿真的开销
2. **批量更新**：减少策略更新频率
3. **小批次训练**：降低内存使用
4. **异步数据保存**：不阻塞训练流程

### 建议的进一步优化
1. **并行仿真**：多个Dymola实例同时运行
2. **经验回放**：利用离线数据进行额外训练
3. **模型压缩**：减小网络规模提高推理速度
4. **预训练模型**：使用历史数据预训练

## 故障排除

### 常见问题

1. **Dymola连接失败**
   - 检查Dymola是否正确安装
   - 确认Python接口路径正确
   - 验证许可证是否有效

2. **仿真结果全为零**
   - 检查模型文件是否存在
   - 验证阀门参数名称是否正确
   - 查看Dymola错误日志

3. **训练不收敛**
   - 调整学习率和网络结构
   - 检查奖励函数设计
   - 增加训练episode数

4. **内存不足**
   - 减小批次大小
   - 降低网络隐藏层维度
   - 增加更新频率

### 调试技巧

1. **启用详细日志**：
   ```bash
   python main_efficient.py --log-level DEBUG
   ```

2. **检查离线数据**：
   ```python
   import json
   with open('offline_data/offline_data_xxx.json', 'r') as f:
       data = json.load(f)
   print(f"数据点数: {len(data)}")
   ```

3. **监控仿真状态**：
   查看生成的`.mat`文件和Dymola日志文件

## 扩展开发

### 添加新的奖励函数

在`heating_environment_efficient.py`中修改`_calculate_reward`方法：

```python
def _calculate_reward(self, state, action):
    # 现有奖励计算
    reward = ...
    
    # 添加新的奖励项
    custom_reward = self._calculate_custom_reward(state, action)
    reward += custom_reward
    
    return reward
```

### 修改网络结构

在`trainer_efficient.py`中修改`ActorCritic`类：

```python
class ActorCritic(nn.Module):
    def __init__(self, state_dim, action_dim, hidden_dim):
        super().__init__()
        # 修改网络结构
        self.shared_layers = nn.Sequential(
            nn.Linear(state_dim, hidden_dim),
            nn.BatchNorm1d(hidden_dim),  # 添加批归一化
            nn.ReLU(),
            nn.Dropout(0.1),             # 添加Dropout
            # ...
        )
```

### 集成新的算法

可以基于现有框架实现其他强化学习算法：
- SAC (Soft Actor-Critic)
- TD3 (Twin Delayed DDPG)
- A3C (Asynchronous Actor-Critic)

## 许可证

本项目仅供学术研究使用。

## 联系方式

如有问题或建议，请联系开发者。

---

**注意**: 使用本系统前请确保已正确安装和配置Dymola环境。