# Image config
IMAGE_NAME = ghcr.io/raidel-a/devcontainer-base
COMMIT_SHA := $(shell git -C .. rev-parse --short HEAD)
TAG_DATE := $(shell date +%Y%m%d)
TAG_LATEST = $(IMAGE_NAME):latest
TAG_COMMIT = $(IMAGE_NAME):$(COMMIT_SHA)
TAG_DATEFULL = $(IMAGE_NAME):$(TAG_DATE)

# Preflight check
check:
	@echo "Checking for 'devcontainer' CLI..."
	@if command -v devcontainer >/dev/null 2>&1; then \
		echo "devcontainer CLI is installed: $$(devcontainer --version)"; \
	else \
		echo "'devcontainer' CLI not found. Install it: npm install -g @devcontainers/cli"; \
		exit 1; \
	fi

# Build image using devcontainer CLI
build: check
	@echo "Building devcontainer image..."
	devcontainer build --workspace-folder .. --image-name $(TAG_LATEST) --no-cache
	@echo "Tagging additional tags: $(TAG_COMMIT), $(TAG_DATEFULL)"
	docker tag $(TAG_LATEST) $(TAG_COMMIT)
	docker tag $(TAG_LATEST) $(TAG_DATEFULL)

# Push to GHCR
push: 
	@echo "Logging in to GHCR..."
	@echo "Using gh CLI for authentication..."
	@if command -v gh >/dev/null 2>&1; then \
		gh auth token | docker login ghcr.io -u raidel-a --password-stdin; \
	else \
		echo "Error: gh CLI not found. Install it or set GH_TOKEN manually"; \
		exit 1; \
	fi
	@echo "Pushing images..."
	docker push $(TAG_LATEST)
	docker push $(TAG_COMMIT)
	docker push $(TAG_DATEFULL)

# Clean up dangling images
clean:
	docker image prune -f

# Show current tags
tags:
	@echo "Latest: $(TAG_LATEST)"
	@echo "Commit: $(TAG_COMMIT)"
	@echo "Date:   $(TAG_DATEFULL)"

.PHONY: check build push clean tags
