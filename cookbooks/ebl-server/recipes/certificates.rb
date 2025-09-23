#
# Cookbook:: ebl-server
# Recipe:: certificates
#
# Copyright:: 2024, AWS Practice Team, MIT Licensed.
#
# Recipe for managing certificates using AWS Secrets Manager

# Create library for AWS Secrets Manager integration
ruby_block 'retrieve_certificates_from_secrets_manager' do
  block do
    require 'aws-sdk-secretsmanager'
    require 'json'
    require 'base64'

    # Initialize AWS Secrets Manager client
    secrets_client = Aws::SecretsManager::Client.new(
      region: node['ebl_server']['secrets_manager']['region']
    )

    begin
      # Retrieve certificate secrets
      cert_response = secrets_client.get_secret_value(
        secret_id: node['ebl_server']['cert_secret_name']
      )
      
      cert_data = JSON.parse(cert_response.secret_string)
      
      # Store certificate data in node attributes for use by other resources
      node.run_state['ebl_certificates'] = cert_data
      
      Chef::Log.info("Successfully retrieved certificates from AWS Secrets Manager")
    rescue Aws::SecretsManager::Errors::ResourceNotFoundException
      Chef::Log.error("Certificate secret not found in AWS Secrets Manager: #{node['ebl_server']['cert_secret_name']}")
      raise
    rescue => e
      Chef::Log.error("Failed to retrieve certificates from AWS Secrets Manager: #{e.message}")
      raise
    end
  end
  action :run
end

# Create certificate directory
directory 'C:\certificates' do
  action :create
end

# Install certificates retrieved from Secrets Manager
ruby_block 'install_certificates' do
  block do
    cert_data = node.run_state['ebl_certificates']
    
    if cert_data
      # Install server certificate
      if cert_data['server_cert']
        cert_content = Base64.decode64(cert_data['server_cert'])
        File.write('C:\certificates\server.pfx', cert_content)
        
        # Import certificate to Windows certificate store
        system("certutil -f -p \"#{cert_data['server_cert_password']}\" -importpfx \"C:\\certificates\\server.pfx\"")
        Chef::Log.info("Server certificate installed successfully")
      end
      
      # Install CA certificate
      if cert_data['ca_cert']
        ca_content = Base64.decode64(cert_data['ca_cert'])
        File.write('C:\certificates\ca.crt', ca_content)
        
        # Import CA certificate to Trusted Root store
        system("certutil -addstore -f \"Root\" \"C:\\certificates\\ca.crt\"")
        Chef::Log.info("CA certificate installed successfully")
      end
    end
  end
  action :run
  only_if { node.run_state['ebl_certificates'] }
end

# Configure certificate permissions for EBL application
powershell_script 'configure_certificate_permissions' do
  code <<-EOH
    # Grant EBL service user access to private keys
    $certStore = "Cert:\\LocalMachine\\My"
    $certificates = Get-ChildItem -Path $certStore | Where-Object { $_.Subject -like "*ebl*" -or $_.Subject -like "*bank*" }
    
    foreach ($cert in $certificates) {
        $keyPath = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert).Key.UniqueName
        $keyFullPath = "$env:ProgramData\\Microsoft\\Crypto\\RSA\\MachineKeys\\$keyPath"
        
        if (Test-Path $keyFullPath) {
            # Grant read access to EBL service user
            icacls $keyFullPath /grant "ebl_service:R"
            Write-Output "Granted certificate access to ebl_service for: $($cert.Subject)"
        }
    }
  EOH
  guard_interpreter :powershell_script
  only_if { node.run_state['ebl_certificates'] }
end

# Create certificate renewal task
windows_task 'certificate_renewal_check' do
  user 'SYSTEM'
  cwd 'C:\certificates'
  command 'powershell.exe'
  command_arguments '-File C:\certificates\check_cert_expiry.ps1'
  run_level :highest
  frequency :daily
  start_time '02:00'
  action [:create, :enable]
end

# Deploy certificate monitoring script
template 'C:\certificates\check_cert_expiry.ps1' do
  source 'check_cert_expiry.ps1.erb'
  variables(
    notification_email: 'admin@bank.local',
    expiry_threshold_days: 30
  )
  action :create
end