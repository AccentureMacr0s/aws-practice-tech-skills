#
# Cookbook:: ebl-server
# Recipe:: configure
#
# Copyright:: 2024, AWS Practice Team
#
# Configures the EBL application after installation

Chef::Log.info('Configuring EBL application')

# Create scripts directory
directory "#{node['ebl_server']['install_dir']}\\scripts" do
  recursive true
  action :create
end

# Create application configuration files
template "#{node['ebl_server']['data_dir']}\\app_settings.json" do
  source 'app_settings.json.erb'
  variables(
    app_name: node['ebl_server']['app_name'],
    version: node['ebl_server']['version'],
    data_dir: node['ebl_server']['data_dir'],
    log_dir: node['ebl_server']['log_dir']
  )
  action :create
  notifies :restart, "windows_service[#{node['ebl_server']['service_name']}]", :delayed
end

# Create logging configuration
template "#{node['ebl_server']['data_dir']}\\logging.config" do
  source 'logging.config.erb'
  variables(
    log_dir: node['ebl_server']['log_dir'],
    app_name: node['ebl_server']['app_name']
  )
  action :create
  notifies :restart, "windows_service[#{node['ebl_server']['service_name']}]", :delayed
end

# Configure log rotation
powershell_script 'configure_log_rotation' do
  code <<-EOH
  $logDir = "#{node['ebl_server']['log_dir']}"
  $taskName = "EBL-LogRotation"
  
  # Create log rotation script
  $rotationScript = @"
`$logPath = "$logDir"
`$maxFiles = 10
`$maxSizeMB = 100

Get-ChildItem `$logPath -Filter "*.log" | Where-Object { 
  `$_.Length -gt (`$maxSizeMB * 1MB) 
} | ForEach-Object {
  `$newName = `$_.Name -replace "\.log$", "_`$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
  Rename-Item `$_.FullName `$newName
}

# Remove old log files
Get-ChildItem `$logPath -Filter "*.log" | Sort-Object CreationTime -Descending | Select-Object -Skip `$maxFiles | Remove-Item -Force
"@
  
  $scriptPath = "$logDir\\rotate_logs.ps1"
  $rotationScript | Out-File -FilePath $scriptPath -Encoding UTF8
  
  # Create scheduled task for log rotation
  $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$scriptPath`""
  $trigger = New-ScheduledTaskTrigger -Daily -At "02:00"
  $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
  
  # Remove existing task if it exists
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
  
  # Register new task
  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description "EBL Application Log Rotation"
  
  Write-Output "Log rotation configured successfully"
  EOH
  action :run
end

# Configure Windows Event Log source for EBL
powershell_script 'configure_event_log' do
  code <<-EOH
  $sourceName = "#{node['ebl_server']['app_name']}"
  $logName = "Application"
  
  try {
    # Check if event source already exists
    if (-not [System.Diagnostics.EventLog]::SourceExists($sourceName)) {
      [System.Diagnostics.EventLog]::CreateEventSource($sourceName, $logName)
      Write-Output "Event log source '$sourceName' created successfully"
    } else {
      Write-Output "Event log source '$sourceName' already exists"
    }
  } catch {
    Write-Warning "Failed to create event log source: $($_.Exception.Message)"
  }
  EOH
  action :run
end

# Create maintenance scripts
template "#{node['ebl_server']['install_dir']}\\scripts\\maintenance.ps1" do
  source 'maintenance.ps1.erb'
  variables(
    service_name: node['ebl_server']['service_name'],
    install_dir: node['ebl_server']['install_dir'],
    data_dir: node['ebl_server']['data_dir'],
    log_dir: node['ebl_server']['log_dir']
  )
  action :create
end

# Create health check script
template "#{node['ebl_server']['install_dir']}\\scripts\\health_check.ps1" do
  source 'health_check.ps1.erb'
  variables(
    service_name: node['ebl_server']['service_name'],
    app_name: node['ebl_server']['app_name']
  )
  action :create
end

# Set up health check scheduled task
powershell_script 'setup_health_check_task' do
  code <<-EOH
  $taskName = "EBL-HealthCheck"
  $scriptPath = "#{node['ebl_server']['install_dir']}\\scripts\\health_check.ps1"
  
  # Create scheduled task for health check
  $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$scriptPath`""
  $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
  $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
  
  # Remove existing task if it exists
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
  
  # Register new task
  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description "EBL Application Health Check"
  
  Write-Output "Health check task configured successfully"
  EOH
  action :run
end

Chef::Log.info('EBL application configuration completed')