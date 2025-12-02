#!/bin/bash
set -e

# Build script for Helm Docker images
# This script can build images for specific versions or fetch the latest releases

REGISTRY="${DOCKER_REGISTRY:-docker.io}"
IMAGE_NAME="${IMAGE_NAME:-helm}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to fetch latest Helm releases from GitHub
fetch_latest_releases() {
    local count=${1:-10}
    log_info "Fetching latest $count Helm releases from GitHub..."
    
    curl -s "https://api.github.com/repos/helm/helm/releases?per_page=$count" | \
        jq -r '.[].tag_name' | \
        grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' || true
}

# Function to get latest Alpine version
get_alpine_version() {
    local alpine_version=$(curl -s https://hub.docker.com/v2/repositories/library/alpine/tags | \
        jq -r '.results[] | select(.name | test("^[0-9]+\\.[0-9]+$")) | .name' | \
        sort -V | tail -1)
    
    if [ -z "$alpine_version" ]; then
        echo "latest"
    else
        echo "$alpine_version"
    fi
}

# Function to build a single version
build_version() {
    local version=$1
    local push=${2:-false}
    local platforms=${3:-$PLATFORMS}
    
    log_info "Building Helm $version for platforms: $platforms"
    
    # Get latest Alpine version
    log_info "Fetching latest Alpine version..."
    local alpine_version=$(get_alpine_version)
    log_info "Using Alpine version: $alpine_version"
    
    local tag="${REGISTRY}/${IMAGE_NAME}:${version}"
    local latest_tag=""
    
    # Check if this is the latest stable release
    if [ "$version" = "$(fetch_latest_releases 1)" ]; then
        latest_tag="${REGISTRY}/${IMAGE_NAME}:latest"
        log_info "This is the latest stable release, tagging as 'latest'"
    fi
    
    # Build command
    local build_cmd="docker buildx build \
        --platform $platforms \
        --build-arg HELM_VERSION=$version \
        --build-arg ALPINE_VERSION=$alpine_version \
        -t $tag"
    
    if [ -n "$latest_tag" ]; then
        build_cmd="$build_cmd -t $latest_tag"
    fi
    
    if [ "$push" = "true" ]; then
        build_cmd="$build_cmd --push"
    else
        # For local builds, check if multi-platform
        if [[ "$platforms" == *","* ]]; then
            log_warn "Multi-platform build without push - image will not be loaded to local Docker"
            # Multi-platform requires push or output to a directory
            # We'll just build without loading
        else
            build_cmd="$build_cmd --load"
        fi
    fi
    
    build_cmd="$build_cmd ."
    
    log_info "Executing: $build_cmd"
    eval $build_cmd
    
    if [ $? -eq 0 ]; then
        log_info "Successfully built $tag"
        return 0
    else
        log_error "Failed to build $tag"
        return 1
    fi
}

# Function to build multiple versions
build_multiple() {
    local versions=("$@")
    local failed=()
    
    for version in "${versions[@]}"; do
        if ! build_version "$version" "$PUSH"; then
            failed+=("$version")
        fi
    done
    
    if [ ${#failed[@]} -gt 0 ]; then
        log_error "Failed to build the following versions:"
        printf '%s\n' "${failed[@]}"
        return 1
    fi
    
    log_info "All versions built successfully!"
}

# Show usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [VERSION...]

Build Helm Docker images for specific versions or latest releases.

OPTIONS:
    -h, --help              Show this help message
    -p, --push              Push images to registry after building
    -l, --latest [N]        Build latest N releases (default: 10)
    -a, --all-stable        Build all stable releases from current page
    --platforms PLATFORMS   Build for specific platforms (default: linux/amd64,linux/arm64)
    --registry REGISTRY     Docker registry to use (default: docker.io)
    --image-name NAME       Image name (default: helm)

EXAMPLES:
    # Build specific version
    $0 v3.19.2

    # Build multiple specific versions
    $0 v3.19.2 v4.0.1

    # Build latest 5 releases
    $0 --latest 5

    # Build and push to registry
    $0 --push v3.19.2

    # Build for specific platform only
    $0 --platforms linux/amd64 v3.19.2

    # Build with custom registry
    $0 --registry ghcr.io/myorg --image-name helm v3.19.2

EOF
}

# Parse arguments
PUSH=false
BUILD_LATEST=false
LATEST_COUNT=10
VERSIONS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -p|--push)
            PUSH=true
            shift
            ;;
        -l|--latest)
            BUILD_LATEST=true
            if [[ $2 =~ ^[0-9]+$ ]]; then
                LATEST_COUNT=$2
                shift
            fi
            shift
            ;;
        -a|--all-stable)
            BUILD_LATEST=true
            LATEST_COUNT=50
            shift
            ;;
        --platforms)
            PLATFORMS="$2"
            shift 2
            ;;
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        --image-name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        v*)
            VERSIONS+=("$1")
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main logic
main() {
    # Check if docker buildx is available
    if ! docker buildx version &> /dev/null; then
        log_error "docker buildx is not available. Please install it first."
        exit 1
    fi
    
    # Create buildx builder if not exists
    if ! docker buildx inspect helm-builder &> /dev/null; then
        log_info "Creating buildx builder 'helm-builder'"
        docker buildx create --name helm-builder --use
    else
        docker buildx use helm-builder
    fi
    
    if [ "$BUILD_LATEST" = true ]; then
        log_info "Fetching latest $LATEST_COUNT releases..."
        mapfile -t VERSIONS < <(fetch_latest_releases "$LATEST_COUNT")
        
        if [ ${#VERSIONS[@]} -eq 0 ]; then
            log_error "No versions found"
            exit 1
        fi
        
        log_info "Found ${#VERSIONS[@]} versions to build:"
        printf '%s\n' "${VERSIONS[@]}"
    elif [ ${#VERSIONS[@]} -eq 0 ]; then
        log_error "No versions specified. Use --latest or provide version numbers."
        usage
        exit 1
    fi
    
    build_multiple "${VERSIONS[@]}"
}

main
