FROM ubuntu:24.04

# Set environment variable to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Установка базовых зависимостей
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Установка Ruby 3.2+ из официального репозитория Ubuntu 24.04
RUN apt-get update && apt-get install -y \
    ruby-full \
    ruby-bundler \
    && rm -rf /var/lib/apt/lists/* \
    && ruby --version

# Установка рабочего каталога
WORKDIR /app

# Копирование файлов проекта
COPY . /app

CMD ["bash"]
