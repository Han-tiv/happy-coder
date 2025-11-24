# Happy 自托管启动指南

## 🚀 快速启动

### 1. 确保所有服务正在运行

检查服务状态:
```bash
# 检查 Happy Server (应该在 3001 端口)
curl http://localhost:3001/

# 检查 Web 应用 (应该在 8081 端口)
curl http://localhost:8081/

# 检查数据库
systemctl status postgresql redis-server
```

### 2. 启动 Happy CLI

**重要**: Happy CLI 必须在前台终端运行才能交互!

在新的终端窗口中运行:
```bash
cd /home/hantiv/code/happy-coder
./start-happy-cli.sh
```

或者直接运行:
```bash
cd /home/hantiv/code/happy-coder/happy-cli
export HAPPY_HOME_DIR=~/.happy-dev
export HAPPY_SERVER_URL=http://localhost:3001
export HAPPY_WEBAPP_URL=http://localhost:8081
./bin/happy.mjs
```

## 📋 组件状态

| 组件 | 地址 | 状态 |
|------|------|------|
| Happy Server | http://localhost:3001 | ✅ 运行中 |
| Web 应用 | http://localhost:8081 | ✅ 运行中 |
| PostgreSQL | localhost:5432 | ✅ 运行中 |
| Redis | localhost:6379 | ✅ 运行中 |
| Happy CLI | 命令行 | ⏸️ 需要手动启动 |

## 🔑 认证信息

### Web 客户端恢复密钥
```
WRPFC-3Y2CL-MGH5I-6JVTE-HDGOO-6DSSF-Z64FW-KAUO2-6TSLU-6VDD3-BQ
```

使用方法:
1. 打开 http://localhost:8081
2. 点击 "Enter your secret key to restore access"
3. 粘贴上面的密钥
4. 你将看到所有 CLI 会话

### CLI 认证文件
- 凭据: `~/.happy-dev/access.key`
- 设置: `~/.happy-dev/settings.json`

## 💻 使用示例

### 交互式会话
```bash
./start-happy-cli.sh
# 然后输入你的问题，按 Ctrl+C 退出
```

### 单次命令
```bash
./start-happy-cli.sh --print "帮我写一个 Python 函数计算斐波那契数列"
```

### 恢复上一个会话
```bash
./start-happy-cli.sh --resume
```

### 调试模式
```bash
./start-happy-cli.sh -d
```

## 🌐 Web 控制

打开 http://localhost:8081 可以:
- 查看所有 CLI 会话
- 实时看到 CLI 的输出
- 从 Web 界面控制 CLI 会话
- 查看历史对话

## 🔧 故障排除

### Happy Server 没有运行
```bash
cd /home/hantiv/code/happy-coder/happy-server
npx tsx --env-file=.env --env-file=.env.dev ./sources/main.ts
```

### Web 应用没有运行
```bash
cd /home/hantiv/code/happy-coder/happy
npx expo start --web
```

### 数据库连接失败
```bash
systemctl start postgresql redis-server
```

### CLI 认证失败
重新运行设置脚本:
```bash
cd /home/hantiv/code/happy-coder
HAPPY_HOME_DIR=~/.happy-dev HAPPY_SERVER_URL=http://localhost:3001 \
node scripts/setup-test-credentials.mjs
```

## 📝 配置文件位置

- Happy Server 配置: `/home/hantiv/code/happy-coder/happy-server/.env`
- Happy CLI 配置: `/home/hantiv/code/happy-coder/happy-cli/.env.dev-local-server`
- Web 应用配置: `/home/hantiv/code/happy-coder/happy/.env`
- CLI 数据目录: `~/.happy-dev/`

## 🎯 下一步

现在你可以:
1. 打开新的终端窗口
2. 运行 `./start-happy-cli.sh`
3. 开始与 Claude Code 交互!

所有数据都存储在本地服务器,完全自托管! 🎉
