FROM ubuntu:20.04

# Установка базовых зависимостей
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    ruby-full \
    && rm -rf /var/lib/apt/lists/*

# Установка Bundler
RUN gem install bundler

# Установка рабочего каталога
WORKDIR /app

# Копирование файлов проекта
COPY . /app

CMD ["bash"]
