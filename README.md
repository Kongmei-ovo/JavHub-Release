# JavHub 安装

1. 在 NAS 或服务器上创建一个目录，例如 `/volume1/docker/javhub`。
2. 在 Docker / Container Manager 中新建 Compose 项目，复制粘贴 [docker-compose.yml](docker-compose.yml)。
3. 把文件顶部的目录改成你刚创建的目录：

   ```yaml
   x-project-dir: &project-dir "/volume1/docker/javhub"
   ```

4. 保存并启动，打开 `http://NAS的IP:3000`。
5. 按网页提示完成安装。首次配对码在 `updater` 容器日志里，其他配置在网页中填写。

默认网页端口为 **3000**，媒体端口为 **18090**；需要时修改 Compose 中对应的端口。

使用命令行时，将文件保存为项目目录里的 `docker-compose.yml`，在该目录运行：

```sh
docker compose up -d
```

已有安装的升级方法见 [升级与组件管理说明](docs/deployment-manager.md)。
