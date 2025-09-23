# InSpec test for EBL Server default configuration
# Test suite to verify the EBL application is properly configured

describe 'EBL Server Configuration' do
  # Test application directory structure
  describe directory('C:\Program Files\EBL') do
    it { should exist }
  end

  describe directory('C:\Program Files\EBL\bin') do
    it { should exist }
  end

  describe directory('C:\Program Files\EBL\config') do
    it { should exist }
  end

  describe directory('C:\Program Files\EBL\logs') do
    it { should exist }
  end

  # Test application files
  describe file('C:\Program Files\EBL\bin\EBL.exe') do
    it { should exist }
  end

  describe file('C:\Program Files\EBL\config\app.config') do
    it { should exist }
    its('content') { should match(/EBLService/) }
    its('content') { should match(/EnableSSL.*true/) }
  end

  # Test Windows service
  describe service('EBLService') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  # Test user account
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

  # Test firewall rules
  describe powershell('Get-NetFirewallRule -DisplayName "EBL Application"') do
    its('exit_status') { should eq 0 }
  end

  describe powershell('Get-NetFirewallRule -DisplayName "EBL Application HTTPS"') do
    its('exit_status') { should eq 0 }
  end

  # Test local groups
  describe group('Bank Local Admins') do
    it { should exist }
  end

  describe group('EBL Operators') do
    it { should exist }
  end

  # Test event log source
  describe powershell('[System.Diagnostics.EventLog]::SourceExists("EBL.exe")') do
    its('stdout') { should match(/True/) }
  end

  # Test certificate directory
  describe directory('C:\certificates') do
    it { should exist }
  end

  # Test PowerShell execution policy
  describe powershell('Get-ExecutionPolicy -Scope LocalMachine') do
    its('stdout') { should match(/RemoteSigned/) }
  end

  # Test audit policy configuration
  describe powershell('auditpol /get /category:"Logon/Logoff"') do
    its('stdout') { should match(/Success and Failure/) }
  end

  # Test scheduled task for certificate renewal
  describe scheduled_task('certificate_renewal_check') do
    it { should exist }
    it { should be_enabled }
  end
end