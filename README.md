# JavHub 安装

本仓库只提供安装文件；JavHub 和 JavInfoApi 源码不公开。

在 Linux amd64 或 arm64 服务器上安装 Docker Compose 后，执行：

```bash
git clone https://github.com/Kongmei-ovo/JavHub-Release.git
cd JavHub-Release
cp .env.example .env
# 编辑 .env：将所有 change-me 改为你自己的密码；JAVHUB_LICENSE_KEY 暂时留空
docker compose pull
docker compose up -d
docker compose logs javinfoapi
```

日志会显示以 `jvh-` 开头的实例 ID。将该 ID 发给发布者，收到激活码后填入 `.env` 的 `JAVHUB_LICENSE_KEY`，然后执行：

```bash
docker compose up -d
```

打开 `http://服务器IP:3000` 即可使用。

更新版本：

```bash
docker compose pull && docker compose up -d
```

请备份 `./config`、`./data` 和 Docker 数据卷。一个激活码只授权一个安装实例。
