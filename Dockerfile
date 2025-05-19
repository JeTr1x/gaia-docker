FROM ubuntu:22.04

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    curl \
    bash \
    sudo \
    ca-certificates \
    jq \
    grep \
    && apt-get clean

# Установка GaiaNet и логирование
RUN curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' \
    | bash | tee /root/gaianet-install.log

# Извлекаем device ID и node ID из лога
RUN grep "The device ID is" /root/gaianet-install.log | awk '{print $5}' > /root/device_id.txt && \
    grep "Your node ID is" /root/gaianet-install.log | awk '{print $6}' > /root/node_id.txt

# Добавляем gaianet в PATH
ENV PATH="/root/gaianet/bin:$PATH"

# Инициализация узла с кастомным конфигом
RUN gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/qwen2-0.5b-instruct/config.json

# Копируем entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Проброс портов
EXPOSE 8080 9068 9069

# Запуск через entrypoint с ловлей сигналов
ENTRYPOINT ["/entrypoint.sh"]
