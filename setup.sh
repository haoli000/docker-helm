#!/bin/bash
# Setup script for the docker-helm project

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Helm Docker Images Project Setup         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"
echo ""

# Check Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker is installed"
    docker --version
else
    echo -e "${YELLOW}✗${NC} Docker is not installed"
    echo "  Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check Docker Buildx
if docker buildx version &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker Buildx is available"
else
    echo -e "${YELLOW}✗${NC} Docker Buildx is not available"
    echo "  Buildx is needed for multi-architecture builds"
    echo "  It's included in Docker Desktop or can be installed separately"
fi

# Check if Docker daemon is running
if docker ps &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"
else
    echo -e "${YELLOW}✗${NC} Docker daemon is not running"
    echo "  Please start Docker and try again"
    exit 1
fi

echo ""
echo -e "${BLUE}Making scripts executable...${NC}"
chmod +x build.sh quickstart.sh test.sh
echo -e "${GREEN}✓${NC} Scripts are now executable"

echo ""
echo -e "${BLUE}Creating buildx builder...${NC}"
if docker buildx inspect helm-builder &> /dev/null; then
    echo -e "${GREEN}✓${NC} Buildx builder 'helm-builder' already exists"
else
    docker buildx create --name helm-builder --use
    echo -e "${GREEN}✓${NC} Created buildx builder 'helm-builder'"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup Complete!                           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo ""
echo "1. Run a quick test:"
echo -e "   ${BLUE}./quickstart.sh${NC}"
echo ""
echo "2. Build your first image:"
echo -e "   ${BLUE}make build HELM_VERSION=v3.19.2${NC}"
echo ""
echo "3. Run tests:"
echo -e "   ${BLUE}make test HELM_VERSION=v3.19.2${NC}"
echo ""
echo "4. Read the documentation:"
echo -e "   ${BLUE}cat PROJECT_OVERVIEW.md${NC}"
echo -e "   ${BLUE}cat GETTING_STARTED.md${NC}"
echo ""
echo "5. Configure GitHub Actions:"
echo "   - Push this repository to GitHub"
echo "   - Enable GitHub Actions in repository settings"
echo "   - Workflow will automatically build new Helm releases"
echo ""
echo "For more information:"
echo "  - Full documentation: README.md"
echo "  - Usage examples: EXAMPLES.md"
echo "  - Supported versions: VERSIONS.md"
echo "  - How to contribute: CONTRIBUTING.md"
echo ""
echo -e "${GREEN}Happy Helming! 🚀${NC}"
