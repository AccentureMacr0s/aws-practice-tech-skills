# Test Kitchen InSpec tests for EBL Server certificate management

# Test AWS CLI installation
describe powershell('aws --version') do
  its('exit_status') { should eq 0 }
end

# Test certificate store
describe powershell('
$certs = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.Subject -like "*ebl*" }
$certs.Count -gt 0
') do
  its('stdout') { should match /True/ }
end

# Test IIS SSL binding if IIS is installed
describe powershell('
$iisFeature = Get-WindowsFeature -Name IIS-WebServerRole
if ($iisFeature.InstallState -eq "Installed") {
  $binding = Get-WebBinding -Name "Default Web Site" -Protocol https
  $binding -ne $null
} else {
  $true  # Skip test if IIS not installed
}
') do
  its('stdout') { should match /True/ }
end

# Test certificate permissions
describe powershell('
$certs = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.Subject -like "*ebl*" }
if ($certs.Count -gt 0) {
  $cert = $certs[0]
  $cert.HasPrivateKey
} else {
  $false
}
') do
  its('stdout') { should match /True/ }
end