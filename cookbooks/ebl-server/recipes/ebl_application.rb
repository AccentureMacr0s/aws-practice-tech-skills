#
# Cookbook:: ebl-server
# Recipe:: ebl_application
#
# Copyright:: 2024, AWS Practice Team, MIT Licensed.
#
# Recipe for installing and configuring EBL.exe application

# Create application user
user 'ebl_service' do
  password 'ComplexP@ssw0rd123!'
  action :create
end

# Create EBL application directory structure
directory node['ebl_server']['application_path'] do
  recursive true
  action :create
end

directory "#{node['ebl_server']['application_path']}\\bin" do
  recursive true
  action :create
end

directory "#{node['ebl_server']['application_path']}\\config" do
  recursive true
  action :create
end

directory "#{node['ebl_server']['application_path']}\\logs" do
  recursive true
  action :create
end

# Deploy EBL.exe application (assuming it's in cookbook files)
cookbook_file "#{node['ebl_server']['application_path']}\\bin\\EBL.exe" do
  source 'EBL.exe'
  action :create
  notifies :restart, 'windows_service[ebl_service]', :delayed
end

# Deploy application configuration file
template "#{node['ebl_server']['application_path']}\\config\\app.config" do
  source 'app.config.erb'
  variables(
    application_path: node['ebl_server']['application_path'],
    ad_domain: node['ebl_server']['ad_domain']
  )
  action :create
  notifies :restart, 'windows_service[ebl_service]', :delayed
end

# Create Windows service for EBL application
powershell_script 'create_ebl_service' do
  code <<-EOH
    $serviceName = "#{node['ebl_server']['service_name']}"
    $exePath = "#{node['ebl_server']['application_path']}\\bin\\EBL.exe"
    $serviceUser = "ebl_service"
    
    # Check if service exists
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    
    if ($null -eq $service) {
        # Create the service
        New-Service -Name $serviceName -BinaryPathName $exePath -DisplayName "EBL Banking Application" -Description "Enterprise Banking Layer application service" -StartupType Automatic
        
        # Set service to run as specific user
        $secpasswd = ConvertTo-SecureString "ComplexP@ssw0rd123!" -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential ("ebl_service", $secpasswd)
        
        # Configure service logon
        $service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"
        $service.Change($null, $null, $null, $null, $null, $null, "ebl_service", "ComplexP@ssw0rd123!")
        
        Write-Output "EBL service created successfully"
    } else {
        Write-Output "EBL service already exists"
    }
  EOH
  guard_interpreter :powershell_script
  not_if "Get-Service -Name '#{node['ebl_server']['service_name']}' -ErrorAction SilentlyContinue"
end

# Manage the Windows service
windows_service node['ebl_server']['service_name'] do
  action [:enable, :start]
  startup_type :automatic
end

# Set up application logging
directory 'C:\Windows\System32\winevt\Logs\EBL' do
  recursive true
  action :create
end

powershell_script 'configure_ebl_logging' do
  code <<-EOH
    # Create custom event log for EBL application
    New-EventLog -LogName "EBL Application" -Source "EBL.exe" -ErrorAction SilentlyContinue
    Write-Output "EBL application logging configured"
  EOH
  guard_interpreter :powershell_script
  not_if '[System.Diagnostics.EventLog]::SourceExists("EBL.exe")'
end