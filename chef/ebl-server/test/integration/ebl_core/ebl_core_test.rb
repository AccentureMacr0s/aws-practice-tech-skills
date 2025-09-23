# Test Kitchen InSpec tests for EBL Core recipe

# Test EBL startup script
describe file('C:\Program Files\EBL\scripts\start_ebl.ps1') do
  it { should exist }
end

# Test EBL shutdown script
describe file('C:\Program Files\EBL\scripts\stop_ebl.ps1') do
  it { should exist }
end

# Test EBL restart script
describe file('C:\Program Files\EBL\scripts\restart_ebl.ps1') do
  it { should exist }
end

# Test performance monitoring script
describe file('C:\ProgramData\EBL\logs\ebl_performance_monitor.ps1') do
  it { should exist }
end

# Test performance counter category
describe powershell('[System.Diagnostics.PerformanceCounterCategory]::Exists("EBL Application")') do
  its('stdout') { should match /True/ }
end

# Test EBL service is running
describe service('EBLService') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

# Test EBL application executable
describe file('C:\Program Files\EBL\EBL.exe') do
  it { should exist }
end

# Test EBL configuration validation
describe file('C:\Program Files\EBL\config.xml') do
  it { should exist }
end

describe file('C:\ProgramData\EBL\app_settings.json') do
  it { should exist }
end

# Test EBL performance logging
describe file('C:\ProgramData\EBL\logs\performance.log') do
  it { should exist }
end

# Test that EBL process is running
describe powershell('Get-Process | Where-Object { $_.ProcessName -like "*EBL*" }') do
  its('exit_status') { should eq 0 }
end

# Test EBL application responsiveness
describe port(80) do
  it { should be_listening }
end

# Test restart report functionality
describe powershell('Test-Path "C:\ProgramData\EBL\restart_report_*.json"') do
  its('stdout') { should match /True/ }
end