# JavHub 安装教程

JavHub 使用 Docker Compose 部署，支持群晖、飞牛、绿联、极空间、1Panel、Portainer 等带有 Compose 功能的 NAS 或服务器。

## NAS 安装（推荐）

### 1. 新建 Compose 项目

打开 NAS 的 Docker 管理界面，新建一个 Compose 项目。

复制本仓库 [`docker-compose.yml`](docker-compose.yml) 的全部内容，粘贴到 Compose 编辑框中。

### 2. 修改顶部配置

只需要修改文件最上面的这几项：

```yaml
x-db-password: &db-password "请填写一个数据库密码"
x-admin-token: &admin-token "请填写一个管理令牌"
x-license-key: &license-key ""
```

- 数据库密码和管理令牌请自行填写，不要使用默认值。
- 第一次启动时，激活码保持为空。
- 网页端口默认是 `3000`，如有冲突可修改 `x-web-port`。

文件下面的其他内容不需要修改。

### 3. 启动项目

保存并启动 Compose 项目，等待镜像下载和容器启动完成。

### 4. 获取实例 ID

打开 `javinfoapi` 容器的日志，找到以 `jvh-` 开头的实例 ID，并将完整内容发给发布者申请激活码。

### 5. 填写激活码

收到激活码后，重新编辑 Compose，把激活码填入：

```yaml
x-license-key: &license-key "你的激活码"
```

保存并重新部署项目，然后访问：

```text
http://NAS的IP:3000
```

## 媒体兼容服务

如需使用 Emby、Infuse、VidHub 或 SenPlayer 连接 JavHub：

1. 登录 JavHub，进入“设置 → 媒体服务器”。
2. 打开“启用媒体兼容服务”并保存。
3. 在播放器中填写 JavHub 的网页地址，例如：

   ```text
   http://NAS的IP:3000
   ```

播放器用户名和密码使用 JavHub 中创建的播放用户。

Docker/NAS 部署不需要、也不应把后端端口 `18090` 暴露到宿主机。媒体兼容 API 已由 JavHub 网页端口统一转发；请勿将 `http://NAS的IP:18090` 填入播放器。本地源码开发时，才使用 `http://localhost:18090`。

## 命令行安装

如果使用普通 Linux 服务器：

```bash
git clone https://github.com/Kongmei-ovo/JavHub-Release.git
cd JavHub-Release
```

编辑 `docker-compose.yml` 顶部的数据库密码和管理令牌，然后启动：

```bash
docker compose up -d
```

获取实例 ID：

```bash
docker compose logs javinfoapi
```

收到激活码后填入 `x-license-key`，再执行：

```bash
docker compose up -d
```

## 更新

在 NAS 中重新拉取镜像并重新部署 Compose 项目即可。

命令行用户执行：

```bash
docker compose pull
docker compose up -d
```

更新镜像不会删除已有配置和数据。

从不带媒体兼容开关的旧版本升级后，该服务默认保持关闭。需要使用播放器时，请在“设置 → 媒体服务器”中手动开启一次。

## 数据目录

配置和数据都保存在 Compose 项目目录中：

- `config`
- `data`
- `storage`

请定期备份这三个目录，不要删除 `config`，否则实例身份可能丢失。

## 无法启动

先查看容器状态和日志：

```bash
docker compose ps
docker compose logs --tail=200 javhub
docker compose logs --tail=200 javinfoapi
```

如果镜像提示 `manifest unknown`，请确认使用的是最新版 `docker-compose.yml`，并检查 NAS 的 CPU 架构是否为 `amd64` 或 `arm64`。
