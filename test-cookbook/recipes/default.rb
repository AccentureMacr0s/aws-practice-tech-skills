#
# Cookbook:: test-cookbook
# Recipe:: default
#
# Simple test recipe for Kitchen Docker testing

Chef::Log.info('Running test-cookbook default recipe')

# Create a test file
file '/tmp/kitchen-docker-test.txt' do
  content node['test_cookbook']['message'] || 'Kitchen Docker test successful!'
  mode '0644'
  action :create
end

# Install a basic package to test package management
package 'curl' do
  action :install
end

# Create a simple service test (using a basic script)
file '/tmp/test-service.sh' do
  content '#!/bin/bash
echo "Test service is running"
exit 0'
  mode '0755'
  action :create
end

Chef::Log.info('Test cookbook execution completed successfully')