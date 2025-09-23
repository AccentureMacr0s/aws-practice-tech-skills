#!/bin/bash

# Kitchen Docker Test Script
# This script validates the Kitchen Docker setup

set -e

echo "=== Kitchen Docker Setup Validation ==="
echo

# Function to print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "OK" ]; then
        echo "✓ $message"
    elif [ "$status" = "WARN" ]; then
        echo "⚠ $message"
    else
        echo "✗ $message"
    fi
}

# Check if we're in the right directory
if [ ! -f "Gemfile" ] || [ ! -f ".kitchen.yml" ]; then
    print_status "ERROR" "Must be run from project root directory"
    exit 1
fi

print_status "OK" "Found project files"

# Check Docker
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        print_status "OK" "Docker is installed and running"
    else
        print_status "ERROR" "Docker is installed but not running"
        exit 1
    fi
else
    print_status "ERROR" "Docker is not installed"
    exit 1
fi

# Check Ruby
if command -v ruby &> /dev/null; then
    RUBY_VERSION=$(ruby --version | cut -d' ' -f2)
    print_status "OK" "Ruby $RUBY_VERSION is installed"
else
    print_status "ERROR" "Ruby is not installed"
    exit 1
fi

# Check Bundler
if command -v bundle &> /dev/null; then
    print_status "OK" "Bundler is available"
else
    print_status "ERROR" "Bundler is not installed"
    exit 1
fi

# Install dependencies
echo
echo "Installing Ruby dependencies..."
if bundle install --quiet; then
    print_status "OK" "Ruby dependencies installed successfully"
else
    print_status "ERROR" "Failed to install Ruby dependencies"
    exit 1
fi

# Check Kitchen
if bundle exec kitchen --version &> /dev/null; then
    KITCHEN_VERSION=$(bundle exec kitchen --version)
    print_status "OK" "Test Kitchen available: $KITCHEN_VERSION"
else
    print_status "ERROR" "Test Kitchen not available"
    exit 1
fi

# Validate Kitchen configuration
echo
echo "Validating Kitchen configuration..."
if bundle exec kitchen diagnose &> /dev/null; then
    print_status "OK" "Kitchen configuration is valid"
else
    print_status "ERROR" "Kitchen configuration has issues"
    exit 1
fi

# List Kitchen instances
echo
echo "Available Kitchen instances:"
bundle exec kitchen list

# Test Kitchen Docker functionality (dry run)
echo
echo "Testing Kitchen Docker driver..."
if bundle exec kitchen create default-ubuntu-2004 --log-level=error; then
    print_status "OK" "Kitchen Docker create successful"
    
    # Cleanup
    bundle exec kitchen destroy default-ubuntu-2004 --log-level=error
    print_status "OK" "Kitchen Docker cleanup successful"
else
    print_status "ERROR" "Kitchen Docker create failed"
    exit 1
fi

echo
echo "=== Kitchen Docker Setup Validation Complete ==="
echo "✓ All checks passed! Kitchen Docker is ready to use."
echo
echo "Usage:"
echo "  bundle exec kitchen list                    # List all instances"
echo "  bundle exec kitchen test default-ubuntu-2004  # Test specific instance"
echo "  bundle exec kitchen test                    # Test all instances"