# Stage 1: Build the Flutter Web application using Ubuntu and official Flutter SDK
FROM ubuntu:22.04 AS build

# Install essential build tools and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and extract official Flutter SDK (stable channel)
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable web support and run doctor
RUN flutter config --enable-web && flutter precache --web

WORKDIR /app

# Copy dependency specification files and fetch packages
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application source code
COPY . .

# Build production web release
RUN flutter build web --release

# Stage 2: Serve via high-performance Nginx server
FROM nginx:alpine

# Copy built web assets to Nginx public directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose HTTP port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]