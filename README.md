# Helm Docker Images

Docker images for different versions of [Helm](https://helm.sh/) - The Kubernetes Package Manager. Built automatically for multiple architectures and versions to facilitate CI/CD testing and multi-version support.

## Features

- 🚀 **Multi-version support**: Images built for each Helm release
- 🏗️ **Multi-architecture**: Supports `linux/amd64` and `linux/arm64`
- 🔄 **Automated builds**: GitHub Actions workflow monitors Helm releases daily
- 🪶 **Lightweight**: Based on Alpine Linux for minimal image size
- 🔒 **Secure**: Non-root user, verified downloads with checksums
- 📦 **Pre-installed tools**: Includes git, bash, curl, and jq

## Available Tags

Images are tagged with their corresponding Helm versions:

- `v4.0.1`, `latest` - Latest stable Helm v4 release
- `v4.0.0` - Helm v4.0.0
- `v3.19.2` - Latest stable Helm v3 release
- `v3.19.1`, `v3.19.0`, etc. - Previous Helm v3 releases

See [Helm releases](https://github.com/helm/helm/releases) for all available versions.

## Quick Start

### Run Helm commands directly

```bash
# Check Helm version
docker run --rm ghcr.io/[your-username]/docker-helm:latest version

# List Helm repos
docker run --rm -v ~/.kube:/home/helm/.kube ghcr.io/[your-username]/docker-helm:latest repo list

# Helm help
docker run --rm ghcr.io/[your-username]/docker-helm:latest --help
```

### Use in CI/CD pipelines

#### GitHub Actions
```yaml
jobs:
  test-helm:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/[your-username]/docker-helm:v3.19.2
    steps:
      - name: Check Helm version
        run: helm version
      
      - name: Run Helm commands
        run: |
          helm repo add stable https://charts.helm.sh/stable
          helm search repo stable
```

#### GitLab CI
```yaml
test-helm:
  image: ghcr.io/[your-username]/docker-helm:v3.19.2
  script:
    - helm version
    - helm repo add stable https://charts.helm.sh/stable
```

#### Jenkins Pipeline
```groovy
pipeline {
    agent {
        docker {
            image 'ghcr.io/[your-username]/docker-helm:v3.19.2'
        }
    }
    stages {
        stage('Helm Test') {
            steps {
                sh 'helm version'
            }
        }
    }
}
```

### Use as base image

```dockerfile
FROM ghcr.io/[your-username]/docker-helm:v3.19.2

# Add your custom tools or configurations
COPY charts/ /charts/

# Run custom commands
RUN helm dependency update /charts/my-chart
```

## Building Images

### Prerequisites

- Docker with [Buildx](https://docs.docker.com/buildx/working-with-buildx/) support
- bash
- curl and jq (for the build script)

### Build specific version

```bash
# Build a specific version
docker build --build-arg HELM_VERSION=v3.19.2 -t helm:v3.19.2 .

# Or use the build script
./build.sh v3.19.2
```

### Build multiple versions

```bash
# Build specific versions
./build.sh v3.19.2 v4.0.1

# Build latest 5 releases
./build.sh --latest 5

# Build all stable releases
./build.sh --all-stable
```

### Build and push to registry

```bash
# Set your registry
export DOCKER_REGISTRY="ghcr.io/your-username"

# Build and push
./build.sh --push v3.19.2

# Build latest 10 releases and push
./build.sh --push --latest 10
```

### Build for specific platform

```bash
# Build for AMD64 only
./build.sh --platforms linux/amd64 v3.19.2

# Build for ARM64 only
./build.sh --platforms linux/arm64 v3.19.2

# Build for both (default)
./build.sh --platforms linux/amd64,linux/arm64 v3.19.2
```

## Build Script Options

```
Usage: ./build.sh [OPTIONS] [VERSION...]

OPTIONS:
    -h, --help              Show help message
    -p, --push              Push images to registry after building
    -l, --latest [N]        Build latest N releases (default: 10)
    -a, --all-stable        Build all stable releases
    --platforms PLATFORMS   Build for specific platforms (default: linux/amd64,linux/arm64)
    --registry REGISTRY     Docker registry to use (default: docker.io)
    --image-name NAME       Image name (default: helm)

EXAMPLES:
    ./build.sh v3.19.2
    ./build.sh v3.19.2 v4.0.1
    ./build.sh --latest 5
    ./build.sh --push v3.19.2
    ./build.sh --platforms linux/amd64 v3.19.2
    ./build.sh --registry ghcr.io/myorg --image-name helm v3.19.2
```

## Automated Builds

This project includes a GitHub Actions workflow that:

1. **Monitors Helm releases daily** - Runs at 2 AM UTC every day
2. **Builds new versions automatically** - Detects and builds newly released versions
3. **Multi-architecture support** - Builds for AMD64 and ARM64
4. **Pushes to GitHub Container Registry** - Automatically publishes images
5. **Manual triggers** - Allows on-demand builds via workflow dispatch

### Manual Workflow Trigger

You can manually trigger builds from the GitHub Actions tab:

1. Go to Actions → Build Helm Docker Images
2. Click "Run workflow"
3. Specify versions or number of latest releases to build
4. Choose whether to push to registry

## Testing Locally

```bash
# Build a test image
docker build --build-arg HELM_VERSION=v3.19.2 -t helm-test:v3.19.2 .

# Test the image
docker run --rm helm-test:v3.19.2 version

# Test with mounted kubeconfig
docker run --rm -v ~/.kube:/home/helm/.kube helm-test:v3.19.2 version

# Test template rendering with local chart
docker run --rm -v .:/charts -w /charts docker.io/haoli1/helm:v3.19.0 template test test-chart-1.0.0.tgz -f extra-values.yaml

# Interactive shell
docker run --rm -it helm-test:v3.19.2 sh
```

## Use Cases

### 1. CI/CD Testing
Test your Helm charts against multiple Helm versions:

```bash
for version in v3.15.0 v3.16.0 v3.17.0 v3.18.0 v3.19.0; do
  echo "Testing with Helm $version"
  docker run --rm -v $(pwd):/apps helm:$version lint /apps/my-chart
done
```

### 2. Version-specific Development
Work with specific Helm versions for compatibility testing:

```bash
docker run --rm -it \
  -v ~/.kube:/home/helm/.kube \
  -v $(pwd):/apps \
  helm:v3.19.2 sh
```

### 3. Kubernetes Cluster Management
```bash
# Add an alias for easy use
alias helm-docker='docker run --rm -v ~/.kube:/home/helm/.kube -v $(pwd):/apps ghcr.io/[your-username]/docker-helm:latest'

# Use like regular helm
helm-docker repo add bitnami https://charts.bitnami.com/bitnami
helm-docker search repo bitnami
```

## Image Contents

Each image includes:

- **Helm binary** - The specific version of Helm
- **Alpine Linux** - Minimal base image (~5MB)
- **Additional tools**:
  - `git` - For working with git-based charts
  - `bash` - Enhanced shell support
  - `curl` - HTTP client
  - `jq` - JSON processor
  - `ca-certificates` - SSL certificate verification

## Security

- Images run as non-root user (`helm:helm`)
- Downloads are verified with SHA256 checksums
- Based on official Alpine Linux images
- No unnecessary packages included
- Regular rebuilds to include security updates

## Contributing

Contributions are welcome! Here's how you can help:

1. **Report issues** - Found a bug? Open an issue
2. **Request versions** - Need a specific Helm version? Let us know
3. **Submit PRs** - Improvements to Dockerfile or scripts
4. **Add examples** - Share your use cases

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- [Helm](https://github.com/helm/helm) - The Kubernetes Package Manager
- [Helm Charts](https://artifacthub.io/) - Find and share Kubernetes packages

## Support

- **Issues**: [GitHub Issues](https://github.com/[your-username]/docker-helm/issues)
- **Helm Documentation**: https://helm.sh/docs/
- **Helm Community**: https://kubernetes.slack.com/ (#helm-users)

## Changelog

### Recent Updates
- Added support for Helm v4.x
- Multi-architecture builds (AMD64, ARM64)
- Automated daily builds
- GitHub Container Registry integration

---

**Note**: Replace `[your-username]` with your actual GitHub username when using these images.
