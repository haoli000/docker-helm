# Helm Docker Images - Usage Examples

This document provides comprehensive examples of how to use the Helm Docker images in various scenarios.

## Table of Contents

- [Basic Usage](#basic-usage)
- [CI/CD Integration](#cicd-integration)
- [Multi-Version Testing](#multi-version-testing)
- [Development Workflows](#development-workflows)
- [Advanced Scenarios](#advanced-scenarios)

## Basic Usage

### Check Helm Version

```bash
docker run --rm ghcr.io/[your-username]/docker-helm:latest version
```

### Get Helm Help

```bash
docker run --rm ghcr.io/[your-username]/docker-helm:latest --help
```

### List Available Commands

```bash
docker run --rm ghcr.io/[your-username]/docker-helm:latest list
```

## CI/CD Integration

### GitHub Actions - Complete Example

```yaml
name: Deploy with Helm

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/[your-username]/docker-helm:v3.19.2
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Kubernetes context
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > ~/.kube/config
      
      - name: Add Helm repositories
        run: |
          helm repo add stable https://charts.helm.sh/stable
          helm repo add bitnami https://charts.bitnami.com/bitnami
          helm repo update
      
      - name: Lint Helm chart
        run: helm lint ./charts/my-app
      
      - name: Package Helm chart
        run: helm package ./charts/my-app
      
      - name: Deploy to Kubernetes
        run: |
          helm upgrade --install my-app ./charts/my-app \
            --namespace production \
            --create-namespace \
            --set image.tag=${{ github.sha }} \
            --wait
```

### GitLab CI - Multi-Stage Pipeline

```yaml
stages:
  - lint
  - test
  - deploy

variables:
  HELM_VERSION: "v3.19.2"

lint-chart:
  stage: lint
  image: ghcr.io/[your-username]/docker-helm:${HELM_VERSION}
  script:
    - helm lint ./charts/*
  only:
    - merge_requests
    - main

test-chart:
  stage: test
  image: ghcr.io/[your-username]/docker-helm:${HELM_VERSION}
  script:
    - helm template ./charts/my-app --debug
    - helm dependency build ./charts/my-app
  only:
    - merge_requests
    - main

deploy-production:
  stage: deploy
  image: ghcr.io/[your-username]/docker-helm:${HELM_VERSION}
  script:
    - echo "$KUBE_CONFIG" | base64 -d > ~/.kube/config
    - helm upgrade --install my-app ./charts/my-app
        --namespace production
        --create-namespace
        --set image.tag=$CI_COMMIT_SHA
        --wait
  only:
    - main
  environment:
    name: production
```

### Jenkins Pipeline - Declarative

```groovy
pipeline {
    agent none
    
    stages {
        stage('Helm Lint') {
            agent {
                docker {
                    image 'ghcr.io/[your-username]/docker-helm:v3.19.2'
                    args '-v $HOME/.kube:/home/helm/.kube'
                }
            }
            steps {
                sh 'helm lint ./charts/my-app'
            }
        }
        
        stage('Helm Template') {
            agent {
                docker {
                    image 'ghcr.io/[your-username]/docker-helm:v3.19.2'
                }
            }
            steps {
                sh 'helm template my-app ./charts/my-app --debug > template-output.yaml'
                archiveArtifacts artifacts: 'template-output.yaml'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            agent {
                docker {
                    image 'ghcr.io/[your-username]/docker-helm:v3.19.2'
                    args '-v $HOME/.kube:/home/helm/.kube'
                }
            }
            steps {
                sh '''
                    helm upgrade --install my-app ./charts/my-app \
                        --namespace production \
                        --create-namespace \
                        --wait
                '''
            }
        }
    }
}
```

### CircleCI Configuration

```yaml
version: 2.1

executors:
  helm-executor:
    docker:
      - image: ghcr.io/[your-username]/docker-helm:v3.19.2

jobs:
  lint:
    executor: helm-executor
    steps:
      - checkout
      - run:
          name: Lint Helm Charts
          command: helm lint ./charts/*
  
  deploy:
    executor: helm-executor
    steps:
      - checkout
      - run:
          name: Configure kubectl
          command: |
            echo $KUBE_CONFIG | base64 -d > ~/.kube/config
      - run:
          name: Deploy with Helm
          command: |
            helm upgrade --install my-app ./charts/my-app \
              --namespace production \
              --wait

workflows:
  version: 2
  build-and-deploy:
    jobs:
      - lint
      - deploy:
          requires:
            - lint
          filters:
            branches:
              only: main
```

## Multi-Version Testing

### Test Chart Compatibility Across Versions

```bash
#!/bin/bash

CHART_PATH="./charts/my-app"
VERSIONS=("v3.15.0" "v3.16.0" "v3.17.0" "v3.18.0" "v3.19.2" "v4.0.1")

echo "Testing chart compatibility across Helm versions..."

for version in "${VERSIONS[@]}"; do
    echo "=========================================="
    echo "Testing with Helm $version"
    echo "=========================================="
    
    # Lint
    echo "Running lint..."
    docker run --rm -v $(pwd):/apps \
        ghcr.io/[your-username]/docker-helm:$version \
        lint $CHART_PATH
    
    # Template
    echo "Running template..."
    docker run --rm -v $(pwd):/apps \
        ghcr.io/[your-username]/docker-helm:$version \
        template test-release $CHART_PATH > /dev/null
    
    if [ $? -eq 0 ]; then
        echo "✓ Helm $version: PASSED"
    else
        echo "✗ Helm $version: FAILED"
        exit 1
    fi
    
    echo ""
done

echo "All versions tested successfully!"
```

### GitHub Actions Matrix Strategy

```yaml
name: Test Chart Compatibility

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        helm-version:
          - v3.15.0
          - v3.16.0
          - v3.17.0
          - v3.18.0
          - v3.19.2
          - v4.0.1
    
    container:
      image: ghcr.io/[your-username]/docker-helm:${{ matrix.helm-version }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Helm Version
        run: helm version
      
      - name: Lint Chart
        run: helm lint ./charts/my-app
      
      - name: Template Chart
        run: helm template my-app ./charts/my-app
      
      - name: Dependency Build
        run: helm dependency build ./charts/my-app
```

## Development Workflows

### Local Chart Development

```bash
# Create an alias for convenience
alias helm-docker='docker run --rm -it \
  -v ~/.kube:/home/helm/.kube \
  -v $(pwd):/apps \
  -w /apps \
  ghcr.io/[your-username]/docker-helm:latest'

# Use it like regular helm
helm-docker create my-new-chart
helm-docker lint ./my-new-chart
helm-docker template test ./my-new-chart
helm-docker package ./my-new-chart
```

### Interactive Development Shell

```bash
docker run --rm -it \
  -v ~/.kube:/home/helm/.kube \
  -v $(pwd):/apps \
  -w /apps \
  ghcr.io/[your-username]/docker-helm:latest sh

# Now you're inside the container
helm version
helm lint ./charts/my-app
helm template my-app ./charts/my-app
```

### Chart Testing with Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  helm-lint:
    image: ghcr.io/[your-username]/docker-helm:v3.19.2
    volumes:
      - ./charts:/charts
    command: lint /charts/my-app
  
  helm-template:
    image: ghcr.io/[your-username]/docker-helm:v3.19.2
    volumes:
      - ./charts:/charts
    command: template test /charts/my-app
  
  helm-test-v4:
    image: ghcr.io/[your-username]/docker-helm:v4.0.1
    volumes:
      - ./charts:/charts
    command: lint /charts/my-app
```

Run with:

```bash
docker-compose up
```

## Advanced Scenarios

### Custom Helm Plugins Installation

```dockerfile
FROM ghcr.io/[your-username]/docker-helm:v3.19.2

USER root

# Install helm-diff plugin
RUN helm plugin install https://github.com/databus23/helm-diff

# Install helm-secrets plugin
RUN helm plugin install https://github.com/jkroepke/helm-secrets --version v4.5.1

USER helm

# Verify plugins
RUN helm plugin list
```

### Using with Kubernetes in Docker (kind)

```bash
# Create a kind cluster
docker run --rm -it \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  kindest/node:v1.27.0

# Use Helm with the cluster
docker run --rm -it \
  -v ~/.kube:/home/helm/.kube \
  -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:latest \
  install my-app ./charts/my-app
```

### Automated Chart Release Process

```bash
#!/bin/bash
set -e

CHART_DIR="./charts/my-app"
CHART_REPO="https://my-charts.example.com"
HELM_VERSION="v3.19.2"

# Update version
echo "Updating chart version..."
docker run --rm -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:$HELM_VERSION \
  sh -c "cd /apps && yq -i '.version = \"$NEW_VERSION\"' $CHART_DIR/Chart.yaml"

# Lint
echo "Linting chart..."
docker run --rm -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:$HELM_VERSION \
  lint /apps/$CHART_DIR

# Package
echo "Packaging chart..."
docker run --rm -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:$HELM_VERSION \
  package /apps/$CHART_DIR -d /apps/releases

# Generate index
echo "Generating repository index..."
docker run --rm -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:$HELM_VERSION \
  repo index /apps/releases --url $CHART_REPO

echo "Chart release complete!"
```

### Helm Diff Before Deploy

```bash
#!/bin/bash

RELEASE_NAME="my-app"
CHART_PATH="./charts/my-app"
NAMESPACE="production"

# Show what would change
docker run --rm \
  -v ~/.kube:/home/helm/.kube \
  -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:v3.19.2 \
  diff upgrade $RELEASE_NAME /apps/$CHART_PATH \
  --namespace $NAMESPACE \
  --install

# Ask for confirmation
read -p "Proceed with deployment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker run --rm \
      -v ~/.kube:/home/helm/.kube \
      -v $(pwd):/apps \
      ghcr.io/[your-username]/docker-helm:v3.19.2 \
      upgrade --install $RELEASE_NAME /apps/$CHART_PATH \
      --namespace $NAMESPACE \
      --wait
fi
```

### Parallel Chart Testing

```bash
#!/bin/bash

# Test multiple charts in parallel
charts=("app1" "app2" "app3" "app4")

for chart in "${charts[@]}"; do
  (
    echo "Testing $chart..."
    docker run --rm -v $(pwd):/apps \
      ghcr.io/[your-username]/docker-helm:latest \
      lint /apps/charts/$chart
    echo "$chart test complete"
  ) &
done

wait
echo "All chart tests complete!"
```

### Chart Dependency Management

```bash
# Update all dependencies
docker run --rm -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:latest \
  dependency update /apps/charts/my-app

# Build dependencies
docker run --rm -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:latest \
  dependency build /apps/charts/my-app

# List dependencies
docker run --rm -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:latest \
  dependency list /apps/charts/my-app
```

## Tips and Best Practices

1. **Volume Mounts**: Always mount your kubeconfig and chart directories appropriately
2. **Working Directory**: Use `-w` flag to set working directory inside container
3. **User Permissions**: The container runs as non-root user `helm` (UID 1000)
4. **Version Pinning**: Use specific version tags in production CI/CD
5. **Multi-Architecture**: The images support both AMD64 and ARM64 architectures
6. **Caching**: Use Docker layer caching in CI/CD for faster builds

## Troubleshooting

### Permission Issues

```bash
# If you encounter permission issues with mounted volumes
docker run --rm --user $(id -u):$(id -g) \
  -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:latest \
  lint /apps/charts/my-app
```

### Debug Mode

```bash
# Run with debug output
docker run --rm -v $(pwd):/apps \
  ghcr.io/[your-username]/docker-helm:latest \
  template my-app /apps/charts/my-app --debug
```

### Access Shell for Debugging

```bash
docker run --rm -it \
  -v $(pwd):/apps \
  --entrypoint sh \
  ghcr.io/[your-username]/docker-helm:latest
```

---

For more information, see the [main README](README.md) or [Helm documentation](https://helm.sh/docs/).
