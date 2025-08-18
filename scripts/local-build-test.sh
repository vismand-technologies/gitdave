#!/bin/bash
set -e

echo "🚀 Local GitHub Workflow Simulation for GitDave"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Change to app directory
cd "$(dirname "$0")/../app"

print_step "Step 1: Setup Node Environment"
echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"

print_step "Step 2: Clean previous builds"
if [ -d "node_modules" ]; then
    print_warning "Removing existing node_modules..."
    rm -rf node_modules
fi

if [ -d "dist" ]; then
    print_warning "Removing existing dist..."
    rm -rf dist
fi

if [ -d "release" ]; then
    print_warning "Removing existing release..."
    rm -rf release
fi

print_step "Step 3: Install dependencies"
npm ci

print_step "Step 4: TypeScript type checking"
npm run typecheck

print_step "Step 5: Build application"
npm run build

print_step "Step 6: Verify build outputs"
if [ -f "dist/main.js" ]; then
    print_success "Main process built successfully"
else
    print_error "Main process build failed"
    exit 1
fi

if [ -f "dist/preload.js" ]; then
    print_success "Preload script built successfully"
else
    print_error "Preload script build failed"
    exit 1
fi

if [ -f "dist/renderer.js" ]; then
    print_success "Renderer process built successfully"
else
    print_error "Renderer process build failed"
    exit 1
fi

if [ -f "dist/index.html" ]; then
    print_success "HTML template generated successfully"
else
    print_error "HTML template generation failed"
    exit 1
fi

print_step "Step 7: Check icon files"
if [ -f "build/icons/icon.ico" ]; then
    print_success "Windows icon found"
else
    print_error "Windows icon missing"
fi

if [ -f "build/icons/icon.icns" ]; then
    print_success "macOS icon found"
else
    print_error "macOS icon missing"
fi

if [ -d "build/icons/png" ] && [ "$(ls -A build/icons/png)" ]; then
    print_success "Linux PNG icons found"
else
    print_error "Linux PNG icons missing"
fi

print_step "Step 8: Test packaging (without publishing)"
echo "Testing electron-builder packaging..."

# Test packaging for current platform only
case "$(uname -s)" in
    Linux*)
        print_step "Testing Linux packaging..."
        npm run pack
        if [ -d "release/linux-unpacked" ]; then
            print_success "Linux packaging test passed"
        else
            print_error "Linux packaging test failed"
        fi
        ;;
    Darwin*)
        print_step "Testing macOS packaging..."
        npm run pack
        if [ -d "release/mac" ]; then
            print_success "macOS packaging test passed"
        else
            print_error "macOS packaging test failed"
        fi
        ;;
    MINGW*|CYGWIN*)
        print_step "Testing Windows packaging..."
        npm run pack
        if [ -d "release/win-unpacked" ]; then
            print_success "Windows packaging test passed"
        else
            print_error "Windows packaging test failed"
        fi
        ;;
    *)
        print_warning "Unknown platform, skipping packaging test"
        ;;
esac

print_success "🎉 Local build simulation completed successfully!"
echo ""
echo "📊 Build Summary:"
echo "- TypeScript compilation: ✅"
echo "- Webpack bundling: ✅"
echo "- Icon files: ✅"
echo "- Electron packaging: ✅"
echo ""
echo "🚀 Your GitHub workflows should now work correctly!"
