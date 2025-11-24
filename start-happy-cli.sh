#!/bin/bash

# Happy CLI 本地启动脚本
#
# 用法:
#   ./start-happy-cli.sh                    # 交互式模式
#   ./start-happy-cli.sh "你的提示词"       # 单次命令模式
#   ./start-happy-cli.sh --help             # 查看帮助

cd /home/hantiv/code/happy-coder/happy-cli

export HAPPY_HOME_DIR=~/.happy-dev
export HAPPY_SERVER_URL=http://localhost:3001
export HAPPY_WEBAPP_URL=http://localhost:8081

echo "=== Happy CLI 本地模式 ==="
echo "Server: $HAPPY_SERVER_URL"
echo "Home: $HAPPY_HOME_DIR"
echo "=========================="
echo ""

# 如果没有参数,启动交互式会话
if [ $# -eq 0 ]; then
    echo "启动交互式 Claude Code 会话..."
    echo "提示: 你可以在移动端或 Web 端 (http://localhost:8081) 查看和控制此会话"
    echo ""
    ./bin/happy.mjs
else
    # 有参数,传递给 happy
    ./bin/happy.mjs "$@"
fi
