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
- 媒体服务器端口默认是 `18090`，如有冲突可修改 `x-media-server-port`。

文件下面的其他内容不需要修改。

### 3. 启动项目

保存并启动 Compose 项目，等待镜像下载和容器启动完成。新版 Compose 会额外
启动一个很小的 `updater` 更新网关，并由它占用网页和媒体服务器端口。

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
3. 在播放器中填写 NAS IP 和媒体服务器端口，例如：

   ```text
   http://NAS的IP:18090
   ```

播放器用户名和密码使用 JavHub 中创建的播放用户。

`x-media-server-port` 是 NAS/宿主机对外提供的媒体端口。如果修改了它，重新创建 `javhub` 容器后，播放器地址也要使用修改后的端口。JavHub 设置页中的服务端口保持 `18090`，通常无需修改。

### Cloudflare 远程访问

媒体服务器设置中提供两种仅面向 Emby 兼容服务的远程入口：无需账号和域名的临时 Quick Tunnel，以及通过 Cloudflare 授权创建的固定 Tunnel 地址。创建后，将设置页显示的 HTTPS 地址填入播放器。

无需修改本仓库的 Compose，也不要另外添加 `cloudflared` 容器。`cloudflared` 已内嵌在 `javhub-protected` 镜像中，由 JavHub 作为子进程启动和管理。Tunnel 只要求容器能够出站访问 HTTPS；不需要新增宿主机端口、`network_mode: host`、Docker Socket 或 `privileged` 权限。

Tunnel 使用的 Emby 专用内部源站为 `127.0.0.1:8096`，只能在 `javhub` 容器内部访问，绝不能映射到宿主机。现有的 `x-media-server-port`（默认 `18090`）映射只是局域网播放器入口，可以继续保留，但与 Cloudflare Tunnel 无关。

固定 Tunnel 的隧道专用凭据保存在现有的 `./data:/app/data` 挂载中。请勿删除或移除该挂载；更新镜像或重新创建容器后，JavHub 会从其中自动恢复固定 Tunnel。

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

## 自动更新

从包含 `updater` 的这个版本开始，系统每分钟检查一次官方正式版本。新版本的
双架构镜像完成构建和校验后，更新器会自动下载并依次重建 JavInfoApi、JavHub，
通常不需要用户手动操作。更新期间，原网页地址会显示维护状态和失败原因。

从旧版首次升级到这个版本时，必须手动更新一次本仓库的完整 Compose 内容并
重新部署，因为旧版尚未包含更新器。命令行用户执行：

```bash
git pull
docker compose pull
docker compose up -d
```

后续更新由 `updater` 自动完成。更新器挂载 Docker Socket，因此拥有重建本项目
容器所需的宿主机 Docker 管理权限；请只使用本官方仓库提供的 Compose 和镜像。
自动更新不会执行 `docker compose down -v`，也不会删除已有配置和数据。

从不带媒体兼容开关的旧版本升级后，该服务默认保持关闭。需要使用播放器时，请在“设置 → 媒体服务器”中手动开启一次。

## 数据目录

配置和数据都保存在 Compose 项目目录中：

- `config`
- `data`
- `storage`

请定期备份这三个目录，不要删除 `config`。其中包含实例 ID、设备私钥和授权
缓存；删除或复制整个 `config` 都会改变本机授权的安全边界。

其中 `data` 还保存固定 Cloudflare Tunnel 的隧道专用凭据；删除后将无法在容器更新或重建后自动恢复该 Tunnel。

## 无法启动

先查看容器状态和日志：

```bash
docker compose ps
docker compose logs --tail=200 javhub
docker compose logs --tail=200 javinfoapi
docker compose logs --tail=200 updater
```

如果镜像提示 `manifest unknown`，请确认使用的是最新版 `docker-compose.yml`，并检查 NAS 的 CPU 架构是否为 `amd64` 或 `arm64`。
