#!/bin/bash
# Integration tests for Helm Docker images

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

HELM_VERSION="${1:-v3.19.2}"
IMAGE_NAME="helm-test:${HELM_VERSION}"

passed=0
failed=0
skipped=0

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((passed++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((failed++))
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    ((skipped++))
}

run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    log_test "$test_name"
    
    if eval "$test_cmd" > /dev/null 2>&1; then
        log_pass "$test_name"
        return 0
    else
        log_fail "$test_name"
        return 1
    fi
}

echo "🧪 Running Integration Tests for Helm ${HELM_VERSION}"
echo "======================================================"
echo ""

# Test 1: Image exists
log_test "Checking if image exists"
if docker image inspect "${IMAGE_NAME}" > /dev/null 2>&1; then
    log_pass "Image exists"
else
    log_fail "Image does not exist. Please build it first with: docker build --build-arg HELM_VERSION=${HELM_VERSION} -t ${IMAGE_NAME} ."
    exit 1
fi

# Test 2: Helm version command
run_test "Helm version command" \
    "docker run --rm ${IMAGE_NAME} version"

# Test 3: Helm help command
run_test "Helm help command" \
    "docker run --rm ${IMAGE_NAME} --help"

# Test 4: Check git is installed
run_test "Git is installed" \
    "docker run --rm ${IMAGE_NAME} sh -c 'which git'"

# Test 5: Check bash is installed
run_test "Bash is installed" \
    "docker run --rm ${IMAGE_NAME} sh -c 'which bash'"

# Test 6: Check curl is installed
run_test "Curl is installed" \
    "docker run --rm ${IMAGE_NAME} sh -c 'which curl'"

# Test 7: Check jq is installed
run_test "jq is installed" \
    "docker run --rm ${IMAGE_NAME} sh -c 'which jq'"

# Test 8: User is non-root
log_test "Container runs as non-root user"
user_id=$(docker run --rm ${IMAGE_NAME} sh -c 'id -u')
if [ "$user_id" != "0" ]; then
    log_pass "Container runs as non-root user (UID: $user_id)"
else
    log_fail "Container runs as root user"
fi

# Test 9: Helm create command
log_test "Helm create command (creates test chart)"
if docker run --rm -v /tmp:/tmp ${IMAGE_NAME} create /tmp/test-chart-$$ > /dev/null 2>&1; then
    log_pass "Helm create command works"
    rm -rf /tmp/test-chart-$$
else
    log_fail "Helm create command failed"
fi

# Test 10: Helm template command
log_test "Helm template command (with created chart)"
docker run --rm -v /tmp:/tmp ${IMAGE_NAME} create /tmp/test-chart-$$ > /dev/null 2>&1
if docker run --rm -v /tmp:/tmp ${IMAGE_NAME} template test /tmp/test-chart-$$ > /dev/null 2>&1; then
    log_pass "Helm template command works"
    rm -rf /tmp/test-chart-$$
else
    log_fail "Helm template command failed"
    rm -rf /tmp/test-chart-$$
fi

# Test 11: Helm lint command
log_test "Helm lint command"
docker run --rm -v /tmp:/tmp ${IMAGE_NAME} create /tmp/test-chart-$$ > /dev/null 2>&1
if docker run --rm -v /tmp:/tmp ${IMAGE_NAME} lint /tmp/test-chart-$$ > /dev/null 2>&1; then
    log_pass "Helm lint command works"
    rm -rf /tmp/test-chart-$$
else
    log_fail "Helm lint command failed"
    rm -rf /tmp/test-chart-$$
fi

# Test 12: Helm repo commands
run_test "Helm repo add command" \
    "docker run --rm ${IMAGE_NAME} repo add stable https://charts.helm.sh/stable"

run_test "Helm repo list command" \
    "docker run --rm ${IMAGE_NAME} repo list"

# Test 13: Image size check
log_test "Image size is reasonable"
size=$(docker image inspect ${IMAGE_NAME} --format='{{.Size}}' | awk '{print $1}')
size_mb=$((size / 1024 / 1024))
if [ "$size_mb" -lt 200 ]; then
    log_pass "Image size is reasonable (${size_mb}MB)"
else
    log_fail "Image size is too large (${size_mb}MB)"
fi

# Test 14: Multi-architecture support (if available)
log_test "Checking multi-architecture support"
if docker buildx inspect > /dev/null 2>&1; then
    log_pass "Docker Buildx is available for multi-arch builds"
else
    log_skip "Docker Buildx not available"
fi

echo ""
echo "======================================================"
echo "Test Results:"
echo "  ✅ Passed: $passed"
echo "  ❌ Failed: $failed"
echo "  ⏭️  Skipped: $skipped"
echo "======================================================"

if [ "$failed" -gt 0 ]; then
    echo ""
    echo "❌ Some tests failed!"
    exit 1
else
    echo ""
    echo "✅ All tests passed!"
    exit 0
fi
