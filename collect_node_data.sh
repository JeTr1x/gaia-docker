#!/bin/bash

BASE_DIR="/opt/gaianet-run/data"
OUTPUT_FILE="node_info.csv"

echo "node,server,address,device_id,keystore,password" > "$OUTPUT_FILE"

SERVER_IP=$(curl -4 ifconfig.me)

for NODE_DIR in "$BASE_DIR"/node*/gaianet; do
  NODE_NAME=$(basename "$(dirname "$NODE_DIR")")
  DEVICE_ID_FILE="$NODE_DIR/deviceid.txt"
  NODEID_FILE="$NODE_DIR/nodeid.json"

  if [[ -f "$DEVICE_ID_FILE" && -f "$NODEID_FILE" ]]; then
    DEVICE_ID=$(cat "$DEVICE_ID_FILE")
    ADDRESS=$(jq -r '.address' "$NODEID_FILE")
    KEYSTORE=$(jq -r '.keystore' "$NODEID_FILE")
    PASSWORD=$(jq -r '.password' "$NODEID_FILE")

    echo "$NODE_NAME,$SERVER_IP,$ADDRESS,$DEVICE_ID,$KEYSTORE,$PASSWORD" >> "$OUTPUT_FILE"
  else
    echo "⚠️ Пропущено: $NODE_NAME — отсутствует deviceid.txt или nodeid.json"
  fi
done

echo "✅ Сбор завершён. Результат: $OUTPUT_FILE"
