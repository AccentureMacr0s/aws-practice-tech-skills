# Bundler Best Practices

## Overview

This document outlines best practices for using Bundler in this project, with a focus on security and avoiding common pitfalls.

## Never Run Bundler as Root

**Important:** Running Bundler as root (with `sudo`) is strongly discouraged and can lead to:

1. **Security vulnerabilities** - System-wide gem installations with elevated privileges
2. **Permission issues** - Files owned by root that normal users cannot modify
3. **Inconsistent behavior** - Different behavior between development and production

### Why This Matters

When you run Bundler as root:
- Gems are installed system-wide with root ownership
- Files created during installation are owned by root
- Other users cannot update or modify these gems
- You may inadvertently override system Ruby packages

### Best Practices

#### 1. Use Local Bundle Path (Recommended)

Configure Bundler to install gems in a local directory within your project:

```bash
bundle config set --local path 'vendor/bundle'
bundle install
```

This approach:
- Keeps dependencies isolated per project
- Avoids permission issues
- Makes it easier to clean up dependencies
- Works consistently across environments

#### 2. Use User-Level Gem Installation

Install Bundler for your user only:

```bash
gem install bundler --user-install
```

Then add the user gem bin directory to your PATH:

```bash
export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
```

#### 3. Use Non-Root User in Docker

When using Docker, always create and use a non-root user:

```dockerfile
# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory and ownership
WORKDIR /app
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Now install gems
RUN bundle config set --local path 'vendor/bundle' && \
    bundle install
```

## Automated Enforcement

This project includes the `BundlerRootCheck` module to help enforce these best practices:

```ruby
require_relative 'lib/bundler_root_check'

# Enforce non-root execution (raises error if root)
BundlerRootCheck.enforce!

# Or just warn if running as root
BundlerRootCheck.warn_if_root
```

## Configuration

The project includes a `.bundle/config` file that configures Bundler to use `vendor/bundle` by default:

```yaml
---
BUNDLE_PATH: "vendor/bundle"
```

This ensures all team members use the same configuration.

## CI/CD Considerations

In CI/CD environments (GitHub Actions, etc.):
- Use the `ruby/setup-ruby` action with `bundler-cache: true`
- This handles caching and proper installation automatically
- Never use `sudo bundle install` in CI scripts

## Troubleshooting

### "You don't have write permissions" Error

If you see this error:
```
ERROR: While executing gem ... (Gem::FilePermissionError)
    You don't have write permissions for the /var/lib/gems/3.2.0 directory.
```

**Solution:** Configure local bundle path:
```bash
bundle config set --local path 'vendor/bundle'
bundle install
```

### Existing Root-Owned Gems

If you have gems installed as root that are causing issues:

1. Remove the system-wide gems (requires sudo):
   ```bash
   sudo rm -rf /var/lib/gems/3.2.0/*
   ```

2. Configure local bundle path:
   ```bash
   bundle config set --local path 'vendor/bundle'
   ```

3. Reinstall gems as non-root user:
   ```bash
   bundle install
   ```

## References

- [Bundler Documentation](https://bundler.io/)
- [Bundler Setup Guide](https://bundler.io/guides/bundler_setup.html)
- [Ruby Security Best Practices](https://www.ruby-lang.org/en/security/)
