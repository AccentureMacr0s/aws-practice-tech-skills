#
# Cookbook:: ebl-server
# Recipe:: EBL
#
# Copyright:: 2024, AWS Practice Team
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# EBL Application Core Management Recipe
# This recipe handles the core EBL application lifecycle and management operations

Chef::Log.info('Starting EBL application core management')

# Ensure EBL application is properly installed
ruby_block 'verify_ebl_installation' do
  block do
    ebl_path = "#{node['ebl_server']['install_dir']}\\#{node['ebl_server']['package_name']}"
    unless ::File.exist?(ebl_path)
      Chef::Log.fatal("EBL application not found at #{ebl_path}")
      raise "EBL application installation verification failed"
    end
    Chef::Log.info("EBL application verified at #{ebl_path}")
  end
  action :run
end

# Create EBL application startup script
template "#{node['ebl_server']['install_dir']}\\scripts\\start_ebl.ps1" do
  source 'start_ebl.ps1.erb'
  variables(
    app_name: node['ebl_server']['app_name'],
    install_dir: node['ebl_server']['install_dir'],
    package_name: node['ebl_server']['package_name'],
    service_name: node['ebl_server']['service_name'],
    data_dir: node['ebl_server']['data_dir'],
    log_dir: node['ebl_server']['log_dir']
  )
  action :create
  notifies :restart, "windows_service[#{node['ebl_server']['service_name']}]", :delayed
end

# Create EBL application shutdown script
template "#{node['ebl_server']['install_dir']}\\scripts\\stop_ebl.ps1" do
  source 'stop_ebl.ps1.erb'
  variables(
    app_name: node['ebl_server']['app_name'],
    service_name: node['ebl_server']['service_name'],
    install_dir: node['ebl_server']['install_dir']
  )
  action :create
end

# EBL Performance Monitor
powershell_script 'setup_ebl_performance_monitoring' do
  code <<-EOH
  $serviceName = "#{node['ebl_server']['service_name']}"
  $appName = "#{node['ebl_server']['app_name']}"
  $logDir = "#{node['ebl_server']['log_dir']}"
  
  Write-Output "Setting up performance monitoring for EBL application"
  
  # Create performance counters for EBL
  try {
    # Check if performance counter category exists
    $categoryName = "EBL Application"
    if ([System.Diagnostics.PerformanceCounterCategory]::Exists($categoryName)) {
      Write-Output "Performance counter category '$categoryName' already exists"
    } else {
      Write-Output "Creating performance counter category '$categoryName'"
      
      # Create custom performance counters for EBL
      $counters = New-Object System.Diagnostics.CounterCreationDataCollection
      
      $counter1 = New-Object System.Diagnostics.CounterCreationData
      $counter1.CounterName = "Active Connections"
      $counter1.CounterType = [System.Diagnostics.PerformanceCounterType]::NumberOfItems32
      $counter1.CounterHelp = "Number of active connections to EBL application"
      $counters.Add($counter1)
      
      $counter2 = New-Object System.Diagnostics.CounterCreationData
      $counter2.CounterName = "Requests Per Second"
      $counter2.CounterType = [System.Diagnostics.PerformanceCounterType]::RateOfCountsPerSecond32
      $counter2.CounterHelp = "Number of requests processed per second"
      $counters.Add($counter2)
      
      $counter3 = New-Object System.Diagnostics.CounterCreationData
      $counter3.CounterName = "Response Time"
      $counter3.CounterType = [System.Diagnostics.PerformanceCounterType]::NumberOfItems32
      $counter3.CounterHelp = "Average response time in milliseconds"
      $counters.Add($counter3)
      
      [System.Diagnostics.PerformanceCounterCategory]::Create($categoryName, "EBL Application Performance Counters", [System.Diagnostics.PerformanceCounterCategoryType]::SingleInstance, $counters)
      Write-Output "Performance counters created successfully"
    }
  } catch {
    Write-Warning "Failed to create performance counters: $($_.Exception.Message)"
  }
  
  # Create performance monitoring script
  $monitorScript = @"
`$serviceName = "$serviceName"
`$logPath = "$logDir\\performance.log"

while (`$true) {
  try {
    `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    `$service = Get-Service -Name `$serviceName -ErrorAction SilentlyContinue
    
    if (`$service -and `$service.Status -eq "Running") {
      # Get process information
      `$process = Get-Process | Where-Object { `$_.ProcessName -like "*EBL*" } | Select-Object -First 1
      
      if (`$process) {
        `$cpuUsage = `$process.CPU
        `$memoryUsage = [math]::Round(`$process.WorkingSet64 / 1MB, 2)
        `$handleCount = `$process.HandleCount
        
        `$logEntry = "`$timestamp - EBL Performance: CPU=`$cpuUsage, Memory=`$memoryUsage MB, Handles=`$handleCount"
        Add-Content -Path `$logPath -Value `$logEntry
      } else {
        `$logEntry = "`$timestamp - EBL Performance: Process not found"
        Add-Content -Path `$logPath -Value `$logEntry
      }
    } else {
      `$logEntry = "`$timestamp - EBL Performance: Service not running"
      Add-Content -Path `$logPath -Value `$logEntry
    }
  } catch {
    `$logEntry = "`$timestamp - EBL Performance Monitor Error: `$(`$_.Exception.Message)"
    Add-Content -Path `$logPath -Value `$logEntry
  }
  
  Start-Sleep -Seconds 60
}
"@
  
  $scriptPath = "$logDir\\ebl_performance_monitor.ps1"
  $monitorScript | Out-File -FilePath $scriptPath -Encoding UTF8
  
  Write-Output "Performance monitoring script created at $scriptPath"
  EOH
  action :run
