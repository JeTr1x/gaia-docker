#!/bin/bash

BASE_PORT=10000
CHAT_BASE_PORT1=11000
CHAT_BASE_PORT2=12000
BASE_PATH="/opt/gaianet-run"
IMAGE_NAME="gaianet-node"

mkdir -p "$BASE_PATH/.envs"
mkdir -p "$BASE_PATH/data"
docker build -t "$IMAGE_NAME" .

for i in $(seq 1 100); do
  PORT=$((BASE_PORT + i))
  CHAT1=$((CHAT_BASE_PORT1 + i))
  CHAT2=$((CHAT_BASE_PORT2 + i))
  DATADIR="$BASE_PATH/data/node$i"
  ENVFILE="$BASE_PATH/.envs/node$i.env"
  CONTAINER_NAME="gaianet-node-$i"

  mkdir -p "$DATADIR"

  cat > "$ENVFILE" <<EOF
HOST_PORT=$PORT
CHAT_PORT1=$CHAT1
CHAT_PORT2=$CHAT2
DATA_DIR=$DATADIR
EOF

  echo "Launching $CONTAINER_NAME on ports $PORT, $CHAT1, $CHAT2..."

  docker run -d \
    --name "$CONTAINER_NAME" \
    --env-file "$ENVFILE" \
    -p "$PORT":8080 \
    -p "$CHAT1":9068 \
    -p "$CHAT2":9069 \
    -v "$DATADIR":/root \
    "$IMAGE_NAME"
  echo "Sleeping 60s before next container start"
  sleep 60  
done
