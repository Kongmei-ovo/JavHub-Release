# 安装与组件管理

入口更新器现在包含独立的桌面安装与管理页：`/_updater/manage`。
它在 JavHub 未安装、未激活或停机时也能工作。第一阶段支持官方基础服务、
FlareSolverr 配置及 AVDB 的停用、本机安装和已有服务连接。

## 新安装

在项目目录保存默认 `docker-compose.yml`（或等价的 `docker-compose.bootstrap.yml`），确认其中的宿主机项目目录和入口端口。
启动入口后访问原网页地址。第一次打开会进入安装页；从 updater 日志复制首次配对码，
设置独立的部署管理员密码，不勾选“接管已经运行的部署”。

网页中填写基础配置，选择是否使用 AVDB，然后保存并应用。
数据库密码和内部令牌可以留空，由入口生成。激活码可以稍后填写：先安装，
在页面取得实例 ID，申请激活码后再保存。主程序实际就绪后提示“进入 JavHub”，
安装中、待激活、恢复中或主程序不可用时不显示完成提示。资料库的首次导入继续使用 JavHub 原有界面。

```sh
docker compose up -d
docker compose logs updater
```

入口会在同一个 Compose 项目和默认网络内创建基础容器；数据存放在项目的
`config`、`data`、`storage` 目录。AVDB 默认关闭。
新部署的数据库初始化通过内部网络认证连接，不挂载 PostgreSQL Unix socket，
适用于 Docker Desktop、Colima 等共享文件系统。首次初始化中断后会补建缺失数据库。

## 已有安装的一次迁移

首次迁移保持原 Compose 项目名称、项目目录和对外端口，只更新入口。
替换为新版入口 Compose 前，备份旧文件、`.env`、数据目录及原数据卷。
使用 `docker compose pull updater` 和 `docker compose up -d updater`，不要删除孤立容器。
没有旧入口的部署先通过原 Compose 停止 JavHub，释放它占用的网页端口，保留容器。

管理页检测到原部署会选择“接管已有部署”。确认后优先读取旧 Compose；如果旧文件
已经被入口文件替换，则从同一项目的现有容器读取环境变量、挂载、网络和数据卷名称。
这只是读取原个人配置，不修改容器。停止的容器也能接管；已有数据库及影片资料
无需重新初始化或导入。原命名卷按实际卷名声明为 external，不会创建一个新空卷。
设备身份和 config.yaml 沿用原挂载。旧密码、授权、集成设置归入个人配置，
启动命令和健康检查等通用部分由官方模板维护。

已生成 `.javhub` 的实例重启入口后直接加载个人配置，无需重新接管。
原容器已经删除、外部数据库、自定义服务或特殊容器权限不自动推断，接管前会说明原因。
原应用 config.yaml 中的 AVDB API Key 可在管理页补填，或使用已有账号取得专用 Key。
原完整 Compose 保存在 `docker-compose.legacy.yml`；主仓库对应覆盖文件为
`docker-compose.legacy.protected.yml`。这些文件是手工部署参考，不应覆盖用户旧密码。

## 配置和组件

- AVDB 本机安装后，页面分别显示容器状态、账号初始化状态及 API Key 验证结果。
  可在管理页创建首次账号，或登录已有账号，取得专用 `javhub-gateway` API Key。
  已开启两步验证的已有账号需自行填写 Key。
- AVDB 的宿主机管理端口保持本地监听。首次账号引导通过入口调用内部接口，
  不需要对局域网开放额外管理端口。
- 停用或切换到外部 AVDB，会在应用新的 JavHub 配置后停止本机 AVDB，保留数据。
  再次选择本机安装会复用原数据。
- FlareSolverr 支持内存上限、空闲页面优化和媒体屏蔽设置。
  保存后比较实际服务定义，只拉取、重建受影响组件。
  发布者可以在模板 `defaults` 中调整这些默认参数，用户自动更新时会应用；
  用户手动修改过的参数和旧部署接管的参数继续保留。
- JavHub 的运行时配置继续使用原设置页。需重启的媒体服务配置和 JavInfo
  补全并发设置，通过固定的内部管理接口交给入口应用；普通开发部署保留原逻辑。
- 接管后的数据库密码第一阶段不提供在线修改，避免隐式修改已有数据库账号。

## 状态、更新与恢复

