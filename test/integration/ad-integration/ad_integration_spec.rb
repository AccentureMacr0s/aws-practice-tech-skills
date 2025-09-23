# InSpec test for EBL Server Active Directory integration
# Test suite to verify AD join and integration functionality

describe 'EBL Server AD Integration' do
  # Test domain membership
  describe powershell('(Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain') do
    its('stdout') { should match(/True/) }
  end

  describe powershell('(Get-WmiObject -Class Win32_ComputerSystem).Domain') do
    its('stdout') { should match(/bank\.local/) }
  end

  # Test domain controller connectivity
  describe powershell('Test-ComputerSecureChannel') do
    its('stdout') { should match(/True/) }
  end

  # Test domain admin group in local administrators
  describe group('Administrators') do
    it { should exist }
  end

  describe powershell('Get-LocalGroupMember -Group "Administrators" | Where-Object {$_.Name -like "*Bank Admins*"}') do
    its('exit_status') { should eq 0 }
  end

  # Test LDAP configuration
  describe file('C:\Program Files\EBL\config\ldap.config') do
    it { should exist }
    its('content') { should match(/ldaps:\/\/dc\.bank\.local:636/) }
    its('content') { should match(/Bank Admins/) }
  end

  # Test Kerberos configuration
  describe powershell('setspn -L $env:COMPUTERNAME') do
    its('stdout') { should match(/HTTP\//) }
  end

  # Test Group Policy application
  describe powershell('gpresult /r /scope:computer') do
    its('exit_status') { should eq 0 }
  end

  # Test WinRM configuration for domain
  describe powershell('Get-Item WSMan:\localhost\Client\TrustedHosts') do
    its('stdout') { should match(/bank\.local/) }
  end

  # Test PowerShell remoting
  describe powershell('Get-PSSessionConfiguration') do
    its('exit_status') { should eq 0 }
  end

  # Test certificate store for domain certificates
  describe powershell('Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Subject -like "*bank*"}') do
    its('exit_status') { should eq 0 }
  end

  # Test user rights assignment
  describe powershell('whoami /priv') do
    its('stdout') { should match(/SeServiceLogonRight/) }
  end

  # Test DNS resolution
  describe powershell('Resolve-DnsName dc.bank.local') do
    its('exit_status') { should eq 0 }
  end

  # Test Active Directory PowerShell module (if available)
  describe powershell('Get-Module -ListAvailable -Name ActiveDirectory') do
    its('exit_status') { should eq 0 }
  end

  # Test time synchronization with domain
  describe powershell('w32tm /query /status') do
    its('stdout') { should match(/Source:.*bank\.local/) }
  end

  # Test domain user authentication
  describe powershell('Get-ADDomain -Server bank.local') do
    its('exit_status') { should eq 0 }
  end
end