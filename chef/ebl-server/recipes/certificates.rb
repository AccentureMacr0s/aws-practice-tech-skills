#
# Cookbook:: ebl-server
# Recipe:: certificates
#
# Copyright:: 2024, AWS Practice Team
#
# Manages SSL certificates using AWS Secrets Manager

Chef::Log.info('Configuring SSL certificates from AWS Secrets Manager')

# Install AWS CLI if not present
powershell_script 'install_aws_cli' do
  code <<-EOH
  # Check if AWS CLI is installed
  try {
    $awsVersion = aws --version
    Write-Output "AWS CLI already installed: $awsVersion"
  } catch {
    Write-Output "Installing AWS CLI..."
    
    # Download AWS CLI installer
    $installerUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
    $installerPath = "$env:TEMP\\AWSCLIV2.msi"
    
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
    
    # Install AWS CLI
    Start-Process msiexec.exe -ArgumentList "/i", $installerPath, "/quiet" -Wait
    
    # Add to PATH if not already there
    $env:PATH += ";C:\\Program Files\\Amazon\\AWSCLIV2"
    
    Write-Output "AWS CLI installed successfully"
  }
  EOH
  action :run
  not_if 'where aws'
end

# Retrieve SSL certificate from AWS Secrets Manager
powershell_script 'retrieve_ssl_certificate' do
  code <<-EOH
  $secretName = "#{node['ebl_server']['certificates']['ssl_cert_secret']}"
  $region = "#{node['ebl_server']['certificates']['aws_region']}"
  $certStore = "#{node['ebl_server']['certificates']['cert_store']}"
  $certLocation = "#{node['ebl_server']['certificates']['cert_store_location']}"
  
  Write-Output "Retrieving certificate from AWS Secrets Manager: $secretName"
  
  try {
    # Get secret value from AWS Secrets Manager
    $secretJson = aws secretsmanager get-secret-value --secret-id $secretName --region $region --output json | ConvertFrom-Json
    $secretValue = $secretJson.SecretString | ConvertFrom-Json
    
    # Extract certificate and private key
    $certificate = $secretValue.certificate
    $privateKey = $secretValue.private_key
    $password = $secretValue.password
    
    if (-not $certificate -or -not $privateKey) {
      throw "Certificate or private key not found in secret"
    }
    
    # Create temporary files for certificate and key
    $certFile = "$env:TEMP\\ebl_cert.crt"
    $keyFile = "$env:TEMP\\ebl_key.key"
    $pfxFile = "$env:TEMP\\ebl_cert.pfx"
    
    # Write certificate and key to temporary files
    $certificate | Out-File -FilePath $certFile -Encoding ASCII
    $privateKey | Out-File -FilePath $keyFile -Encoding ASCII
    
    # Convert to PFX format using OpenSSL (if available) or PowerShell
    if (Get-Command openssl -ErrorAction SilentlyContinue) {
      $opensslCmd = "openssl pkcs12 -export -out `"$pfxFile`" -inkey `"$keyFile`" -in `"$certFile`" -password pass:$password"
      Invoke-Expression $opensslCmd
    } else {
      # Alternative: Use .NET classes to create PFX
      Write-Warning "OpenSSL not found. Using alternative method to import certificate."
      # Import certificate using PowerShell certificate provider
      $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
      $cert.Import($certFile)
    }
    
    # Import certificate to Windows certificate store
    if (Test-Path $pfxFile) {
      $securePwd = ConvertTo-SecureString -String $password -Force -AsPlainText
      Import-PfxCertificate -FilePath $pfxFile -CertStoreLocation "Cert:\\$certStore\\$certLocation" -Password $securePwd
      Write-Output "Certificate imported successfully to $certStore\\$certLocation"
    } else {
      # Fallback: Import just the certificate
      Import-Certificate -FilePath $certFile -CertStoreLocation "Cert:\\$certStore\\$certLocation"
      Write-Output "Certificate imported successfully (without private key)"
    }
    
    # Clean up temporary files
    Remove-Item $certFile -Force -ErrorAction SilentlyContinue
    Remove-Item $keyFile -Force -ErrorAction SilentlyContinue
    Remove-Item $pfxFile -Force -ErrorAction SilentlyContinue
    
  } catch {
    Write-Error "Failed to retrieve or import certificate: $($_.Exception.Message)"
    throw
  }
  EOH
  action :run
  sensitive true
end

# Configure IIS SSL binding if IIS is installed
powershell_script 'configure_iis_ssl' do
  code <<-EOH
  # Check if IIS is installed and configured
  $iisFeature = Get-WindowsFeature -Name IIS-WebServerRole
  
  if ($iisFeature.InstallState -eq "Installed") {
    Write-Output "Configuring IIS SSL binding for EBL application"
    
    # Import WebAdministration module
    Import-Module WebAdministration -ErrorAction SilentlyContinue
    
    # Get the certificate thumbprint
    $certStore = "#{node['ebl_server']['certificates']['cert_store']}"
    $certLocation = "#{node['ebl_server']['certificates']['cert_store_location']}"
    $cert = Get-ChildItem -Path "Cert:\\$certStore\\$certLocation" | Where-Object { $_.Subject -like "*ebl*" } | Select-Object -First 1
    
    if ($cert) {
      $thumbprint = $cert.Thumbprint
      Write-Output "Found certificate with thumbprint: $thumbprint"
      
      # Remove existing SSL binding if it exists
      try {
        Remove-WebBinding -Name "Default Web Site" -Protocol https -Port 443 -ErrorAction SilentlyContinue
      } catch {
        Write-Output "No existing SSL binding found"
      }
      
      # Create new SSL binding
      New-WebBinding -Name "Default Web Site" -Protocol https -Port 443
      
      # Bind certificate to HTTPS
      $binding = Get-WebBinding -Name "Default Web Site" -Protocol https
      $binding.AddSslCertificate($thumbprint, $certStore)
      
      Write-Output "SSL certificate bound to IIS successfully"
    } else {
      Write-Warning "No suitable certificate found for IIS binding"
    }
  } else {
    Write-Output "IIS not installed, skipping SSL configuration"
  }
  EOH
  action :run
  only_if { node['ebl_server']['windows_features'].any? { |f| f.include?('IIS') } }
end

Chef::Log.info('SSL certificate configuration completed')