end

# EBL Configuration Validator
ruby_block 'validate_ebl_configuration' do
  block do
    config_file = "#{node['ebl_server']['install_dir']}\\config.xml"
    app_settings_file = "#{node['ebl_server']['data_dir']}\\app_settings.json"
    
    # Validate XML configuration
    if ::File.exist?(config_file)
      Chef::Log.info("EBL XML configuration file found: #{config_file}")
      # Additional XML validation could be added here
    else
      Chef::Log.warn("EBL XML configuration file not found: #{config_file}")
    end
    
    # Validate JSON configuration
    if ::File.exist?(app_settings_file)
      Chef::Log.info("EBL JSON configuration file found: #{app_settings_file}")
      # Additional JSON validation could be added here
    else
      Chef::Log.warn("EBL JSON configuration file not found: #{app_settings_file}")
    end
  end
  action :run
end

# EBL Application Status Check
powershell_script 'ebl_status_check' do
  code <<-EOH
  $serviceName = "#{node['ebl_server']['service_name']}"
  $installDir = "#{node['ebl_server']['install_dir']}"
  $appName = "#{node['ebl_server']['app_name']}"
  
  Write-Output "Performing EBL application status check"
  
  # Check service status
  try {
    $service = Get-Service -Name $serviceName -ErrorAction Stop
    Write-Output "EBL Service Status: $($service.Status)"
    Write-Output "Service Start Type: $($service.StartType)"
    
    if ($service.Status -eq "Running") {
      # Check if the process is responsive
      $process = Get-Process | Where-Object { $_.ProcessName -like "*EBL*" } | Select-Object -First 1
      if ($process) {
        $processId = $process.Id
        $cpuUsage = $process.CPU
        $memoryUsage = [math]::Round($process.WorkingSet64 / 1MB, 2)
        
        Write-Output "EBL Process ID: $processId"
        Write-Output "EBL CPU Usage: $cpuUsage"
        Write-Output "EBL Memory Usage: $memoryUsage MB"
        
        # Test if the application is responsive (basic health check)
        try {
          $testConnection = Test-NetConnection -ComputerName "127.0.0.1" -Port 80 -WarningAction SilentlyContinue
          if ($testConnection.TcpTestSucceeded) {
            Write-Output "EBL Application: Responsive on port 80"
          } else {
            Write-Output "EBL Application: Not responsive on port 80"
          }
        } catch {
          Write-Output "EBL Application: Health check failed - $($_.Exception.Message)"
        }
      } else {
        Write-Warning "EBL process not found despite service running"
      }
    } else {
      Write-Warning "EBL service is not running"
    }
  } catch {
    Write-Error "Failed to check EBL service status: $($_.Exception.Message)"
  }
  
  # Check EBL application files integrity
  $eblExePath = "$installDir\\#{node['ebl_server']['package_name']}"
  if (Test-Path $eblExePath) {
    $fileInfo = Get-ItemProperty $eblExePath
    Write-Output "EBL Executable: Found - Size: $($fileInfo.Length) bytes, Modified: $($fileInfo.LastWriteTime)"
  } else {
    Write-Error "EBL executable not found at expected location: $eblExePath"
  }
  
  # Check configuration files
  $configPath = "$installDir\\config.xml"
  if (Test-Path $configPath) {
    Write-Output "EBL Configuration: Found at $configPath"
  } else {
    Write-Warning "EBL configuration file not found at $configPath"
  }
  
  Write-Output "EBL status check completed"
  EOH
  action :run
end

# Create EBL application restart script with dependencies check
template "#{node['ebl_server']['install_dir']}\\scripts\\restart_ebl.ps1" do
  source 'restart_ebl.ps1.erb'
  variables(
    service_name: node['ebl_server']['service_name'],
    app_name: node['ebl_server']['app_name'],
    install_dir: node['ebl_server']['install_dir'],
    data_dir: node['ebl_server']['data_dir']
  )
  action :create
end

# Ensure EBL service is running and properly configured
windows_service node['ebl_server']['service_name'] do
  action [:enable, :start]
  startup_type :automatic
  only_if { ::Win32::Service.exists?(node['ebl_server']['service_name']) }
end

Chef::Log.info('EBL application core management completed successfully')