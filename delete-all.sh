#!/bin/bash

BASE_PATH="/opt/gaianet-run"

echo "Удаление контейнеров gaianet-node-[1-100]..."

for i in $(seq 1 100); do
  CONTAINER_NAME="gaianet-node-$i"
  if docker ps -a -q -f name="^/${CONTAINER_NAME}$" > /dev/null; then
    echo "Удаляю контейнер $CONTAINER_NAME..."
    docker rm -f "$CONTAINER_NAME"
  fi
done

echo "Удаление данных в $BASE_PATH..."
rm -rf "$BASE_PATH/data"
rm -rf "$BASE_PATH/.envs"

echo "Готово."
