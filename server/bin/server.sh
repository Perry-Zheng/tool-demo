#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

# 导入配置
eval "$(PYTHONPATH=$PROJECT_ROOT python3 - <<EOF
try:
    from settings.config import SERVICE_CONFIG
    print(f'export PROJECT_ROOT="{SERVICE_CONFIG["PROJECT_ROOT"]}"')
    print(f'export LOG_DIR="{SERVICE_CONFIG["LOG_DIR"]}"')
    print(f'export PID_DIR="{SERVICE_CONFIG["PID_DIR"]}"')
except Exception as e:
    import sys
    print(f'echo "配置加载错误: {str(e)}"', file=sys.stderr)
    sys.exit(1)
EOF
)"

# 检查配置是否成功导入
if [ -z "$PROJECT_ROOT" ]; then
    echo "错误: 无法加载配置文件"
    exit 1
fi


# 输出当前配置
echo "当前配置:"
echo "PROJECT_ROOT: $PROJECT_ROOT"
echo "LOG_DIR: $LOG_DIR"
echo "PID_DIR: $PID_DIR"

# 设置 supervisor 配置文件路径
SUPERVISOR_CONF="$PROJECT_ROOT/settings/supervisor/supervisor.conf"

# 清理函数
cleanup() {
    echo "Cleaning up..."
    # 删除旧的 sock 文件
    rm -f "$PROJECT_ROOT/server/supervisor.sock"
    # 删除旧的 pid 文件
    rm -f "$PID_DIR/supervisord.pid"
    # 杀死可能存在的旧进程
    pkill -f "supervisord -c $SUPERVISOR_CONF" || true
    pkill -f "python3 run.py" || true
}

# 检查目录是否存在
check_directories() {
    if [ ! -d "$PROJECT_ROOT" ]; then
        echo "错误: 项目根目录不存在: $PROJECT_ROOT"
        exit 1
    fi
    
    # 创建必要的目录（从 config.py 中获取配置）
    echo "Creating necessary directories..."
    mkdir -p "$LOG_DIR"
    mkdir -p "$PID_DIR"
    
    # 检查配置文件
    if [ ! -f "$SUPERVISOR_CONF" ]; then
        echo "错误: supervisor配置文件不存在: $SUPERVISOR_CONF"
        exit 1
    fi
}

# 设置环境变量供 supervisor 使用
export ENV_PROJECT_ROOT="$PROJECT_ROOT"

# 检查目录
check_directories

# 处理命令行参数
case "$1" in
    start)
        echo "Starting Flask application..."
        cleanup
        echo "Using config file: $SUPERVISOR_CONF"
        echo "Python path: $(which python3)"
        echo "Current directory: $(pwd)"
        echo "---"
        supervisord -c "$SUPERVISOR_CONF"
        sleep 2
        supervisorctl -c "$SUPERVISOR_CONF" status
        ;;
    
    stop)
        echo "Stopping Flask application..."
        supervisorctl -c "$SUPERVISOR_CONF" stop flask_app
        supervisorctl -c "$SUPERVISOR_CONF" shutdown
        cleanup
        ;;
    
    restart)
        echo "Restarting Flask application..."
        $0 stop
        sleep 2
        $0 start
        ;;
    
    status)
        supervisorctl -c "$SUPERVISOR_CONF" status
        ;;
    
    logs)
        echo "Available logs:"
        echo "1. Access log (a)"
        echo "2. Error log (e)"
        echo "3. Supervisor log (s)"
        read -p "Choose log type [a/e/s]: " log_type
        case $log_type in
            a|A) tail -f "$LOG_DIR/flask_access.log" ;;
            e|E) tail -f "$LOG_DIR/flask_error.log" ;;
            s|S) tail -f "$LOG_DIR/supervisord.log" ;;
            *) echo "Invalid choice" ;;
        esac
        ;;
    
    clean)
        cleanup
        echo "Cleanup completed"
        ;;
    
    *)
        echo "使用方法: $0 {start|stop|restart|status|logs|clean}"
        echo "命令说明:"
        echo "  start   - 启动 Flask 应用"
        echo "  stop    - 停止 Flask 应用"
        echo "  restart - 重启 Flask 应用"
        echo "  status  - 查看应用状态"
        echo "  logs    - 查看应用日志"
        echo "  clean   - 清理旧进程和文件"
        exit 1
        ;;
esac

exit 0 