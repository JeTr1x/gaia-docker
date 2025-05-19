#!/bin/bash
set -e

export PATH="/root/gaianet/bin:$PATH"

# Установка ноды, если ещё нет папки
if [ ! -d "/root/gaianet" ]; then
  echo "[EPLOG] Installing GaiaNet node..."
  curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash | tee /root/gaianet-install.log

  grep "[EPLOG] The device ID is" /root/gaianet-install.log | awk '{print $5}' > /root/device_id.txt
  grep "[EPLOG] Your node ID is" /root/gaianet-install.log | awk '{print $6}' > /root/node_id.txt
fi

# Проверяем наличие файла модели в папке gaianet
MODEL_PATH="/root/gaianet/Qwen2-0.5B-Instruct-Q5_K_M.gguf"
if [ ! -f "$MODEL_PATH" ]; then
  echo "[EPLOG] Model file not found, running init..."
  gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/qwen2-0.5b-instruct/config.json
else
  echo "[EPLOG] Model file found, skipping init."
fi

trap "echo '[EPLOG] Stopping GaiaNet...'; gaianet stop; exit 0" SIGINT SIGTERM

echo "[EPLOG] Starting GaiaNet node..."
exec gaianet start &

sleep 20

tail -F /root/gaianet/log/*.log &
TAIL_PID=$!

# Ждём, пока процесс gaianet живёт
while pgrep -f gaianet > /dev/null; do
  sleep 5
done

echo "[EPLOG] GaiaNet process stopped, killing tail..."
kill $TAIL_PID

echo "[EPLOG] Exiting container."
