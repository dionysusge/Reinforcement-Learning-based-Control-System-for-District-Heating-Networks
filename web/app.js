/**
 * 训练结果查看器前端应用
 * 作者: Dionysus
 * 日期: 2025-01-09
 */

class TrainingResultViewer {
    constructor() {
        this.sessions = [];
        this.currentTensorBoard = null;
        this.init();
    }

    /**
     * 初始化应用
     */
    init() {
        this.bindEvents();
        this.loadSessions();
        this.updateTensorBoardStatus();
    }

    /**
     * 绑定事件监听器
     */
    bindEvents() {
        // 刷新按钮
        document.getElementById('refreshBtn').addEventListener('click', () => {
            this.loadSessions();
        });

        // 会话选择
        document.getElementById('sessionSelect').addEventListener('change', (e) => {
            const sessionId = e.target.value;
            if (sessionId) {
                this.selectSession(sessionId);
            }
        });

        // TensorBoard控制按钮
        document.getElementById('startBtn').addEventListener('click', () => {
            const sessionId = document.getElementById('sessionSelect').value;
            if (sessionId) {
                this.startTensorBoard(sessionId);
            } else {
                this.showError('请先选择一个训练会话');
            }
        });

        document.getElementById('stopBtn').addEventListener('click', () => {
            this.stopTensorBoard();
        });

        document.getElementById('openBtn').addEventListener('click', () => {
            this.openBrowser();
        });
    }

