.PHONY: all test clean docker-build docker-run docker-stop

# Default action runs tests and builds the container
all: test docker-build

# Run the verified 20+ unit and widget test suite
test:
	@echo "🧪 Running Flutter test suite..."
	flutter test

# Clean build artifacts
clean:
	@echo "🧹 Cleaning project..."
	flutter clean
	flutter pub get

# Build the production Docker container
docker-build:
	@echo "🐳 Building Docker image for Kasi Bites Dashboard..."
	docker build -t kasi-bites-dashboard:latest .

# Spin up the container locally on port 8080
docker-run:
	@echo "🚀 Starting Kasi Bites container on http://localhost:8080..."
	docker run -d -p 8080:80 --name kasi-dashboard-app kasi-bites-dashboard:latest

# Stop and remove the local test container
docker-stop:
	@echo "🛑 Stopping local container..."
	docker stop kasi-dashboard-app || true
	docker rm kasi-dashboard-app || true