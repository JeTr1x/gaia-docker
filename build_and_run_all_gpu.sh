#!/bin/bash
set -e

REPO_URL="https://github.com/JeTr1x/gaia-docker.git"
BRANCH="gpu"
CLONE_DIR="gaia-docker-gpu"
IMAGE_NAME="gaianet-gpu"

API_PORT_BASE=38000
CHAT_UI_PORT_BASE=39068
CHAT_WS_PORT_BASE=39069
DATA_DIR_BASE="$HOME/gaianet_data"

if [ -d "$CLONE_DIR" ]; then
  echo "[INFO] Репозиторий уже клонирован, обновляем..."
  cd "$CLONE_DIR"
  git fetch
  git checkout "$BRANCH"
  git pull origin "$BRANCH"
  cd ..
else
  echo "[INFO] Клонируем репозиторий..."
  git clone --branch "$BRANCH" "$REPO_URL" "$CLONE_DIR"
fi

echo "[INFO] Собираем Docker образ $IMAGE_NAME..."
docker build -t "$IMAGE_NAME" "$CLONE_DIR"

GPU_COUNT=$(nvidia-smi --list-gpus | wc -l)
echo "[INFO] Найдено GPU: $GPU_COUNT"

if [ "$GPU_COUNT" -eq 0 ]; then
  echo "[ERROR] Не найдено ни одной GPU, прерываем."
  exit 1
fi

for (( i=0; i<GPU_COUNT; i++ )); do
  CONTAINER_NAME="gaianet-gpu-$i"
  API_PORT=$((API_PORT_BASE + i))
  CHAT_UI_PORT=$((CHAT_UI_PORT_BASE + i))
  CHAT_WS_PORT=$((CHAT_WS_PORT_BASE + i))
  DATA_DIR="${DATA_DIR_BASE}/node$i"

  mkdir -p "$DATA_DIR"

  echo "[INFO] Запускаем контейнер $CONTAINER_NAME с GPU $i, портами $API_PORT:$CHAT_UI_PORT:$CHAT_WS_PORT, данными $DATA_DIR"

  docker run -d \
    --name "$CONTAINER_NAME" \
    -p ${API_PORT}:8080 \
    -p ${CHAT_UI_PORT}:9068 \
    -p ${CHAT_WS_PORT}:9069 \
    -v "${DATA_DIR}:/root" \
    --gpus "device=$i" \
    --restart unless-stopped \
    "$IMAGE_NAME"

  echo "[INFO] Ждём 3 минуты перед запуском следующего контейнера..."
  sleep 180
done

echo "[INFO] Запущено $GPU_COUNT контейнеров."

