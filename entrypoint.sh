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
CONFIG_FILE="$HOME/gaianet/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
  mkdir $HOME/gaianet
  curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --ggmlcuda 12
  source $HOME/.bashrc
  wget -O "$HOME/gaianet/config.json" https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/qwen-2.5-coder-7b-instruct_rustlang/config.json
  jq '.chat = "https://huggingface.co/gaianet/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-3B-Instruct-Q5_K_M.gguf"' "$CONFIG_FILE" > tmp.$$.json && mv tmp.$$.json "$CONFIG_FILE"
  jq '.chat_name = "Qwen2.5-Coder-3B-Instruct"' "$CONFIG_FILE" > tmp.$$.json && mv tmp.$$.json "$CONFIG_FILE"
  grep '"chat":' $HOME/gaianet/config.json
  grep '"chat_name":' $HOME/gaianet/config.json
  gaianet init
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
