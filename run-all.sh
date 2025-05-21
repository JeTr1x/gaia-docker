#!/bin/bash
set -e

IMAGE_NAME="gaianet-image"  # Замените на имя вашего образа

# Настройки для 5 контейнеров
CONTAINERS=5

# Начальные значения портов (пример, меняйте под свои)
API_PORT_BASE=8010
CHAT_UI_PORT_BASE=9068
CHAT_WS_PORT_BASE=9069

# Папка для данных (пример)
DATA_DIR_BASE="/opt/gaianet-run"

for i in $(seq 0 $((CONTAINERS - 1))); do
  CONTAINER_NAME="gaianet-$i"
  API_PORT=$((API_PORT_BASE + i))
  CHAT_UI_PORT=$((CHAT_UI_PORT_BASE + i))
  CHAT_WS_PORT=$((CHAT_WS_PORT_BASE + i))
  DATA_DIR="${DATA_DIR_BASE}/node$i"
  GPU_DEVICE=$i

  mkdir -p "$DATA_DIR"

  echo "Запускаем контейнер $CONTAINER_NAME с портами $API_PORT, $CHAT_UI_PORT, $CHAT_WS_PORT, GPU $GPU_DEVICE, данными $DATA_DIR"

  docker run -d \
    --name "$CONTAINER_NAME" \
    -p ${API_PORT}:8080 \
    -p ${CHAT_UI_PORT}:9068 \
    -p ${CHAT_WS_PORT}:9069 \
    -v "${DATA_DIR}:/root" \
    --gpus "device=$GPU_DEVICE" \
    --restart unless-stopped \
    "$IMAGE_NAME"
done