运行状态每分钟后台检查，网页只读取缓存。AVDB 使用初始化接口和一次认证的
空查询验证连接；FlareSolverr 使用 `sessions.list`，不定期抓取目标网站。
来源真实请求成功率继续由 JavHub 原有来源诊断负责。检查失败不会自动反复重启容器。AVDB 下载或启动失败会单独显示，基础服务继续安装。

官方模板放在更新器镜像的 `/usr/share/javhub/deployment.json`，构建时嵌入同一文件。
发布服务新增 `updater` 版本字段。两种架构镜像和模板验证完成后，构建流程才推广版本。
入口从固定的官方版本镜像读取模板文件，不接受网页传入镜像名称、Shell 命令或挂载路径。
模板 schema 不兼容时先更新入口，由新版入口继续解析和应用，旧入口不会强行应用未知模板。

更新器用一次性的官方镜像辅助容器更新自身，避免自身退出中断 Compose 重建。
原更新器没有管理功能时，仍按原来的应用镜像 OTA 流程工作。

`.javhub` 保存权限为 0600 的管理员状态、用户设置、导入覆盖项、官方模板、
生成部署、运行时令牌和恢复记录；目录权限为 0700。管理密码以 PBKDF2 保存，
网页响应不返回密码、授权码或 API Key。首次配对码完成配对后删除。

应用前先校验配置和下载镜像，再保存恢复记录。旧镜像按运行容器的实际 image ID
固定，失败或入口重启后按记录恢复原容器和配置。首次安装失败则停止已启动的组件，
数据继续保留。不会执行整项目 `down` 或删除数据卷。
数据库和第三方组件内部的数据格式升级并不能仅靠换回镜像撤销；发布此类升级前，
必须另外提供兼容迁移和数据备份方案。

备份时将 `.javhub` 与 `config`、`data`、`storage` 一起保存。它含敏感配置，
不应上传到代码仓库或公开分享。

## 发布顺序

先构建并验收带管理功能的入口镜像，确认正式镜像标签可用，再发布精简 Compose
和迁移说明。旧入口镜像无法安装只含入口的新版配置；不能先让客户替换文件，
再等待镜像发布。首次迁移需要更新入口一次，客户已有数据库和资料继续保留。

## 验证

Go 测试覆盖配对、会话、来源校验、凭据脱敏、固定服务权限、按组件应用、
失败回退、恢复记录及 AVDB 初始化/认证状态。
设置 `JAVHUB_COMPOSE_BINARY` 后，还会使用真实 Compose 验证三个 AVDB 模式和
含 `$` 的密码。专门的更新器 CI 会执行 race 检查和 Compose 验证。

本机使用独立 Docker 项目运行了按正式 Dockerfile 构建的受保护 JavHub、JavInfoApi
和入口镜像，以及真实 PostgreSQL、Redis、FlareSolverr、AVDB。通过了基础安装、
HTTPS 签名授权、网页/API 访问、仅重建变更组件、AVDB 账号与专用 Key 创建、
停用后恢复数据、运行时配置自动重启、入口重启及独立辅助容器替换入口。还实际替换了测试管理状态、从现有容器接管并应用
新版官方配置，确认原数据库记录、数据挂载、密码、授权和实例 ID 均保留。
另用轻量测试容器验证了 AVDB 端口冲突不阻塞主服务和失败后的镜像/配置回退。
真实 NAS 上的旧部署迁移、多架构运行和已发布版本的远程 OTA，仍需发布前验收。
本地验证不会推送镜像、修改线上授权服务或推广发布版本。

本机完整测试使用以下命令。需要 Docker、Python 项目虚拟环境、Node.js，以及
同级 `JavInfoApi` 源码；完整受保护镜像首次编译需要数分钟。

```sh
scripts/local-deployment-test.sh build
scripts/local-deployment-test.sh start
scripts/local-deployment-test.sh test
scripts/local-deployment-test.sh adopt-test
scripts/local-deployment-test.sh status
```

管理页在 `http://127.0.0.1:19300/_updater/manage`，应用首页在同端口。
测试数据、独立签名密钥、7 天测试证书和随机凭据保存在已忽略的
`.javhub/local-deployment-test`，测试管理员密码在 `assets/credentials.json`。
测试使用专属授权服务和信任证书，不使用生产密钥或客户数据。
`scripts/local-deployment-test.sh stop` 只移除带专属标签的测试容器，保留测试数据。
该部署用于本机验收，不应作为客户发布包。

```sh
cd updater
JAVHUB_COMPOSE_BINARY=/path/to/docker-compose go test -race ./...
go vet ./...
```
