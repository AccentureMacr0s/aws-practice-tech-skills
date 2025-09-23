#
# Cookbook:: ebl-server
# Recipe:: default
#
# Copyright:: 2024, AWS Practice Team, MIT Licensed.
#
# Main recipe for configuring EBL server on Windows Server 2022

# Include other recipes
include_recipe 'ebl-server::certificates'
include_recipe 'ebl-server::ebl_application'
include_recipe 'ebl-server::windows_admin_groups'

# Ensure Windows features are enabled
windows_feature 'IIS-WebServerRole' do
  action :install
  all true
end

windows_feature 'IIS-WebServer' do
  action :install
  all true
end

# Create application directory
directory node['ebl_server']['application_path'] do
  recursive true
  action :create
end

# Configure Windows Firewall rules for EBL application
powershell_script 'configure_ebl_firewall' do
  code <<-EOH
    New-NetFirewallRule -DisplayName "EBL Application" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
    New-NetFirewallRule -DisplayName "EBL Application HTTPS" -Direction Inbound -Protocol TCP -LocalPort 8443 -Action Allow
  EOH
  guard_interpreter :powershell_script
  not_if 'Get-NetFirewallRule -DisplayName "EBL Application" -ErrorAction SilentlyContinue'
end

# Log successful completion
log 'EBL Server configuration completed successfully' do
  level :info
end