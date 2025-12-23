# Beancount Docker

基于 Docker 的 [Fava](https://beancount.github.io/fava/) 部署方案，Fava 是 [Beancount](https://beancount.github.io/) 复式记账的 Web 界面，默认集成 OAuth2/OIDC 认证。

## 特性

- 多阶段构建，镜像体积小
- 默认启用 OAuth2 Proxy 进行 OIDC 认证
- 集成 [Fava Dashboards](https://github.com/andreasgerstmayr/fava-dashboards) 仪表盘
- 支持 [Beancount Periodic](https://pypi.org/project/beancount-periodic/) 周期性交易
- 使用高性能的 [UV](https://github.com/astral-sh/uv) 包管理器

## 快速开始

### 1. 克隆仓库

```bash
git clone <repository-url>
cd beancount-docker
```

### 2. 添加账本文件

```bash
mkdir books
cp /path/to/your/main.bean books/
```

### 3. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 配置 OIDC 认证信息
```

### 4. 启动服务

```bash
docker compose up -d
```

### 5. 访问 Fava

打开 <http://localhost:5505>（通过 OAuth2 认证）

## 部署模式

### 默认模式：OAuth2 认证

默认配置通过 OAuth2 Proxy 保护 Fava，需配置 `.env` 文件后启动：

```bash
docker compose up -d
```

访问地址：<http://localhost:5505>

### 无认证模式

如不需要 OAuth2 认证，修改 `docker-compose.yaml`，取消注释 ports 部分：

```yaml
services:
  fava:
    # ...
    ports:
      - 5000:5000
```

然后仅启动 Fava：

```bash
docker compose up -d fava
```

或者注释掉 `docker-compose.yaml` 中的 `oauth2-proxy-fava` 部分，然后启动服务：

```bash
docker compose up -d
```

访问地址：<http://localhost:5000>

## 配置

### 环境变量

创建 `.env` 文件配置 OAuth2 认证：

| 变量 | 说明 | 示例 |
| --- | --- | --- |
| `OIDC_ISSUER_URL` | OIDC 提供商地址 | `https://accounts.google.com` |
| `OAUTH2_CLIENT_ID` | OAuth2 客户端 ID | `your-client-id` |
| `OAUTH2_CLIENT_SECRET` | OAuth2 客户端密钥 | `your-client-secret` |
| `OAUTH2_PROXY_REDIRECT_URL` | 回调地址 | `http://localhost:5505/oauth2/callback` |
| `OAUTH2_PROXY_EMAIL_DOMAINS` | 允许的邮箱域名 | `*` 或 `example.com` |
| `OAUTH2_PROXY_COOKIE_SECRET` | Cookie 加密密钥 | 使用下方命令生成 |

生成 Cookie 密钥：

```bash
openssl rand -base64 32 | tr '+/' '-_' | tr -d '='
```

### 账本文件路径

默认读取 `/books/main.bean`，可在 `docker-compose.yaml` 中修改：

```yaml
environment:
  - BEANCOUNT_FILE=/books/your-ledger.bean
```

### 数据卷

| 主机路径 | 容器路径 | 说明 |
| --- | --- | --- |
| `./books` | `/books` | Beancount 账本文件 |

## 使用

### 服务管理

```bash
# 启动所有服务
docker compose up -d

# 仅启动 Fava（无认证模式需先修改 docker-compose.yaml）
docker compose up -d fava

# 查看日志
docker compose logs -f

# 停止服务
docker compose down
```

### 重新构建

```bash
docker compose build --no-cache
docker compose up -d
```

### Beancount 命令

```bash
# 检查账本语法
docker compose exec fava bean-check /books/main.bean

# 执行查询
docker compose exec fava bean-query /books/main.bean "SELECT account, sum(position) GROUP BY account"

# 格式化账本
docker compose exec fava bean-format /books/main.bean
```

### 服务端口

| 服务 | 端口 | 说明 |
| --- | --- | --- |
| `fava` | 5000 | Fava Web 界面（内部） |
| `oauth2-proxy-fava` | 5505 | OAuth2 认证代理（默认入口） |

## 依赖

| 包 | 版本 | 说明 |
| --- | --- | --- |
| [beancount](https://beancount.github.io/) | ≥3.2.0 | 复式记账核心 |
| [fava](https://beancount.github.io/fava/) | ≥1.30.8 | Web 界面 |
| [fava-dashboards](https://github.com/andreasgerstmayr/fava-dashboards) | 2.0.0b2 | 仪表盘扩展 |
| [beancount-periodic](https://pypi.org/project/beancount-periodic/) | ≥0.2.1 | 周期性交易 |

## 故障排除

### Fava 无法启动

1. 检查账本文件是否有效：

   ```bash
   docker compose exec fava bean-check /books/main.bean
   ```

2. 检查 `books` 目录权限

3. 查看日志：

   ```bash
   docker compose logs fava
   ```

### OAuth2 认证失败

1. 确认 `.env` 中所有变量已正确配置
2. 确认回调地址与 OIDC 提供商配置一致
3. 查看 OAuth2 Proxy 日志：

   ```bash
   docker compose logs oauth2-proxy-fava
   ```

### 构建失败

```bash
docker compose build --no-cache
```

## 本地运行

### 安装 UV

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 安装依赖并运行

```bash
uv sync
uv run fava books/main.bean
```

### 更新依赖

```bash
uv lock --upgrade
docker compose build
```

## 相关项目

- [Beancount](https://beancount.github.io/) - 文本复式记账
- [Fava](https://beancount.github.io/fava/) - Beancount Web 界面
- [Fava Dashboards](https://github.com/andreasgerstmayr/fava-dashboards) - 仪表盘扩展
- [OAuth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/) - 认证代理
