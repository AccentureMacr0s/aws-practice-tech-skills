# Test Kitchen InSpec tests for EBL Server default configuration

describe service('EBLService') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe directory('C:\Program Files\EBL') do
  it { should exist }
end

describe directory('C:\ProgramData\EBL') do
  it { should exist }
end

describe directory('C:\ProgramData\EBL\logs') do
  it { should exist }
end

describe file('C:\Program Files\EBL\EBL.exe') do
  it { should exist }
end

describe file('C:\Program Files\EBL\config.xml') do
  it { should exist }
end

describe file('C:\ProgramData\EBL\app_settings.json') do
  it { should exist }
end

describe user('ebl_service') do
  it { should exist }
end

# Test Windows features
describe windows_feature('IIS-WebServerRole') do
  it { should be_installed }
end

describe windows_feature('IIS-WebServer') do
  it { should be_installed }
end

# Test scheduled tasks
describe powershell('Get-ScheduledTask -TaskName "EBL-HealthCheck"') do
  its('exit_status') { should eq 0 }
end

describe powershell('Get-ScheduledTask -TaskName "EBL-LogRotation"') do
  its('exit_status') { should eq 0 }
end

# Test event log source
describe powershell('[System.Diagnostics.EventLog]::SourceExists("EBL Application")') do
  its('stdout') { should match /True/ }
end

# Test PowerShell scripts
describe file('C:\Program Files\EBL\scripts\maintenance.ps1') do
  it { should exist }
end

describe file('C:\Program Files\EBL\scripts\health_check.ps1') do
  it { should exist }
end