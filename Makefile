SHELL=/bin/bash -o pipefail

IMAGE_NAME = hangxie/hadoop-all-in-one
CONTAINER_NAME = hadoop-test

.PHONY: help build test run clean

help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		cut -d ":" -f1- | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

build: ## Build the Docker image
	@docker build -t $(IMAGE_NAME) .

test: ## Run tests
	@./test-hdfs-commands.sh

run: ## Run container interactively for manual testing
	@docker run -d --name $(CONTAINER_NAME) \
		-p 8030-8088:8030-8088 \
		-p 9000:9000 \
		-p 9864-9870:9864-9870 \
		$(IMAGE_NAME)

clean: ## Clean up containers and images
	@docker rm -f $(CONTAINER_NAME) 2>/dev/null
	@docker rmi -f $(IMAGE_NAME) 2>/dev/null
