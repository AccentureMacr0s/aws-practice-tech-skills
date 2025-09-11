#!/bin/bash

# Custom check script for AWS Practice Tech Skills

echo "Running custom checks..."

# Check Ruby files syntax (excluding .bundle directory)
echo "Checking Ruby files..."
find ./ruby -name "*.rb" -not -path "./ruby/.bundle/*" | while read -r file; do
    echo "Checking $file..."
    ruby -c "$file" || exit 1
done

# Check if Gemfile exists
if [ -f "./ruby/Gemfile" ]; then
    echo "✓ Ruby Gemfile found"
else
    echo "✗ Ruby Gemfile not found"
    exit 1
fi

# Check if basic_tasks.rb has the correct syntax
if grep -q "%w(Ruby Python Java)" ./ruby/algorithms/basic_tasks.rb; then
    echo "✓ basic_tasks.rb has correct %w() syntax"
else
    echo "✗ basic_tasks.rb syntax check failed"
    exit 1
fi

echo "All custom checks passed!"