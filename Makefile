# =============================================================================
# Makefile for CIN Maternal DQA
# =============================================================================

.PHONY: help build run dev clean shell logs

help:
	@echo "Available commands:"
	@echo "  make build  - Build Docker image"
	@echo "  make run    - Run DQA in Docker"
	@echo "  make dev    - Run DQA in development mode (with code mounting)"
	@echo "  make clean  - Clean Docker containers and images"
	@echo "  make shell  - Open shell in container"
	@echo "  make logs   - View container logs"

build:
	docker-compose build

run:
	./docker_run.sh

dev:
	./docker_dev.sh

clean:
	./docker_clean.sh

shell:
	docker-compose run --rm dqa /bin/bash

logs:
	docker-compose logs -f

# Quick test
test:
	docker-compose run --rm dqa Rscript -e "cat('Docker is working!\n')"
