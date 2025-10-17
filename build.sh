#!/bin/bash

# Build script for multi-architecture Docker images
# This script builds images for both ARM64 (Apple Silicon) and AMD64 (Intel) architectures

set -e

IMAGE_NAME="bookstore"
TAG=${1:-latest}
REGISTRY=${2:-"{YOUR_DOCKER_HUB_USERNAME_HERE}"}  # Provide your Docker Hub username

echo "Building multi-architecture Docker image: ${IMAGE_NAME}:${TAG}"

# Create buildx builder if it doesn't exist
docker buildx inspect multiarch >/dev/null 2>&1 || {
    echo "Creating new buildx builder..."
    docker buildx create --name multiarch --use
}

# Use the multiarch builder
docker buildx use multiarch

# Build and push multi-architecture image
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag ${REGISTRY}/${IMAGE_NAME}:${TAG} \
    --push \
    .

echo "Multi-architecture image built and pushed successfully!"
echo "Image: ${REGISTRY}/${IMAGE_NAME}:${TAG}"

# If you want to build only for your current architecture locally:
# docker build -t ${IMAGE_NAME}:${TAG} .