    /**
     * 加载训练会话列表
     */
    async loadSessions() {
        try {
            this.showLoading('正在加载训练会话...');
            
            const response = await fetch('/api/sessions');
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const sessions = await response.json();
            this.sessions = sessions;
            this.renderSessionList();
            this.log('成功加载训练会话列表');
        } catch (error) {
            this.log(`加载训练会话失败: ${error.message}`, 'error');
            this.showError('加载训练会话失败，请检查服务是否正常运行');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * 渲染会话列表
     */
    renderSessionList() {
        const select = document.getElementById('sessionSelect');
        select.innerHTML = '<option value="">请选择训练会话...</option>';
        
        // 按ID降序排序（最新的在前面）
        const sortedSessions = [...this.sessions].sort((a, b) => parseInt(b.id) - parseInt(a.id));
        
        sortedSessions.forEach(session => {
            const option = document.createElement('option');
            option.value = session.id;
            option.textContent = `${session.id} - ${session.name} (${session.episodes}轮)`;
            select.appendChild(option);
        });
    }

    /**
     * 选择会话
     */
    async selectSession(sessionId) {
        try {
            this.showLoading('正在加载会话详情...');
            
            const response = await fetch(`/api/sessions/${sessionId}`);
            if (!response.ok) {
                throw new Error('无法获取会话详情');
            }
            
            const sessionInfo = await response.json();
            this.updateSessionInfo(sessionInfo);
            this.log(`已选择会话: ${sessionId}`);
        } catch (error) {
            this.log(`加载会话详情失败: ${error.message}`, 'error');
            this.showError('加载会话详情失败');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * 更新会话信息显示
     */
    updateSessionInfo(sessionInfo) {
        document.getElementById('sessionId').textContent = sessionInfo.id || '-';
        document.getElementById('sessionName').textContent = sessionInfo.name || '-';
        document.getElementById('sessionCreated').textContent = sessionInfo.created || '-';
        document.getElementById('sessionEpisodes').textContent = sessionInfo.episodes || '0';
        document.getElementById('sessionStatus').textContent = sessionInfo.status || 'unknown';
        
        // 更新路径信息
        document.getElementById('tensorboardPath').textContent = sessionInfo.tensorboardPath || '-';
        document.getElementById('modelsPath').textContent = sessionInfo.modelsPath || '-';
        document.getElementById('statsPath').textContent = sessionInfo.statsPath || '-';
        
        // 更新数据可用性
        const hasTensorboard = sessionInfo.hasTensorboard;
        const hasModels = sessionInfo.hasModels;
        const hasStats = sessionInfo.hasStats;
        
        document.getElementById('hasTensorboard').textContent = hasTensorboard ? '✅ 可用' : '❌ 不可用';
        document.getElementById('hasModels').textContent = hasModels ? '✅ 可用' : '❌ 不可用';
        document.getElementById('hasStats').textContent = hasStats ? '✅ 可用' : '❌ 不可用';
        
        // 更新统计信息
        if (sessionInfo.lastReward !== undefined) {
            document.getElementById('lastReward').textContent = sessionInfo.lastReward.toFixed(2);
        } else {
            document.getElementById('lastReward').textContent = '-';
        }
        
        if (sessionInfo.bestReward !== undefined) {
            document.getElementById('bestReward').textContent = sessionInfo.bestReward.toFixed(2);
        } else {
            document.getElementById('bestReward').textContent = '-';
        }
        
        // 根据数据可用性启用/禁用启动按钮
        const startBtn = document.getElementById('startBtn');
        if (hasTensorboard) {
            startBtn.disabled = false;
            startBtn.title = '';
        } else {
            startBtn.disabled = true;
            startBtn.title = '该会话没有TensorBoard数据';
        }
    }

    /**
     * 启动TensorBoard
     */
    async startTensorBoard(sessionId) {
        try {
            this.showLoading(`正在启动TensorBoard (会话 ${sessionId})...`);
            
            // 先获取会话详细信息
            const sessionResponse = await fetch(`/api/sessions/${sessionId}`);
            if (!sessionResponse.ok) {
                throw new Error('无法获取会话信息');
            }
            
            const sessionInfo = await sessionResponse.json();
            if (!sessionInfo.hasTensorboard) {
                throw new Error('该会话没有TensorBoard数据');
            }
            
            // 启动TensorBoard
            const response = await fetch('/api/tensorboard/start', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ 
                    sessionId: sessionId,
                    logdir: sessionInfo.tensorboardPath
                })
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message || '启动失败');
            }
            
            const result = await response.json();
            
            this.currentTensorBoard = {
                sessionId: sessionId,
                processId: result.processId,
                port: result.port,
                url: result.url
            };
            
            this.updateTensorBoardStatus();
            this.log(`TensorBoard启动成功 (端口: ${result.port})`);
            
            // 自动打开浏览器
            setTimeout(() => {
                this.openBrowser();
            }, 1000);
        } catch (error) {
            this.log(`启动TensorBoard失败: ${error.message}`, 'error');
            this.showError('启动TensorBoard失败，请检查会话数据是否完整');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * 停止TensorBoard
     */
    async stopTensorBoard() {
        if (!this.currentTensorBoard) {
            this.log('没有正在运行的TensorBoard', 'warning');
            return;
        }
        
        try {
            this.showLoading('正在停止TensorBoard...');
            
            const response = await fetch('/api/tensorboard/stop', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ processId: this.currentTensorBoard.processId })
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message || '停止失败');
            }
            
            const result = await response.json();
            
            this.currentTensorBoard = null;
            this.updateTensorBoardStatus();
            this.log('TensorBoard已停止');
        } catch (error) {
            this.log(`停止TensorBoard失败: ${error.message}`, 'error');
            this.showError('停止TensorBoard失败');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * 打开浏览器
     */
    openBrowser() {
        if (!this.currentTensorBoard) {
            this.log('TensorBoard未运行', 'error');
            return;
        }
        
        window.open(this.currentTensorBoard.url, '_blank');
        this.log(`已打开浏览器访问: ${this.currentTensorBoard.url}`);
    }

    /**
     * 更新TensorBoard状态显示
     */
    updateTensorBoardStatus() {
        const statusElement = document.getElementById('tensorboardStatus');
        const portElement = document.getElementById('portInfo');
        const urlElement = document.getElementById('urlInfo');
        const startBtn = document.getElementById('startBtn');
        const stopBtn = document.getElementById('stopBtn');
        const openBtn = document.getElementById('openBtn');
        
        if (this.currentTensorBoard) {
            statusElement.textContent = '运行中';
            statusElement.className = 'status-value status-running';
            portElement.textContent = this.currentTensorBoard.port;
            urlElement.innerHTML = `<a href="${this.currentTensorBoard.url}" target="_blank">${this.currentTensorBoard.url}</a>`;
            
            startBtn.disabled = true;
            stopBtn.disabled = false;
            openBtn.disabled = false;
        } else {
            statusElement.textContent = '未启动';
            statusElement.className = 'status-value status-stopped';
            portElement.textContent = '-';
            urlElement.textContent = '-';
            
            startBtn.disabled = false;
            stopBtn.disabled = true;
            openBtn.disabled = true;
        }
    }

    /**
     * 显示加载状态
     */
    showLoading(message) {
        const loadingElement = document.getElementById('loadingMessage');
        if (loadingElement) {
            loadingElement.textContent = message;
            loadingElement.style.display = 'block';
        }
    }

    /**
     * 隐藏加载状态
     */
    hideLoading() {
        const loadingElement = document.getElementById('loadingMessage');
        if (loadingElement) {
            loadingElement.style.display = 'none';
        }
    }

    /**
     * 显示错误信息
     */
    showError(message) {
        // 可以实现一个更好的错误提示UI
        alert(message);
    }

    /**
     * 记录日志
     */
    log(message, type = 'info') {
        const container = document.getElementById('logsContainer');
        if (!container) return;
        
        const timestamp = new Date().toLocaleTimeString();
        
        const logEntry = document.createElement('div');
        logEntry.className = `log-entry log-${type}`;
        logEntry.innerHTML = `
            <span class="log-time">[${timestamp}]</span>
            <span class="log-message">${message}</span>
        `;
        
        container.appendChild(logEntry);
        container.scrollTop = container.scrollHeight;
        
        // 限制日志条数
        const logs = container.querySelectorAll('.log-entry');
        if (logs.length > 100) {
            logs[0].remove();
        }
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', () => {
    new TrainingResultViewer();
});