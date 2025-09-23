#
# Cookbook:: ebl-server
# Recipe:: ad_join
#
# Copyright:: 2024, AWS Practice Team, MIT Licensed.
#
# Recipe for joining Windows Server to Active Directory domain

# Retrieve AD credentials from AWS Secrets Manager
ruby_block 'retrieve_ad_credentials' do
  block do
    require 'aws-sdk-secretsmanager'
    require 'json'

    # Initialize AWS Secrets Manager client
    secrets_client = Aws::SecretsManager::Client.new(
      region: node['ebl_server']['secrets_manager']['region']
    )

    begin
      # Retrieve AD join credentials
      ad_response = secrets_client.get_secret_value(
        secret_id: node['ebl_server']['ad_secret_name']
      )
      
      ad_data = JSON.parse(ad_response.secret_string)
      
      # Store AD credentials in node run_state for security
      node.run_state['ad_credentials'] = ad_data
      
      Chef::Log.info("Successfully retrieved AD credentials from AWS Secrets Manager")
    rescue Aws::SecretsManager::Errors::ResourceNotFoundException
      Chef::Log.error("AD credentials secret not found in AWS Secrets Manager: #{node['ebl_server']['ad_secret_name']}")
      raise
    rescue => e
      Chef::Log.error("Failed to retrieve AD credentials from AWS Secrets Manager: #{e.message}")
      raise
    end
  end
  action :run
end

# Use the ad_join cookbook to join domain
include_recipe 'ad_join::default'

# Configure additional AD integration after domain join
powershell_script 'configure_ad_integration' do
  code <<-EOH
    $domain = "#{node['ebl_server']['ad_domain']}"
    $adminGroup = "#{node['ebl_server']['admin_group']}"
    
    # Wait for domain join to complete
    Start-Sleep -Seconds 30
    
    # Add domain admin group to local administrators
    try {
        Add-LocalGroupMember -Group "Administrators" -Member "$domain\\$adminGroup" -ErrorAction Stop
        Write-Output "Successfully added $domain\\$adminGroup to local Administrators group"
    } catch [Microsoft.PowerShell.Commands.MemberExistsException] {
        Write-Output "$domain\\$adminGroup is already a member of local Administrators group"
    } catch {
        Write-Error "Failed to add $domain\\$adminGroup to local Administrators group: $_"
        throw
    }
    
    # Configure Group Policy client
    gpupdate /force
    
    # Enable Windows Remote Management for domain
    Enable-PSRemoting -Force
    Set-Item WSMan:\\localhost\\Client\\TrustedHosts -Value "*.$domain" -Force
    
    Write-Output "AD integration configuration completed"
  EOH
  guard_interpreter :powershell_script
  retries 3
  retry_delay 30
  only_if { node.run_state['ad_credentials'] }
  notifies :reboot_now, 'reboot[after_domain_join]', :immediately
end

# Reboot after domain join
reboot 'after_domain_join' do
  action :nothing
  reason 'Reboot required after domain join'
  delay_mins 1
end

# Configure Kerberos authentication for EBL application
powershell_script 'configure_kerberos_for_ebl' do
  code <<-EOH
    $serviceName = "#{node['ebl_server']['service_name']}"
    $domain = "#{node['ebl_server']['ad_domain']}"
    $hostname = $env:COMPUTERNAME
    
    # Create Service Principal Name (SPN) for EBL service
    $spn = "HTTP/$hostname.$domain"
    
    # Register SPN for computer account
    setspn -A $spn $hostname
    
    # Configure delegation if needed
    # This would typically be done by domain admin
    Write-Output "Kerberos configuration for EBL completed"
  EOH
  guard_interpreter :powershell_script
  only_if 'Test-ComputerSecureChannel'
  action :run
end

# Configure LDAP authentication for EBL application
template "#{node['ebl_server']['application_path']}\\config\\ldap.config" do
  source 'ldap.config.erb'
  variables(
    domain: node['ebl_server']['ad_domain'],
    admin_group: node['ebl_server']['admin_group']
  )
  action :create
  notifies :restart, 'windows_service[' + node['ebl_server']['service_name'] + ']', :delayed
end