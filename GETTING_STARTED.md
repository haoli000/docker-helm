# Getting Started with Helm Docker Images

This guide will help you get started with using and building Helm Docker images quickly.

## Prerequisites

- Docker installed (version 20.10+)
- Docker Buildx (for multi-architecture builds)
- Basic knowledge of Helm and Kubernetes
- (Optional) Access to a Kubernetes cluster for testing

## Quick Start (5 minutes)

### 1. Clone the Repository

```bash
git clone https://github.com/[your-username]/docker-helm.git
cd docker-helm
```

### 2. Run the Quick Start Script

```bash
./quickstart.sh
```

This will:
- Build a Helm v3.19.2 image
- Test the image
- Show usage examples

### 3. Try Your First Helm Command

```bash
# Check Helm version
docker run --rm helm-test:v3.19.2 version

# Get help
docker run --rm helm-test:v3.19.2 --help
```

## Building Images

### Build a Specific Version

```bash
# Using Make (recommended)
make build HELM_VERSION=v3.19.2

# Or using Docker directly
docker build --build-arg HELM_VERSION=v3.19.2 -t helm:v3.19.2 .

# Or using the build script
./build.sh v3.19.2
```

### Build Multiple Versions

```bash
# Build latest 5 releases
./build.sh --latest 5

# Build specific versions
./build.sh v3.19.2 v4.0.1

# Build all stable releases
./build.sh --all-stable
```

### Build for Multiple Architectures

```bash
# Build for AMD64 and ARM64
./build.sh --platforms linux/amd64,linux/arm64 v3.19.2

# Or using Make
make build-multi HELM_VERSION=v3.19.2
```

## Testing

### Run All Tests

```bash
# Build and test
make build test HELM_VERSION=v3.19.2

# Or use the test script
./test.sh v3.19.2
```

### Manual Testing

```bash
# Test version command
docker run --rm helm:v3.19.2 version

# Test with a sample chart
docker run --rm -v $(pwd):/apps helm:v3.19.2 create /apps/test-chart
docker run --rm -v $(pwd):/apps helm:v3.19.2 lint /apps/test-chart
```

## Common Usage Patterns

### 1. Lint Your Charts

```bash
docker run --rm -v $(pwd):/apps helm:v3.19.2 lint /apps/charts/my-app
```

### 2. Template Your Charts

```bash
docker run --rm -v $(pwd):/apps helm:v3.19.2 template my-app /apps/charts/my-app
```

### 3. Work with Kubernetes

```bash
# Mount your kubeconfig
docker run --rm \
  -v ~/.kube:/home/helm/.kube \
  helm:v3.19.2 list

# Deploy a chart
docker run --rm \
  -v ~/.kube:/home/helm/.kube \
  -v $(pwd):/apps \
  helm:v3.19.2 install my-app /apps/charts/my-app
```

### 4. Interactive Development

```bash
# Start an interactive shell
docker run --rm -it \
  -v ~/.kube:/home/helm/.kube \
  -v $(pwd):/apps \
  helm:v3.19.2 sh

# Or use Make
make shell HELM_VERSION=v3.19.2
```

### 5. Using Docker Compose

```bash
# Build images
docker-compose build

# Run Helm version
docker-compose run helm-v3 version

# Lint charts
docker-compose run lint-v3

# Interactive shell
docker-compose run shell
```

## CI/CD Integration

### GitHub Actions

Add to your `.github/workflows/ci.yml`:

```yaml
jobs:
  helm-lint:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/[your-username]/docker-helm:v3.19.2
    steps:
      - uses: actions/checkout@v4
      - run: helm lint ./charts/*
```

### GitLab CI

Add to your `.gitlab-ci.yml`:

```yaml
helm-lint:
  image: ghcr.io/[your-username]/docker-helm:v3.19.2
  script:
    - helm lint ./charts/*
```

### Jenkins

Add to your `Jenkinsfile`:

```groovy
pipeline {
    agent {
        docker {
            image 'ghcr.io/[your-username]/docker-helm:v3.19.2'
        }
    }
    stages {
        stage('Helm Lint') {
            steps {
                sh 'helm lint ./charts/*'
            }
        }
    }
}
```

## Publishing Images

### To Docker Hub

```bash
# Login
docker login

# Build and push
export DOCKER_REGISTRY=docker.io/your-username
./build.sh --push v3.19.2
```

### To GitHub Container Registry

```bash
# Login
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Build and push
export DOCKER_REGISTRY=ghcr.io/your-username
./build.sh --push v3.19.2
```

### Using GitHub Actions

The repository includes a GitHub Actions workflow that automatically:
1. Checks for new Helm releases daily
2. Builds images for new versions
3. Pushes to GitHub Container Registry

Just enable GitHub Actions in your repository settings!

## Troubleshooting

### Build Fails

```bash
# Check Docker is running
docker ps

# Check Buildx is available
docker buildx version

# Verify internet connection for downloading Helm
curl -I https://get.helm.sh/
```

### Permission Issues

```bash
# Run as your user
docker run --rm --user $(id -u):$(id -g) \
  -v $(pwd):/apps \
  helm:v3.19.2 lint /apps/charts/my-app
```

### Image Size Too Large

```bash
# Check image size
docker images helm:v3.19.2

# Clean up unused layers
docker system prune -a
```

## Next Steps

1. **Explore Examples**: Check out [EXAMPLES.md](EXAMPLES.md) for more advanced usage
2. **Version Support**: See [VERSIONS.md](VERSIONS.md) for supported Helm versions
3. **Contributing**: Read [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
4. **Automation**: Set up the GitHub Actions workflow for automated builds

## Help & Support

- **Documentation**: Check the [README.md](README.md)
- **Examples**: See [EXAMPLES.md](EXAMPLES.md)
- **Issues**: Open an issue on GitHub
- **Helm Docs**: Visit https://helm.sh/docs/

## Quick Reference

### Make Commands

```bash
make help              # Show all available commands
make build            # Build image
make test             # Test image
make push             # Build and push to registry
make build-latest     # Build latest 5 versions
make shell            # Start interactive shell
make clean            # Clean up images
make lint             # Lint Dockerfile and scripts
```

### Environment Variables

```bash
HELM_VERSION          # Helm version to build (default: v3.19.2)
DOCKER_REGISTRY       # Docker registry (default: docker.io)
IMAGE_NAME            # Image name (default: helm)
PLATFORMS             # Build platforms (default: linux/amd64,linux/arm64)
```

### Useful Aliases

Add these to your `.bashrc` or `.zshrc`:

```bash
# Quick Helm docker command
alias helm-docker='docker run --rm -v ~/.kube:/home/helm/.kube -v $(pwd):/apps helm:v3.19.2'

# Interactive Helm shell
alias helm-shell='docker run --rm -it -v ~/.kube:/home/helm/.kube -v $(pwd):/apps helm:v3.19.2 sh'

# Helm lint current directory
alias helm-lint='docker run --rm -v $(pwd):/apps helm:v3.19.2 lint /apps'
```

---

Happy Helming! 🚀
