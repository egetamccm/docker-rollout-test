# docker-rollout-test

[![CI Security](https://github.com/egetamccm/docker-rollout-test/actions/workflows/ci-security.yml/badge.svg)](https://github.com/egetamccm/docker-rollout-test/actions/workflows/ci-security.yml)

Small demo app to test zero-downtime local deployments with Docker Compose and docker-rollout.

## What this demo includes

- A simple Node.js HTTP app (`web`) with version output.
- Nginx reverse proxy (`proxy`) bound to `localhost:${PROXY_PORT:-8080}`.
- Secure multi-stage Dockerfile with distroless non-root runtime.
- Compose setup aligned with docker-rollout caveats:
	- `web` has no `container_name`.
	- `web` has no `ports` mapping (uses `expose` only).

## Prerequisites

- Docker + Docker Compose plugin
- docker-rollout Docker CLI plugin installed

Install docker-rollout plugin (user-local):

```sh
mkdir -p ~/.docker/cli-plugins
curl -L https://raw.githubusercontent.com/wowu/docker-rollout/main/docker-rollout -o ~/.docker/cli-plugins/docker-rollout
chmod +x ~/.docker/cli-plugins/docker-rollout
```

## Start the stack

```sh
docker compose up -d --build
curl -s http://localhost:${PROXY_PORT:-8080}
```

If `8080` is already in use on your machine, choose another port:

```sh
PROXY_PORT=8090 docker compose up -d --build
curl -s http://localhost:8090
```

Expected output is JSON containing `version`, `hostname`, and timestamps.

## Simulate traffic

```sh
PROXY_PORT=8090 ./scripts/load-test.sh 30
```

Use the same `PROXY_PORT` value you used for `docker compose up`.

## Roll out a new version without downtime

```sh
APP_VERSION=v2 PROXY_PORT=8090 ./scripts/deploy.sh
```

This script:

- Builds a fresh image for `web`
- Runs `docker rollout web`
- Waits briefly after healthy
- Prints the current response

## Stop everything

```sh
docker compose down
```

## Security automation

This repository includes:

- CI workflow at `.github/workflows/ci-security.yml`:
	- `npm audit --audit-level=high`
	- Docker image build
	- Trivy image scan that fails on HIGH/CRITICAL findings
- Dependabot config at `.github/dependabot.yml` for:
	- npm updates in `/app`
	- Docker base image updates for `/Dockerfile`
	- GitHub Actions updates

## First PR verification checklist

After pushing this branch, verify in GitHub:

- `CI Security` workflow is triggered on the push/PR.
- `npm audit` step passes (no high/critical vulnerabilities in app deps).
- Trivy image scan passes (no high/critical vulnerabilities blocking the build).
- Dependabot is enabled and opens update PRs on schedule.
