#
# Cookbook:: ebl-server
# Recipe:: install
#
# Copyright:: 2024, AWS Practice Team
#
# Installs the EBL application

Chef::Log.info('Installing EBL application')

# Download EBL.exe from specified URL or S3 bucket
remote_file "#{Chef::Config[:file_cache_path]}\\#{node['ebl_server']['package_name']}" do
  source node['ebl_server']['download_url']
  checksum node['ebl_server']['checksum'] if node['ebl_server']['checksum']
  action :create
  notifies :run, 'powershell_script[install_ebl_application]', :immediately
end

# Install EBL application
powershell_script 'install_ebl_application' do
  code <<-EOH
  $installerPath = "#{Chef::Config[:file_cache_path]}\\#{node['ebl_server']['package_name']}"
  $installDir = "#{node['ebl_server']['install_dir']}"
  
  Write-Output "Installing EBL application from $installerPath to $installDir"
  
  # Check if installer exists
  if (-not (Test-Path $installerPath)) {
    throw "Installer not found at $installerPath"
  }
  
  # Create installation directory if it doesn't exist
  if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force
  }
  
  # Copy the EBL.exe to the installation directory
  Copy-Item $installerPath $installDir -Force
  
  # Make the application executable
  $appPath = Join-Path $installDir "#{node['ebl_server']['package_name']}"
  if (Test-Path $appPath) {
    Write-Output "EBL application installed successfully at $appPath"
  } else {
    throw "Failed to install EBL application"
  }
  EOH
  action :nothing
end

# Create EBL application configuration file
template "#{node['ebl_server']['install_dir']}\\config.xml" do
  source 'config.xml.erb'
  variables(
    app_name: node['ebl_server']['app_name'],
    data_dir: node['ebl_server']['data_dir'],
    log_dir: node['ebl_server']['log_dir'],
    service_user: node['ebl_server']['app_user']
  )
  action :create
end

# Create Windows service for EBL application
powershell_script 'create_ebl_service' do
  code <<-EOH
  $serviceName = "#{node['ebl_server']['service_name']}"
  $displayName = "#{node['ebl_server']['service_display_name']}"
  $exePath = "#{node['ebl_server']['install_dir']}\\#{node['ebl_server']['package_name']}"
  $serviceUser = "#{node['ebl_server']['app_user']}"
  
  # Check if service already exists
  $existingService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
  
  if ($existingService) {
    Write-Output "Service $serviceName already exists. Stopping and removing..."
    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $serviceName
    Start-Sleep -Seconds 2
  }
  
  # Create new service
  Write-Output "Creating service $serviceName"
  New-Service -Name $serviceName -DisplayName $displayName -BinaryPathName $exePath -StartupType Automatic
  
  # Configure service to run as specified user
  $service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"
  if ($service) {
    $result = $service.Change($null, $null, $null, $null, $null, $null, $serviceUser, $null)
    if ($result.ReturnValue -eq 0) {
      Write-Output "Service configured to run as $serviceUser"
    } else {
      Write-Warning "Failed to configure service user. Return value: $($result.ReturnValue)"
    }
  }
  EOH
  action :run
  not_if { ::Win32::Service.exists?(node['ebl_server']['service_name']) }
end

# Start EBL service
windows_service node['ebl_server']['service_name'] do
  action [:enable, :start]
  startup_type :automatic
end

Chef::Log.info('EBL application installed and service started successfully')