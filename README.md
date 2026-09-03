# JavHub Installation

This repository only provides installation files. The source code for JavHub and JavInfoApi is not publicly available.

On a Linux amd64 or arm64 server, install Docker Compose and then run:

```bash
git clone https://github.com/Kongmei-ovo/JavHub-Release.git
cd JavHub-Release
cp .env.example .env
# Edit .env: replace all "change-me" values with your own passwords.
# Leave JAVHUB_LICENSE_KEY empty for now.
docker compose pull
docker compose up -d
docker compose logs javinfoapi
```

The logs will display an instance ID starting with `jvh-`. Send this ID to the publisher. After receiving the activation key, set it as `JAVHUB_LICENSE_KEY` in `.env`, then run:

```bash
docker compose up -d
```

Open `http://SERVER_IP:3000` in your browser to access JavHub.

To update to the latest version:

```bash
docker compose pull && docker compose up -d
```

Please back up `./config`, `./data`, and the Docker volumes regularly.

Each activation key is licensed for one installation instance only.
