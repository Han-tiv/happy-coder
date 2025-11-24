#!/usr/bin/env bash
#
# AI CLI Compatibility Checker
# Verifies that Gemini CLI and Codex CLI are properly installed and compatible
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
ALL_CHECKS_PASSED=true

echo "🔍 Happy AI CLI Compatibility Checker"
echo "======================================"
echo ""

# Function to print status
print_status() {
    local status=$1
    local message=$2

    if [ "$status" = "OK" ]; then
        echo -e "${GREEN}✓${NC} $message"
    elif [ "$status" = "WARN" ]; then
        echo -e "${YELLOW}⚠${NC} $message"
    else
        echo -e "${RED}✗${NC} $message"
        ALL_CHECKS_PASSED=false
    fi
}

# Check Node.js version
echo "1. Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    NODE_MAJOR=$(node --version | cut -d'.' -f1 | sed 's/v//')

    if [ "$NODE_MAJOR" -ge 20 ]; then
        print_status "OK" "Node.js $NODE_VERSION (>= 20 required)"
    else
        print_status "ERROR" "Node.js $NODE_VERSION is too old (>= 20 required)"
    fi
else
    print_status "ERROR" "Node.js not found"
fi
echo ""

# Check npm
echo "2. Checking npm..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_status "OK" "npm $NPM_VERSION"
else
    print_status "ERROR" "npm not found"
fi
echo ""

# Check Gemini CLI
echo "3. Checking Gemini CLI..."
if command -v gemini &> /dev/null; then
    GEMINI_VERSION=$(gemini --version 2>&1 | head -n1 || echo "unknown")
    print_status "OK" "Gemini CLI installed: $GEMINI_VERSION"

    # Check if gemini accepts --allowed-tools flag
    if gemini --help 2>&1 | grep -q "allowed-tools"; then
        print_status "OK" "Gemini CLI supports --allowed-tools flag"
    else
        print_status "WARN" "Gemini CLI may not support --allowed-tools flag (check version)"
    fi
else
    print_status "WARN" "Gemini CLI not installed (optional)"
    echo "         Install: npm install -g @google/gemini-cli"
fi
echo ""

# Check Codex CLI
echo "4. Checking Codex CLI..."
if command -v codex &> /dev/null; then
    CODEX_VERSION=$(codex --version 2>&1 | head -n1 || echo "unknown")
    print_status "OK" "Codex CLI installed: $CODEX_VERSION"
else
    print_status "WARN" "Codex CLI not installed (optional)"
    echo "         See: https://codex.dev for installation"
fi
echo ""

# Check happy-cli
echo "5. Checking happy-cli..."
if [ -f "./happy-cli/bin/happy.mjs" ]; then
    print_status "OK" "happy-cli found in local submodule"

    # Check if happy gemini command exists
    if grep -q "gemini" ./happy-cli/bin/happy.mjs; then
        print_status "OK" "happy gemini command available"
    else
        print_status "ERROR" "happy gemini command not found in happy-cli"
    fi

    # Check if happy codex command exists
    if grep -q "codex" ./happy-cli/bin/happy.mjs; then
        print_status "OK" "happy codex command available"
    else
        print_status "WARN" "happy codex command not found in happy-cli"
    fi
else
    print_status "ERROR" "happy-cli not found (check git submodules)"
fi
echo ""

# Check MCP server integration
echo "6. Checking Happy MCP Server..."
if [ -f "./happy-cli/src/claude/utils/startHappyServer.ts" ]; then
    print_status "OK" "Happy MCP Server implementation found"

    # Count tools registered
    TOOL_COUNT=$(grep -c "registerTool" ./happy-cli/src/claude/utils/startHappyServer.ts || echo "0")
    print_status "OK" "MCP tools registered: $TOOL_COUNT"
else
    print_status "ERROR" "Happy MCP Server not found"
fi
echo ""

# Check environment variables
echo "7. Checking environment configuration..."
if [ -n "${GEMINI_API_KEY:-}" ]; then
    print_status "OK" "GEMINI_API_KEY is set"
elif [ -n "${GOOGLE_API_KEY:-}" ]; then
    print_status "OK" "GOOGLE_API_KEY is set"
else
    print_status "WARN" "No Gemini API key found (required for Gemini CLI)"
    echo "         Set GEMINI_API_KEY or GOOGLE_API_KEY, or use OAuth login"
fi

if [ -n "${HAPPY_SERVER_URL:-}" ]; then
    print_status "OK" "HAPPY_SERVER_URL is set: $HAPPY_SERVER_URL"
else
    print_status "WARN" "HAPPY_SERVER_URL not set (using default)"
fi
echo ""

# Check Happy Server connectivity
echo "8. Checking Happy Server..."
HAPPY_URL="${HAPPY_SERVER_URL:-http://localhost:3005}"
if curl -s -f -m 5 "$HAPPY_URL/health" > /dev/null 2>&1; then
    print_status "OK" "Happy Server is reachable at $HAPPY_URL"
else
    print_status "WARN" "Happy Server not reachable at $HAPPY_URL"
    echo "         Start with: ./happy-demo.sh start"
fi
echo ""

# Summary
echo "======================================"
if [ "$ALL_CHECKS_PASSED" = true ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some critical checks failed${NC}"
    echo "Please fix the errors above before using Happy AI CLI integration"
    exit 1
fi
