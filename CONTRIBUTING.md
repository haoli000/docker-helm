# Contributing to Helm Docker Images

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in [GitHub Issues](https://github.com/[your-username]/docker-helm/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Version information (Helm version, Docker version, OS)

### Requesting Helm Versions

If you need a specific Helm version that's not available:

1. Open an issue with the title "Request: Helm version X.X.X"
2. Explain why this version is needed
3. We'll build and publish it ASAP

### Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Test your changes locally
5. Commit with clear messages
6. Push to your fork
7. Open a Pull Request

### Code Style

- Use shellcheck for bash scripts
- Keep Dockerfile instructions clear and commented
- Follow existing code formatting
- Add comments for complex logic

### Testing

Before submitting a PR, test:

```bash
# Build the image
docker build --build-arg HELM_VERSION=v3.19.2 -t helm-test:v3.19.2 .

# Test the image
docker run --rm helm-test:v3.19.2 version
docker run --rm helm-test:v3.19.2 --help

# Run shellcheck on scripts
shellcheck build.sh
```

## Development Setup

```bash
# Clone your fork
git clone https://github.com/[your-username]/docker-helm.git
cd docker-helm

# Make build script executable
chmod +x build.sh

# Build a test image
./build.sh v3.19.2

# Test the build
docker run --rm helm:v3.19.2 version
```

## Pull Request Guidelines

- Keep PRs focused on a single feature or fix
- Update documentation if needed
- Add/update examples if applicable
- Ensure all tests pass
- Link related issues

## Questions?

Feel free to open an issue for any questions or discussions.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
