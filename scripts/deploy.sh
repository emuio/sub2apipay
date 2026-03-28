#!/usr/bin/env bash

set -euo pipefail

DEPLOY_DIR="${DEPLOY_DIR:-$HOME/sub2apipay-deploy}"
COMPOSE_FILE="${COMPOSE_FILE:-${DEPLOY_DIR}/docker-compose.yml}"
SERVICE="${SERVICE:-app}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found in PATH" >&2
  exit 1
fi

if [ ! -d "${DEPLOY_DIR}" ]; then
  echo "missing deploy directory: ${DEPLOY_DIR}" >&2
  exit 1
fi

if [ ! -f "${COMPOSE_FILE}" ]; then
  echo "missing compose file: ${COMPOSE_FILE}" >&2
  exit 1
fi

cd "${DEPLOY_DIR}"

echo "Pulling latest image for ${SERVICE}..."
docker compose -f "${COMPOSE_FILE}" pull "${SERVICE}"

echo "Restarting ${SERVICE}..."
docker compose -f "${COMPOSE_FILE}" up -d "${SERVICE}"

CONTAINER_ID="$(docker compose -f "${COMPOSE_FILE}" ps -q "${SERVICE}")"

if [ -n "${CONTAINER_ID}" ]; then
  echo "Current running image:"
  docker inspect --format '{{.Config.Image}}' "${CONTAINER_ID}"
fi

echo "Service status:"
docker compose -f "${COMPOSE_FILE}" ps "${SERVICE}"

echo "Recent logs:"
docker compose -f "${COMPOSE_FILE}" logs --tail=20 "${SERVICE}"
