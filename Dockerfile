FROM ubuntu:24.04

# Set environment variable to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Установка базовых зависимостей и инструментов разработки
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    software-properties-common \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Установка Ruby 3.2+ из официального репозитория Ubuntu 24.04
RUN apt-get update && apt-get install -y \
    ruby-full \
    ruby-bundler \
    ruby-dev \
    && rm -rf /var/lib/apt/lists/* \
    && ruby --version

# Create a non-root user for running the application
# This is a security best practice and prevents issues with Bundler
RUN groupadd -r appuser && useradd -r -g appuser -m appuser

# Установка рабочего каталога
WORKDIR /app

# Копирование файлов проекта
COPY . /app

# Change ownership of the application directory to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Configure Bundler to use local vendor directory (best practice)
RUN cd ruby && bundle config set --local path 'vendor/bundle'

CMD ["bash"]
