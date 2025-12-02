# Docker Helm Project - Complete Setup

✅ **Project successfully created!**

This project provides automated Docker image builds for different Helm versions, perfect for CI/CD testing and multi-version support.

## 📁 Project Structure

```
docker-helm/
├── .github/
│   └── workflows/
│       └── build.yml              # GitHub Actions workflow for automated builds
├── .gitignore                      # Git ignore patterns
├── Dockerfile                      # Multi-stage Dockerfile for Helm images
├── Makefile                        # Convenient make commands
├── README.md                       # Main documentation
├── GETTING_STARTED.md             # Quick start guide
├── EXAMPLES.md                     # Comprehensive usage examples
├── CONTRIBUTING.md                 # Contribution guidelines
├── VERSIONS.md                     # Supported Helm versions
├── LICENSE                         # MIT License
├── build.sh                        # Build script for multiple versions
├── quickstart.sh                   # Quick start testing script
├── test.sh                         # Integration test suite
└── docker-compose.yml             # Docker Compose configuration
```

## 🚀 Quick Start

### 1. Test Locally

```bash
# Quick test with default version (v3.19.2)
./quickstart.sh

# Or specify a version
./quickstart.sh v4.0.1
```

### 2. Build Specific Version

```bash
# Using Make
make build HELM_VERSION=v3.19.2

# Using build script
./build.sh v3.19.2

# Using Docker directly
docker build --build-arg HELM_VERSION=v3.19.2 -t helm:v3.19.2 .
```

### 3. Build Multiple Versions

```bash
# Latest 5 releases
./build.sh --latest 5

# Specific versions
./build.sh v3.19.2 v4.0.1

# All stable releases
./build.sh --all-stable
```

### 4. Test Your Build

```bash
# Run test suite
./test.sh v3.19.2

# Or use Make
make test HELM_VERSION=v3.19.2
```

## 🎯 Key Features

### Automated Builds
- **Daily checks** for new Helm releases (GitHub Actions runs at 2 AM UTC)
- **Multi-architecture** support (AMD64, ARM64)
- **Version matrix** testing across multiple Helm versions
- **Automated publishing** to container registry

### Docker Image
- **Lightweight**: Based on Alpine Linux (~50-80MB)
- **Secure**: Non-root user, verified checksums
- **Complete**: Includes git, bash, curl, jq
- **Multi-arch**: Supports AMD64 and ARM64

### Build Tools
- **build.sh**: Flexible build script with multiple options
- **Makefile**: Convenient make targets for common tasks
- **test.sh**: Comprehensive integration tests
- **quickstart.sh**: Quick testing and validation

## 📖 Documentation

| File | Description |
|------|-------------|
| [README.md](README.md) | Main project documentation and overview |
| [GETTING_STARTED.md](GETTING_STARTED.md) | Step-by-step quick start guide |
| [EXAMPLES.md](EXAMPLES.md) | Comprehensive usage examples and patterns |
| [VERSIONS.md](VERSIONS.md) | Supported Helm versions and update schedule |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute to the project |

## 🔧 Available Commands

### Make Commands

```bash
make help              # Show all available commands
make build            # Build Docker image
make build-multi      # Build multi-architecture image
make test             # Test the built image
make push             # Build and push to registry
make build-latest     # Build latest 5 versions
make build-all        # Build all stable versions
make quickstart       # Run quick start script
make clean            # Clean up local images
make shell            # Start interactive shell
make lint             # Lint Dockerfile and scripts
```

### Build Script Options

```bash
./build.sh [OPTIONS] [VERSION...]

Options:
  -h, --help              Show help
  -p, --push              Push to registry
  -l, --latest [N]        Build latest N releases
  -a, --all-stable        Build all stable releases
  --platforms             Specify platforms
  --registry              Set registry
  --image-name            Set image name
```

## 🔄 GitHub Actions Workflow

The included workflow automatically:

1. **Monitors** Helm releases daily
2. **Detects** new versions automatically
3. **Builds** multi-arch images (AMD64, ARM64)
4. **Tests** each image
5. **Publishes** to GitHub Container Registry
6. **Tags** latest version appropriately

