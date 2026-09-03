# JavHub protected distribution

This public repository contains installation files only. The JavHub and
JavInfoApi source repositories remain private. The distributed containers hold
compiled first-party binaries and require an instance-bound activation code.

## Requirements

- Docker Engine with Docker Compose v2, or the standalone `docker-compose`
- A Linux amd64 or arm64 host
- An activation code issued by the publisher

## Install

```bash
git clone https://github.com/Kongmei-ovo/JavHub-Release.git
cd JavHub-Release
cp .env.example .env
```

Replace every `change-me` value in `.env`, then start once:

```bash
docker compose pull
docker compose up -d
docker compose logs javinfoapi
```

Without a license key, the log prints an instance ID beginning with `jvh-`.
Send that ID to the publisher. Put the returned activation code in
`JAVHUB_LICENSE_KEY` inside `.env`, then run:

```bash
docker compose up -d
```

Open `http://SERVER_IP:3000` after all services become healthy.

## Update

```bash
docker compose pull
docker compose up -d
```

Persistent state is stored in `./config`, `./data`, and named Docker volumes.
Back these up before major upgrades.

## License and cloning boundary

One activation authorizes one installation. JavHub and JavInfoApi share the
same instance ID and signed short-lived grant, so only one activation code is
needed.

Software running on a customer-controlled host cannot provide an absolute
anti-cloning guarantee. Copying the complete configuration directory can copy
the instance identity. Hardware fingerprints are also spoofable in virtualized
environments. The current mechanism prevents casual code sharing and supports
server-side revocation; stronger enforcement would require continuous lease
tracking or hardware-backed remote attestation.

This repository does not grant a source-code license. The protected images and
service are distributed for authorized use only. Third-party containers remain
subject to their respective upstream licenses.
