#!/bin/bash

# Обработка завершения
trap "echo 'Stopping GaiaNet...'; gaianet stop; exit 0" SIGINT SIGTERM

echo "Starting GaiaNet node..."
gaianet start &
wait $!