### Manual Trigger

You can manually trigger builds:
1. Go to **Actions** tab
2. Select **Build Helm Docker Images**
3. Click **Run workflow**
4. Specify versions or count
5. Choose whether to push

## 📦 Usage Examples

### Basic Usage

```bash
# Check version
docker run --rm helm:v3.19.2 version

# Lint a chart
docker run --rm -v $(pwd):/apps helm:v3.19.2 lint /apps/charts/my-app

# Template a chart
docker run --rm -v $(pwd):/apps helm:v3.19.2 template my-app /apps/charts/my-app
```

### CI/CD Integration

#### GitHub Actions
```yaml
jobs:
  test:
    container:
      image: ghcr.io/[your-username]/docker-helm:v3.19.2
    steps:
      - run: helm lint ./charts/*
```

#### GitLab CI
```yaml
test:
  image: ghcr.io/[your-username]/docker-helm:v3.19.2
  script:
    - helm lint ./charts/*
```

#### Jenkins
```groovy
agent {
    docker {
        image 'ghcr.io/[your-username]/docker-helm:v3.19.2'
    }
}
```

### Development

```bash
# Create alias for convenience
alias helm-docker='docker run --rm -v ~/.kube:/home/helm/.kube -v $(pwd):/apps helm:v3.19.2'

# Use like normal helm
helm-docker version
helm-docker list
helm-docker install my-app ./charts/my-app
```

## 🎨 Customization

### Change Registry

```bash
export DOCKER_REGISTRY="ghcr.io/your-username"
./build.sh --push v3.19.2
```

### Custom Image Name

```bash
export IMAGE_NAME="my-helm"
./build.sh v3.19.2
```

### Specific Platforms

```bash
./build.sh --platforms linux/amd64 v3.19.2
```

## 🧪 Testing

### Run All Tests

```bash
# Build and test
make build test HELM_VERSION=v3.19.2

# Or use test script
./test.sh v3.19.2
```

### Test Across Versions

```bash
for version in v3.15.0 v3.16.0 v3.17.0 v3.18.0 v3.19.2; do
  echo "Testing with Helm $version"
  docker run --rm -v $(pwd):/apps helm:$version lint /apps/charts/my-app
done
```

## 📝 Next Steps

1. **Configure GitHub Actions**:
   - Enable Actions in repository settings
   - Set up GitHub Container Registry access
   - Workflow will run automatically daily

2. **Customize for Your Needs**:
   - Modify `Dockerfile` to add custom tools
   - Update `build.sh` with your registry details
   - Adjust workflow timing in `.github/workflows/build.yml`

3. **Set Up CI/CD**:
   - Add workflow files to your projects
   - Use the images in your pipelines
   - Test charts across multiple Helm versions

4. **Contribute**:
   - Report issues or request features
   - Submit improvements via pull requests
   - Share your use cases

## 🆘 Troubleshooting

### Build Issues
```bash
# Check Docker is running
docker ps

# Verify Buildx
docker buildx version

# Test internet connection
curl -I https://get.helm.sh/
```

### Permission Issues
```bash
# Run as current user
docker run --rm --user $(id -u):$(id -g) -v $(pwd):/apps helm:v3.19.2 lint /apps/charts
```

### Image Not Found
```bash
# Verify image exists
docker images helm:v3.19.2

# Rebuild if needed
make build HELM_VERSION=v3.19.2
```

## 📚 Resources

- **Helm Documentation**: https://helm.sh/docs/
- **Helm Releases**: https://github.com/helm/helm/releases
- **Docker Buildx**: https://docs.docker.com/buildx/
- **GitHub Actions**: https://docs.github.com/actions

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## ✅ What's Included

- ✅ Multi-version Helm Docker images
- ✅ Multi-architecture support (AMD64, ARM64)
- ✅ Automated build pipeline (GitHub Actions)
- ✅ Build scripts and tools
- ✅ Comprehensive documentation
- ✅ CI/CD integration examples
- ✅ Testing framework
- ✅ Docker Compose setup
- ✅ Make targets for convenience

**Your Helm Docker image project is ready to use! 🎉**

For questions or issues, please open a GitHub issue.
