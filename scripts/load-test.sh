#!/usr/bin/env sh
set -eu

duration="${1:-20}"
proxy_port="${PROXY_PORT:-8080}"
end_time=$(( $(date +%s) + duration ))

while [ "$(date +%s)" -lt "$end_time" ]; do
  ts="$(date +%H:%M:%S)"
  response="$(curl -s "http://localhost:${proxy_port}" || true)"
  echo "${ts} ${response}"
  sleep 1
done
