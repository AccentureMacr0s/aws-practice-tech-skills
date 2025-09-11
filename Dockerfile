FROM ubuntu:20.04

# Установка базовых зависимостей
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    ruby-full \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Установка Bundler
RUN gem install bundler

# Установка рабочего каталога
WORKDIR /app

# Копирование файлов проекта
COPY . /app

# Установка Ruby зависимостей из ruby/Gemfile
WORKDIR /app/ruby
RUN bundle install

# Возврат в основной рабочий каталог
WORKDIR /app

# Создание non-root пользователя для безопасности
RUN useradd -m -s /bin/bash appuser && \
    chown -R appuser:appuser /app
USER appuser

CMD ["bash"]
