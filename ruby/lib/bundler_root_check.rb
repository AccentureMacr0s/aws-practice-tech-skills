# frozen_string_literal: true

# BundlerRootCheck module provides utilities to enforce non-root bundler execution
# This is a security best practice to prevent potential system-wide modifications
module BundlerRootCheck
  class RootExecutionError < StandardError; end

  # Check if the current process is running as root
  # @return [Boolean] true if running as root, false otherwise
  def self.running_as_root?
    Process.uid.zero?
  end

  # Enforce that bundler is not running as root
  # @raise [RootExecutionError] if running as root
  # @return [void]
  # rubocop:disable Metrics/MethodLength
  def self.enforce!
    return unless running_as_root?

    raise RootExecutionError, <<~ERROR
      ⚠️  Running Bundler as root is not recommended!

      This is a security risk and can cause permission issues.

      Please run bundler commands as a non-root user.

      Recommended solutions:
      1. Run without sudo: bundle install
      2. Configure bundler to use a local path: bundle config set --local path 'vendor/bundle'
      3. Use a non-root user in Docker containers

      For more information, see: https://bundler.io/guides/bundler_setup.html
    ERROR
  end
  # rubocop:enable Metrics/MethodLength

  # Check if running as root and print a warning (non-fatal)
  # @return [void]
  def self.warn_if_root
    return unless running_as_root?

    warn <<~WARNING
      ⚠️  Warning: Running Bundler as root is not recommended!

      This may cause permission issues and is a security risk.
      Consider running as a non-root user.
    WARNING
  end
end
