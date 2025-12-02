# Makefile for Helm Docker Images

.PHONY: help build test push clean quickstart

# Variables
HELM_VERSION ?= v3.19.2
REGISTRY ?= docker.io
IMAGE_NAME ?= helm
PLATFORMS ?= linux/amd64,linux/arm64

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

build: ## Build Docker image for specified HELM_VERSION (default: v3.19.2)
	@echo "Building Helm $(HELM_VERSION) image..."
	docker build --build-arg HELM_VERSION=$(HELM_VERSION) -t $(IMAGE_NAME):$(HELM_VERSION) .

build-multi: ## Build multi-architecture image
	@echo "Building multi-arch image for Helm $(HELM_VERSION)..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg HELM_VERSION=$(HELM_VERSION) \
		-t $(REGISTRY)/$(IMAGE_NAME):$(HELM_VERSION) \
		--load \
		.

test: ## Test the built image
	@echo "Testing Helm $(HELM_VERSION) image..."
	docker run --rm $(IMAGE_NAME):$(HELM_VERSION) version
	docker run --rm $(IMAGE_NAME):$(HELM_VERSION) --help
	@echo "✅ Tests passed!"

push: ## Build and push multi-arch image to registry
	@echo "Building and pushing multi-arch image..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg HELM_VERSION=$(HELM_VERSION) \
		-t $(REGISTRY)/$(IMAGE_NAME):$(HELM_VERSION) \
		--push \
		.

build-latest: ## Build latest 5 Helm versions
	./build.sh --latest 5

build-all: ## Build all recent stable versions
	./build.sh --all-stable

quickstart: ## Run quickstart script for quick testing
	./quickstart.sh $(HELM_VERSION)

clean: ## Clean up local images
	@echo "Cleaning up Docker images..."
	docker images | grep "$(IMAGE_NAME)" | awk '{print $$3}' | xargs -r docker rmi -f
	@echo "✅ Cleanup complete!"

shell: ## Start interactive shell in container
	docker run --rm -it \
		-v ~/.kube:/home/helm/.kube \
		-v $(PWD):/apps \
		-w /apps \
		$(IMAGE_NAME):$(HELM_VERSION) sh

lint-dockerfile: ## Lint Dockerfile using hadolint
	@command -v hadolint >/dev/null 2>&1 || { echo "hadolint not installed. Install from: https://github.com/hadolint/hadolint"; exit 1; }
	hadolint Dockerfile

lint-scripts: ## Lint shell scripts using shellcheck
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not installed. Install from: https://www.shellcheck.net/"; exit 1; }
	shellcheck build.sh quickstart.sh

lint: lint-dockerfile lint-scripts ## Run all linters

# Examples
examples: ## Show usage examples
	@echo "Common usage examples:"
	@echo ""
	@echo "  Build specific version:"
	@echo "    make build HELM_VERSION=v3.19.2"
	@echo ""
	@echo "  Build and test:"
	@echo "    make build test HELM_VERSION=v4.0.1"
	@echo ""
	@echo "  Build and push to registry:"
	@echo "    make push HELM_VERSION=v3.19.2 REGISTRY=ghcr.io/myorg"
	@echo ""
	@echo "  Build multiple versions:"
	@echo "    make build-latest"
	@echo ""
	@echo "  Interactive shell:"
	@echo "    make shell HELM_VERSION=v3.19.2"
	@echo ""
	@echo "  Quick test:"
	@echo "    make quickstart HELM_VERSION=v3.19.2"
