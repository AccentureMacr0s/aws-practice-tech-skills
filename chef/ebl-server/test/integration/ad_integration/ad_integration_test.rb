# Test Kitchen InSpec tests for EBL Server Active Directory integration

# Test domain membership
describe powershell('(Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain') do
  its('stdout') { should match /True/ }
end

# Test domain groups in local administrators
describe powershell('
$adminGroup = [ADSI]"WinNT://./Administrators,group"
$members = @($adminGroup.psbase.Invoke("Members")) | ForEach-Object { 
  $_.GetType().InvokeMember("Name", "GetProperty", $null, $_, $null) 
}
$members -contains "Domain Admins"
') do
  its('stdout') { should match /True/ }
end

describe powershell('
$adminGroup = [ADSI]"WinNT://./Administrators,group"
$members = @($adminGroup.psbase.Invoke("Members")) | ForEach-Object { 
  $_.GetType().InvokeMember("Name", "GetProperty", $null, $_, $null) 
}
$members -contains "EBL Administrators"
') do
  its('stdout') { should match /True/ }
end

# Test domain connectivity
describe powershell('Test-ComputerSecureChannel') do
  its('stdout') { should match /True/ }
end

# Test AD management script
describe file('C:\Program Files\EBL\scripts\ad_management.ps1') do
  it { should exist }
end

# Test service account configuration
describe powershell('
$service = Get-WmiObject -Class Win32_Service -Filter "Name=\'EBLService\'"
$service.StartName -like "*\\*"
') do
  its('stdout') { should match /True/ }
end