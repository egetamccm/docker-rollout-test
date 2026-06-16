#!/usr/bin/env sh
set -eu

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required"
  exit 1
fi

if ! docker rollout --help >/dev/null 2>&1; then
  echo "docker-rollout plugin not found. Install from https://github.com/wowu/docker-rollout"
  exit 1
fi

proxy_port="${PROXY_PORT:-8070}"

echo "Building image with APP_VERSION=${APP_VERSION:-v1}"
docker compose build web

echo "Deploying web without downtime using docker rollout"
docker rollout web --wait-after-healthy 2

echo "Done. Current response:"
curl -fsS "http://localhost:${proxy_port}" | cat
