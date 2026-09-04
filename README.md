# JavHub 安装

JavHub 是一个使用 Docker Compose 部署的自托管应用。本仓库只提供基于加密镜像的官方部署文件，不包含 JavHub 和 JavInfoApi 的源代码。

## 开始之前

你需要准备：

- 一台 `amd64` 或 `arm64` 架构的 Linux 服务器
- 已安装的 Docker 和 Docker Compose
- 可供浏览器访问的服务器 IP
- 发布者提供的激活码（首次启动并取得实例 ID 后申请）

先确认 Docker Compose 可用：

```bash
docker compose version
```

如果提示找不到 `docker` 或 `compose`，请先按照 [Docker 官方文档](https://docs.docker.com/engine/install/) 安装 Docker Engine 和 Compose 插件。

## 官方版本：一键下载并启动

复制下面的整段命令到服务器终端执行：

```bash
mkdir -p JavHub-Release
cd JavHub-Release
curl -fsSL https://raw.githubusercontent.com/Kongmei-ovo/JavHub-Release/main/docker-compose.yml -o docker-compose.yml

# 自动生成数据库密码和管理令牌，并写入 Compose 文件
DB_SECRET="$(openssl rand -hex 24)"
ADMIN_SECRET="$(openssl rand -hex 24)"
sed -i "s|^x-db-password:.*|x-db-password: \&db-password \"${DB_SECRET}\"|" docker-compose.yml
sed -i "s|^x-admin-token:.*|x-admin-token: \&admin-token \"${ADMIN_SECRET}\"|" docker-compose.yml
unset DB_SECRET ADMIN_SECRET

docker compose pull
docker compose up -d
```

`docker-compose.yml` 顶部有一块标注为“用户配置（只修改这里）”的区域。上面的命令已经自动填写密码；第一次启动时，让 `x-license-key` 保持为空。

如果你使用 1Panel、Portainer、群晖 Container Manager 等图形界面，也可以直接复制 [`docker-compose.yml`](docker-compose.yml) 的全部内容创建 Compose 项目。创建前只需在文件顶部修改以下内容：

- `x-db-password`：数据库密码
- `x-admin-token`：管理令牌
- `x-license-key`：首次启动时留空，取得激活码后再填写
- `x-timezone`：时区，默认 `Asia/Shanghai`
- `x-web-port`：网页端口，默认 `3000`

数据库密码只定义一次，并由所有相关服务共用，不要修改文件下面的数据库连接配置。

镜像下载和数据库初始化可能需要几分钟。用下面的命令查看状态：

```bash
docker compose ps
```

## 获取实例 ID

执行：

```bash
docker compose logs javinfoapi
```

在输出中找到以 `jvh-` 开头的实例 ID，并把**完整的实例 ID**发给发布者。如果暂时没有看到，请等待一分钟后再执行一次命令。

## 填写激活码

收到发布者发来的激活码后，复制下面的整段命令执行：

```bash
read -r -p "请粘贴激活码，然后按回车：" LICENSE_KEY
sed -i "s|^x-license-key:.*|x-license-key: \&license-key \"${LICENSE_KEY}\"|" docker-compose.yml
unset LICENSE_KEY
docker compose up -d
docker compose ps
```

终端出现提示后，只粘贴激活码本身并按回车。命令会自动写入 `docker-compose.yml` 并重新启动服务。使用图形界面时，则把激活码填入文件顶部的 `x-license-key`，再重新部署 Compose 项目。

当服务状态显示为 `running` 或 `healthy` 后，在浏览器打开：

```text
http://服务器IP:3000
```

例如服务器 IP 是 `192.168.1.20`，就打开 `http://192.168.1.20:3000`。如果使用云服务器，还需要在防火墙或安全组中放行 TCP 端口 `3000`。

## 更新

进入安装目录并执行。`stable` 是官方稳定版镜像标签，会拉取最新的加密镜像：

```bash
cd JavHub-Release
docker compose pull
docker compose up -d
```

不要在更新时重新下载并覆盖 `docker-compose.yml`，否则会覆盖你填写的密码和激活码。更新镜像不会删除已有配置和数据。

## 常用排错命令

```bash
# 查看所有服务状态
docker compose ps

# 查看 JavHub 日志
docker compose logs --tail=200 javhub

# 查看 JavInfoApi 日志和实例 ID
docker compose logs --tail=200 javinfoapi

# 重启全部服务
docker compose restart
```

如果仍无法启动，请把 `docker compose ps` 和相关日志的输出发给发布者。发送日志前请检查其中是否包含你不希望公开的信息；不要发送完整的 `docker-compose.yml`、密码或激活码。

## 数据备份

请定期备份以下内容：

- `./config`
- `./data`
- Docker 数据卷 `javinfo-postgres`、`javhub-redis` 和 `avdb-data`

不要删除 `./config`：实例身份保存在这里。一个激活码只授权一个安装实例，把激活码复制到另一台服务器不会形成新的授权。
