FROM ruby:3.2-slim

# Установка базовых зависимостей
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    build-essential \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Bundler уже установлен в образе ruby

# Установка рабочего каталога
WORKDIR /app

# Копирование файлов проекта
COPY . /app

CMD ["bash"]
