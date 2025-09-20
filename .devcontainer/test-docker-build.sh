#!/usr/bin/env bash
set -euo pipefail

# Script to test the devcontainer Docker build locally
# This mimics the build process used by GitHub Codespaces

echo "🐳 Testing devcontainer Docker build locally..."

# Get the folder basename (used as build arg)
FOLDER_BASENAME=$(basename "$PWD")
RUST_VERSION="1.89.0"

echo "📁 Folder basename: $FOLDER_BASENAME"
echo "🦀 Rust version: $RUST_VERSION"

# Build the Docker image
echo "🔨 Building Docker image..."
docker build \
  --file .devcontainer/Dockerfile \
  --build-arg RUST_VERSION="$RUST_VERSION" \
  --build-arg FOLDER_BASENAME="$FOLDER_BASENAME" \
  --build-arg CODESPACES_ENVIRONMENT="local" \
  --tag "test-devcontainer:latest" \
  .

echo "✅ Docker build completed successfully!"

# Optional: Run the container to test it works
echo ""
echo "🚀 To test the container interactively, run:"
echo "   docker run -it --rm test-devcontainer:latest bash"
echo ""
echo "🧪 To run a quick test inside the container:"
echo "   docker run --rm test-devcontainer:latest bash -c 'rustc --version && cargo --version'"

# Run the quick test automatically
echo "🧪 Running quick verification test..."
docker run --rm test-devcontainer:latest bash -c 'rustc --version && cargo --version && mise --version'

echo "🎉 All tests passed! Your devcontainer builds correctly."
