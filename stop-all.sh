#!/bin/bash

echo "Остановка всех контейнеров gaianet-node-[1-100]..."

for i in $(seq 1 100); do
  CONTAINER_NAME="gaianet-node-$i"
  if docker ps -q -f name="^/${CONTAINER_NAME}$" > /dev/null; then
    echo "Останавливаю $CONTAINER_NAME..."
    docker stop "$CONTAINER_NAME"
  else
    echo "$CONTAINER_NAME не запущен."
  fi
done
