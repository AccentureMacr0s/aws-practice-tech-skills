#!/usr/bin/env ruby
# frozen_string_literal: true

# Example script demonstrating BundlerRootCheck usage

require_relative '../lib/bundler_root_check'

puts 'Bundler Root Check Example'
puts '=' * 50

# Check if running as root
puts "\n1. Checking if running as root..."
if BundlerRootCheck.running_as_root?
  puts "   ⚠️  Warning: You are running as root (UID=#{Process.uid})"
else
  puts "   ✓ Good: Running as non-root user (UID=#{Process.uid})"
end

# Demonstrate warn_if_root
puts "\n2. Using warn_if_root (non-fatal)..."
BundlerRootCheck.warn_if_root

# Demonstrate enforce! (commented out to avoid breaking the example)
puts "\n3. Using enforce! (fatal if root)..."
puts '   Note: This would raise an error if running as root'
puts '   Uncomment the line below to test:'
puts '   # BundlerRootCheck.enforce!'

begin
  # Uncomment to test enforcement:
  # BundlerRootCheck.enforce!
  puts '   ✓ Enforcement check passed'
rescue BundlerRootCheck::RootExecutionError => e
  puts '   ✗ Enforcement check failed:'
  puts e.message
  exit 1
end

puts "\n#{'=' * 50}"
puts 'Example completed successfully!'
