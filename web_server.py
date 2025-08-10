#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
训练结果查看器Web服务
作者: Dionysus
日期: 2025-01-09

提供Web界面来查看和管理训练结果，支持选择历史训练会话并启动对应的TensorBoard
"""

import os
import json
import subprocess
import threading
import time
import signal
import webbrowser
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional

from flask import Flask, render_template, jsonify, request, send_from_directory
from flask_cors import CORS


class TensorBoardManager:
    """
    TensorBoard进程管理器
    """
    
    def __init__(self):
        self.processes: Dict[str, subprocess.Popen] = {}
        self.ports: Dict[str, int] = {}
        self.base_port = 6006
    
    def start_tensorboard(self, session_id: str, logdir: str) -> Dict[str, Any]:
        """
        启动TensorBoard
        
        Args:
            session_id: 会话ID
            logdir: 日志目录路径
            
        Returns:
            Dict[str, Any]: 启动结果
        """
        try:
            # 检查是否已经在运行
            if session_id in self.processes:
                process = self.processes[session_id]
                if process.poll() is None:  # 进程仍在运行
                    port = self.ports[session_id]
                    return {
                        'success': True,
                        'message': 'TensorBoard已在运行',
                        'processId': session_id,
                        'port': port,
                        'url': f'http://localhost:{port}'
                    }
                else:
                    # 进程已结束，清理
                    del self.processes[session_id]
                    del self.ports[session_id]
            
            # 检查日志目录是否存在
            if not os.path.exists(logdir):
                return {
                    'success': False,
                    'message': f'TensorBoard日志目录不存在: {logdir}'
                }
            
            # 检查是否有日志文件
            log_files = [f for f in os.listdir(logdir) if f.startswith('events.out.tfevents')]
            if not log_files:
                return {
                    'success': False,
                    'message': f'日志目录中没有TensorBoard文件: {logdir}'
                }
            
            # 找到可用端口
            port = self._find_available_port()
            
            # 启动TensorBoard
            cmd = ['tensorboard', '--logdir', logdir, '--port', str(port), '--host', '0.0.0.0']
            
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # 等待一下确保启动成功
            time.sleep(2)
            
            if process.poll() is not None:
                # 进程已结束，启动失败
                stdout, stderr = process.communicate()
                return {
                    'success': False,
                    'message': f'TensorBoard启动失败: {stderr}'
                }
            
            # 保存进程信息
            self.processes[session_id] = process
            self.ports[session_id] = port
            
            return {
                'success': True,
                'message': 'TensorBoard启动成功',
                'processId': session_id,
                'port': port,
                'url': f'http://localhost:{port}'
            }
            
        except FileNotFoundError:
            return {
                'success': False,
                'message': '未找到tensorboard命令，请确保已安装TensorBoard'
            }
        except Exception as e:
            return {
                'success': False,
                'message': f'启动TensorBoard时发生错误: {str(e)}'
            }
    
    def stop_tensorboard(self, session_id: str) -> Dict[str, Any]:
        """
        停止TensorBoard
        
        Args:
            session_id: 会话ID
            
        Returns:
            Dict[str, Any]: 停止结果
        """
        try:
            if session_id not in self.processes:
                return {
                    'success': False,
                    'message': 'TensorBoard进程不存在'
                }
            
            process = self.processes[session_id]
            
            if process.poll() is not None:
                # 进程已结束
                del self.processes[session_id]
                del self.ports[session_id]
                return {
                    'success': True,
                    'message': 'TensorBoard进程已结束'
                }
            
            # 终止进程
            process.terminate()
            
            # 等待进程结束
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                # 强制杀死进程
                process.kill()
                process.wait()
            
            # 清理
            del self.processes[session_id]
            del self.ports[session_id]
            
            return {
                'success': True,
                'message': 'TensorBoard已停止'
            }
            
        except Exception as e:
            return {
                'success': False,
                'message': f'停止TensorBoard时发生错误: {str(e)}'
            }
    
    def _find_available_port(self) -> int:
        """
        查找可用端口
        
        Returns:
            int: 可用端口号
        """
        import socket
        
        for port in range(self.base_port, self.base_port + 100):
            if port in self.ports.values():
                continue
                
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                result = sock.connect_ex(('localhost', port))
                sock.close()
                
                if result != 0:  # 端口可用
                    return port
            except:
                continue
        
        raise Exception("无法找到可用端口")
    
    def cleanup(self):
        """
        清理所有进程
        """
        for session_id in list(self.processes.keys()):
            self.stop_tensorboard(session_id)


class TrainingResultManager:
    """
    训练结果管理器
    """
    
    def __init__(self, base_dir: str = None):
        if base_dir is None:
            base_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'training_result')
        self.base_dir = base_dir
    
    def get_sessions(self) -> List[Dict[str, Any]]:
        """
        获取所有训练会话
        
        Returns:
            List[Dict[str, Any]]: 会话列表
        """
        sessions = []
        
        if not os.path.exists(self.base_dir):
            return sessions
        
        for item in os.listdir(self.base_dir):
            session_path = os.path.join(self.base_dir, item)
            if os.path.isdir(session_path) and item.isdigit():
                session_info = self._get_session_info(item, session_path)
                if session_info:
                    sessions.append(session_info)
        
        return sessions
    
    def get_session_detail(self, session_id: str) -> Optional[Dict[str, Any]]:
        """
        获取会话详细信息
        
        Args:
            session_id: 会话ID
            
        Returns:
            Optional[Dict[str, Any]]: 会话详细信息
        """
        session_path = os.path.join(self.base_dir, session_id)
        if not os.path.exists(session_path):
            return None
        
        return self._get_session_info(session_id, session_path, detailed=True)
    
    def _get_session_info(self, session_id: str, session_path: str, detailed: bool = False) -> Optional[Dict[str, Any]]:
        """
        获取会话信息
        
        Args:
            session_id: 会话ID
            session_path: 会话路径
            detailed: 是否获取详细信息
            
        Returns:
            Optional[Dict[str, Any]]: 会话信息
        """
        try:
            # 基本信息
            info = {
                'id': session_id,
                'name': f'训练会话 {session_id}',
                'created': datetime.fromtimestamp(os.path.getctime(session_path)).strftime('%Y-%m-%d %H:%M:%S'),
                'status': 'completed'
            }
            
            # 检查各个目录
            tensorboard_path = os.path.join(session_path, 'tensorboard')
            models_path = os.path.join(session_path, 'models')
            stats_path = os.path.join(session_path, 'stats')
            
            # 统计模型文件数量（估算episode数）
            episodes = 0
            if os.path.exists(models_path):
                model_files = [f for f in os.listdir(models_path) if f.endswith('.pth')]
                episodes = len(model_files)
            
            info['episodes'] = episodes
            
            if detailed:
                info.update({
                    'tensorboardPath': tensorboard_path,
                    'modelsPath': models_path,
                    'statsPath': stats_path,
                    'hasTensorboard': os.path.exists(tensorboard_path),
                    'hasModels': os.path.exists(models_path),
                    'hasStats': os.path.exists(stats_path)
                })
                
                # 尝试读取统计信息
                try:
                    stats_file = os.path.join(stats_path, f'training_stats_{session_id}.json')
                    if os.path.exists(stats_file):
                        with open(stats_file, 'r', encoding='utf-8') as f:
                            stats_data = json.load(f)
                            if 'episode_rewards' in stats_data and stats_data['episode_rewards']:
                                info['lastReward'] = stats_data['episode_rewards'][-1]
                                info['bestReward'] = max(stats_data['episode_rewards'])
                except:
                    pass
            
            return info
            
        except Exception as e:
            print(f"获取会话信息失败 {session_id}: {e}")
            return None


# 创建Flask应用
app = Flask(__name__, static_folder='web', template_folder='web')
CORS(app)  # 允许跨域请求

# 创建管理器实例
tensorboard_manager = TensorBoardManager()
result_manager = TrainingResultManager()


@app.route('/')
def index():
    """主页"""
    return send_from_directory('web', 'index.html')


@app.route('/<path:filename>')
def static_files(filename):
    """静态文件"""
    return send_from_directory('web', filename)


@app.route('/api/sessions')
def get_sessions():
    """获取训练会话列表"""
    try:
        sessions = result_manager.get_sessions()
        return jsonify(sessions)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/sessions/<session_id>')
def get_session_detail(session_id):
    """获取会话详细信息"""
    try:
        session_info = result_manager.get_session_detail(session_id)
        if session_info is None:
            return jsonify({'error': '会话不存在'}), 404
        return jsonify(session_info)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/tensorboard/start', methods=['POST'])
def start_tensorboard():
    """启动TensorBoard"""
    try:
        data = request.get_json()
        session_id = data.get('sessionId')
        logdir = data.get('logdir')
        
        if not session_id or not logdir:
            return jsonify({'error': '缺少必要参数'}), 400
        
        # 如果logdir是相对路径，转换为绝对路径
        if not os.path.isabs(logdir):
            base_dir = os.path.dirname(os.path.abspath(__file__))
            logdir = os.path.join(base_dir, logdir)
        
        result = tensorboard_manager.start_tensorboard(session_id, logdir)
        
        if result['success']:
            return jsonify(result)
        else:
            return jsonify(result), 400
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/tensorboard/stop', methods=['POST'])
def stop_tensorboard():
    """停止TensorBoard"""
    try:
        data = request.get_json()
        process_id = data.get('processId')
        
        if not process_id:
            return jsonify({'error': '缺少进程ID'}), 400
        
        result = tensorboard_manager.stop_tensorboard(process_id)
        
        if result['success']:
            return jsonify(result)
        else:
            return jsonify(result), 400
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/tensorboard/status')
def get_tensorboard_status():
    """获取TensorBoard状态"""
    try:
        status = {}
        for session_id, process in tensorboard_manager.processes.items():
            if process.poll() is None:  # 进程仍在运行
                status[session_id] = {
                    'running': True,
                    'port': tensorboard_manager.ports.get(session_id),
                    'url': f'http://localhost:{tensorboard_manager.ports.get(session_id)}'
                }
            else:
                status[session_id] = {'running': False}
        
        return jsonify(status)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


def cleanup_on_exit():
    """退出时清理"""
    print("正在清理TensorBoard进程...")
    tensorboard_manager.cleanup()
    print("清理完成")


def signal_handler(signum, frame):
    """信号处理器"""
    cleanup_on_exit()
    exit(0)


def main():
    """
    主函数
    """
    print("=== 训练结果查看器Web服务 ===")
    print("作者: Dionysus")
    print("日期: 2025-01-09\n")
    
    # 注册信号处理器
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # 检查训练结果目录
    base_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'training_result')
    if not os.path.exists(base_dir):
        print(f"⚠️  训练结果目录不存在: {base_dir}")
        print("请先运行训练生成结果数据")
    else:
        sessions = result_manager.get_sessions()
        print(f"✅ 找到 {len(sessions)} 个训练会话")
    
    # 启动Web服务
    host = '127.0.0.1'
    port = 5000
    
    print(f"🚀 启动Web服务...")
    print(f"📍 访问地址: http://{host}:{port}")
    print(f"📁 静态文件目录: {os.path.join(os.path.dirname(os.path.abspath(__file__)), 'web')}")
    print("\n⚠️  按 Ctrl+C 停止服务")
    
    # 自动打开浏览器
    def open_browser():
        time.sleep(1.5)
        try:
            webbrowser.open(f'http://{host}:{port}')
            print("🌐 已自动打开浏览器")
        except:
            print("⚠️  无法自动打开浏览器，请手动访问上述地址")
    
    threading.Thread(target=open_browser, daemon=True).start()
    
    try:
        app.run(host=host, port=port, debug=False, threaded=True)
    except KeyboardInterrupt:
        pass
    finally:
        cleanup_on_exit()


if __name__ == '__main__':
    main()