#!/bin/bash
# Quick start script for testing the Helm Docker image locally

set -e

HELM_VERSION="${1:-v3.19.2}"
IMAGE_NAME="helm-test:${HELM_VERSION}"

echo "🚀 Helm Docker Image Quick Start"
echo "================================="
echo ""
echo "Building Helm ${HELM_VERSION} image..."
echo ""

# Build the image
docker build --build-arg HELM_VERSION="${HELM_VERSION}" -t "${IMAGE_NAME}" .

echo ""
echo "✅ Image built successfully!"
echo ""
echo "Testing the image..."
echo ""

# Test the image
echo "1. Checking Helm version:"
docker run --rm "${IMAGE_NAME}" version

echo ""
echo "2. Listing Helm commands:"
docker run --rm "${IMAGE_NAME}" --help | head -20

echo ""
echo "3. Checking installed tools:"
docker run --rm "${IMAGE_NAME}" sh -c "which git bash curl jq"

echo ""
echo "✅ All tests passed!"
echo ""
echo "📝 Usage examples:"
echo ""
echo "   # Run Helm commands:"
echo "   docker run --rm ${IMAGE_NAME} version"
echo ""
echo "   # Mount your charts directory:"
echo "   docker run --rm -v \$(pwd):/apps ${IMAGE_NAME} lint /apps/my-chart"
echo ""
echo "   # Interactive shell:"
echo "   docker run --rm -it ${IMAGE_NAME} sh"
echo ""
echo "   # With kubeconfig:"
echo "   docker run --rm -v ~/.kube:/home/helm/.kube ${IMAGE_NAME} list"
echo ""
echo "For more examples, see EXAMPLES.md"
echo ""
