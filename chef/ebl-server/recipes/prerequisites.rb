#
# Cookbook:: ebl-server
# Recipe:: prerequisites
#
# Copyright:: 2024, AWS Practice Team
#
# Sets up prerequisites for EBL server installation

Chef::Log.info('Installing EBL server prerequisites')

# Install required Windows features
node['ebl_server']['windows_features'].each do |feature|
  windows_feature feature do
    action :install
    install_method :windows_feature_powershell
  end
end

# Create application directories
[
  node['ebl_server']['install_dir'],
  node['ebl_server']['data_dir'],
  node['ebl_server']['log_dir']
].each do |dir|
  directory dir do
    recursive true
    action :create
  end
end

# Create application service user
user node['ebl_server']['app_user'] do
  password node['ebl_server']['app_user_password'] if node['ebl_server']['app_user_password']
  action :create
  comment 'EBL Application Service User'
  home "C:\\Users\\#{node['ebl_server']['app_user']}"
end

# Grant necessary privileges to service user
windows_user_privilege 'Logon as a service' do
  users [node['ebl_server']['app_user']]
  action :add
end

windows_user_privilege 'Act as part of the operating system' do
  users [node['ebl_server']['app_user']]
  action :add
end

# Set permissions on application directories
[
  node['ebl_server']['install_dir'],
  node['ebl_server']['data_dir'],
  node['ebl_server']['log_dir']
].each do |dir|
  powershell_script "Set permissions on #{dir}" do
    code <<-EOH
    $path = "#{dir}"
    $user = "#{node['ebl_server']['app_user']}"
    
    # Set full control for the service user
    $acl = Get-Acl $path
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl $path $acl
    
    Write-Output "Permissions set for $user on $path"
    EOH
    action :run
  end
end

Chef::Log.info('EBL server prerequisites installed successfully')