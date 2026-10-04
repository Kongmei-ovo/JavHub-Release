# JavHub 安装教程

默认 `docker-compose.yml` 只启动独立入口，组件、数据库和授权在网页里配置。
支持带 Compose 功能的 NAS 或服务器；后续一般不再需要修改 Compose。

## 新安装

1. 新建 Compose 项目，复制 [docker-compose.yml](docker-compose.yml)。
2. 将顶部 `x-project-dir` 改成 NAS 上实际的项目绝对路径；按需调整网页端口（默认 3000）和媒体端口（默认 18090）。
3. 保存并启动，然后访问 `http://NAS的IP:3000`。
4. 从 `updater` 日志复制首次配对码，在网页设置部署管理员密码。
5. 选择可选组件并安装。数据库密码和内部管理令牌可留空自动生成；激活码也可稍后填写。
6. 安装后在网页取得实例 ID，申请激活码，再保存。看到“JavHub 已就绪，可以开始使用”后，点击“进入 JavHub”。

命令行用户在项目目录中执行：

```sh
docker compose up -d
docker compose logs updater
```

完成后再次打开原地址直接进入主程序。组件管理仍可从“设置 → 基础服务”打开。
`docker-compose.bootstrap.yml` 保留为同样的入口安装方案。

## 已有用户升级

原 Compose 中的通用服务配置由官方模板接管，个人密码、授权和集成配置继续保留。
迁移不会重新创建数据库数据、改变原数据挂载或要求重新导入影片资料。

首次迁移前备份原 Compose、`.env`、`config`、`data`、`storage` 和原数据卷。
保持原 Compose 项目名称和项目目录，不要新建另一个项目。

1. 原部署有入口时，只将 Compose 替换成新版入口文件，保留原项目名称、目录和对外端口。
2. 只更新入口：`docker compose pull updater`，再执行 `docker compose up -d updater`。
3. 打开网页设置部署管理员。检测到原容器时会自动勾选“接管已有部署”。确认后沿用旧数据库密码、授权、挂载和网络。
4. 检查显示的配置，保存并应用。之后由入口管理基础服务和可选组件。

**不要执行 `down -v`，不要选择删除孤立容器/数据卷。** 新入口通过同一项目内已有容器
取得原个人配置，即使旧 Compose 已被替换，也可识别原数据卷。容器可以处于停止状态。
如果旧入口不具备管理功能，需要本次发布后手动拉取新版入口一次。

原部署没有入口、网页端口由 `javhub` 占用时，先用原 Compose 执行
`docker compose stop javhub` 释放端口，保留容器和数据，然后再更换文件启动入口。

已经使用新版并生成 `.javhub` 的用户无需再次接管；更新入口后自动加载原个人配置。
仅在应用设置中填写过的 AVDB API Key，可在组件管理中补填，或连接已有 AVDB 账号获取专用 Key。

接管目前支持官方单实例服务组合。自定义服务、外部独立数据库、特殊容器权限或已删除
原容器的部署需要按原配置迁移；入口会在修改容器前说明不支持的原因，避免误建空库。
保留的 [docker-compose.legacy.yml](docker-compose.legacy.yml) 是旧完整布局参考，
不能用它的默认密码覆盖自己原来的配置。

## 配置与组件

AVDB 可选择不使用、本机安装或连接已有服务。本机模式可在引导里创建首次账号或登录
已有账号取得专用 Key；停用会停止容器并保留数据。FlareSolverr 内存、空闲页面优化等
配置保存后自动应用，只重建受影响服务。

启用自动更新后，入口接收官方应用、部署模板和自身的新版本。更新期间网页会显示进度，
失败会显示原因。个人配置独立保存在 `.javhub`，无需追着官方模板修改 Compose。

## 媒体兼容服务

在“设置 → 媒体服务器”开启媒体兼容服务。Emby、Infuse、VidHub 或 SenPlayer 使用
`http://NAS的IP:18090`，用户名和密码使用 JavHub 中创建的播放用户。
媒体端口可以在 Compose 中修改，修改后播放器也需要使用新地址。

Cloudflare Quick Tunnel 和固定 Tunnel 可直接在设置中创建，无需添加 `cloudflared` 容器。
固定 Tunnel 凭据随 `data` 挂载保存，更新后可恢复。

## 数据与排查

备份 `.javhub`、`config`、`data`、`storage` 以及已有命名数据卷；其中包含密码、
设备身份和授权缓存，不要公开分享或提交仓库。停用组件不会删除数据。

```sh
docker compose logs --tail=200 updater
docker ps --filter label=com.docker.compose.project=javhub
```

基础服务由入口生成的 `.javhub/compose.json` 管理，默认 Compose 仅列出入口。
也可在网页查看组件状态。将上面的 `javhub` 换成自己的项目名。

安装、接管与恢复细节见 [安装与组件管理](docs/deployment-manager.md)。
默认入口也兼容 `docker-compose.protected.yml`。`docker-compose.cloudflare.yml`
仅供保留完整服务的旧部署叠加使用，不能叠加到新版入口文件。
