#!/bin/bash
# populate-helm-images.sh
# Script to build and push all Helm versions from v3.17.0 onwards that don't exist in Docker Hub

set -e

MIN_VERSION="v3.17.0"
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-haoli1}"
IMAGE_NAME="${IMAGE_NAME:-helm}"

echo "=========================================="
echo "Populating Helm Images to Docker Hub"
echo "=========================================="
echo "Registry: docker.io/${DOCKER_HUB_USERNAME}/${IMAGE_NAME}"
echo "Minimum version: ${MIN_VERSION}"
echo ""

# Get all Helm releases >= v3.17.0 (excluding rc, alpha, beta releases)
echo "[INFO] Fetching Helm releases from GitHub..."
releases=$(curl -s "https://api.github.com/repos/helm/helm/releases?per_page=100" | \
  jq -r '.[].tag_name' | \
  grep -E '^v3\.(1[7-9]|[2-9][0-9])\.[0-9]+$' | \
  sort -V)

if [ -z "$releases" ]; then
  echo "[ERROR] Failed to fetch releases"
  exit 1
fi

total=$(echo "$releases" | wc -l | tr -d ' ')
echo "[INFO] Found $total releases to check"
echo ""

count=0
success=0
skipped=0
failed=0

for version in $releases; do
  count=$((count + 1))
  echo "[$count/$total] Checking $version..."
  
  # Check if image exists on Docker Hub
  status=$(curl -s -o /dev/null -w "%{http_code}" \
    "https://hub.docker.com/v2/repositories/${DOCKER_HUB_USERNAME}/${IMAGE_NAME}/tags/${version}")
  
  if [ "$status" = "200" ]; then
    echo "  ✓ Already exists, skipping"
    skipped=$((skipped + 1))
  else
    echo "  → Building and pushing..."
    
    if ./build.sh --push "$version"; then
      echo "  ✓ Successfully built and pushed"
      success=$((success + 1))
    else
      echo "  ✗ Failed to build"
      failed=$((failed + 1))
    fi
  fi
  
  echo ""
done

echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Total versions checked: $total"
echo "Successfully built: $success"
echo "Skipped (already exist): $skipped"
echo "Failed: $failed"
echo "=========================================="

if [ $failed -gt 0 ]; then
  exit 1
fi
