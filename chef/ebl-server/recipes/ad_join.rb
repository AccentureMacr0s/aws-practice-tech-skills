#
# Cookbook:: ebl-server
# Recipe:: ad_join
#
# Copyright:: 2024, AWS Practice Team
#
# Handles Active Directory domain join and group management

Chef::Log.info('Configuring Active Directory integration')

# Ensure ad_join cookbook is available
Chef::Log.info("Using ad_join cookbook for domain integration")

# Configure domain join using ad_join cookbook
ad_join_domain node['ebl_server']['ad_integration']['domain'] do
  username node['ebl_server']['ad_integration']['username']
  password node['ebl_server']['ad_integration']['password']
  action :join
  only_if { node['ebl_server']['ad_integration']['enabled'] }
end

# Add domain groups to local administrators
node['ebl_server']['ad_integration']['admin_groups'].each do |group|
  powershell_script "add_domain_group_to_admins_#{group.gsub(' ', '_')}" do
    code <<-EOH
    $groupName = "#{group}"
    $domain = "#{node['ebl_server']['ad_integration']['domain']}"
    $domainGroup = "$domain\\$groupName"
    
    Write-Output "Adding domain group '$domainGroup' to local administrators"
    
    try {
      # Check if group is already a member
      $adminGroup = [ADSI]"WinNT://./Administrators,group"
      $members = @($adminGroup.psbase.Invoke("Members")) | ForEach-Object { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) }
      
      if ($members -contains $groupName) {
        Write-Output "Group '$groupName' is already a member of local administrators"
      } else {
        # Add the domain group to local administrators
        $adminGroup.psbase.Invoke("Add", ([ADSI]"WinNT://$domain/$groupName,group").Path)
        Write-Output "Successfully added '$domainGroup' to local administrators"
      }
    } catch {
      Write-Error "Failed to add group '$domainGroup' to administrators: $($_.Exception.Message)"
      # Try alternative method using net localgroup
      try {
        $result = net localgroup administrators "$domainGroup" /add 2>&1
        if ($LASTEXITCODE -eq 0) {
          Write-Output "Successfully added '$domainGroup' using net localgroup"
        } else {
          Write-Warning "net localgroup returned: $result"
        }
      } catch {
        Write-Error "Alternative method also failed: $($_.Exception.Message)"
      }
    }
    EOH
    action :run
    only_if { node['ebl_server']['ad_integration']['enabled'] }
  end
end

# Configure EBL service to run with domain service account if specified
powershell_script 'configure_service_domain_account' do
  code <<-EOH
  $serviceName = "#{node['ebl_server']['service_name']}"
  $domain = "#{node['ebl_server']['ad_integration']['domain']}"
  $serviceUser = "#{node['ebl_server']['app_user']}"
  
  # Check if service user should be a domain account
  if ($serviceUser -notlike "*\\*") {
    $domainServiceUser = "$domain\\$serviceUser"
    
    Write-Output "Configuring service '$serviceName' to run as domain account '$domainServiceUser'"
    
    try {
      # Stop the service first
      Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
      
      # Change service account
      $service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"
      if ($service) {
        $result = $service.Change($null, $null, $null, $null, $null, $null, $domainServiceUser, $null)
        if ($result.ReturnValue -eq 0) {
          Write-Output "Service account changed successfully"
          
          # Grant logon as service right to domain account
          secedit /export /cfg "$env:TEMP\\secpol.cfg"
          $content = Get-Content "$env:TEMP\\secpol.cfg"
          $newContent = $content -replace "SeServiceLogonRight = (.*)$", "SeServiceLogonRight = `$1,$domainServiceUser"
          $newContent | Out-File "$env:TEMP\\secpol_new.cfg" -Encoding ASCII
          secedit /configure /db "$env:TEMP\\secedit.sdb" /cfg "$env:TEMP\\secpol_new.cfg"
          
          # Start the service
          Start-Service -Name $serviceName
          Write-Output "Service started with domain account"
        } else {
          Write-Error "Failed to change service account. Return value: $($result.ReturnValue)"
        }
      }
    } catch {
      Write-Error "Failed to configure domain service account: $($_.Exception.Message)"
    }
  } else {
    Write-Output "Service user already appears to be a domain account: $serviceUser"
  }
  EOH
  action :run
  only_if { node['ebl_server']['ad_integration']['enabled'] }
end

# Create PowerShell script for manual AD operations
template "#{node['ebl_server']['install_dir']}\\scripts\\ad_management.ps1" do
  source 'ad_management.ps1.erb'
  variables(
    domain: node['ebl_server']['ad_integration']['domain'],
    admin_groups: node['ebl_server']['ad_integration']['admin_groups'],
    service_name: node['ebl_server']['service_name']
  )
  action :create
  only_if { node['ebl_server']['ad_integration']['enabled'] }
end

# Verify domain join status
powershell_script 'verify_domain_join' do
  code <<-EOH
  $domain = "#{node['ebl_server']['ad_integration']['domain']}"
  
  try {
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $currentDomain = $computerSystem.Domain
    
    if ($currentDomain -eq $domain) {
      Write-Output "Successfully joined to domain: $currentDomain"
    } else {
      Write-Warning "Expected domain: $domain, Current domain: $currentDomain"
    }
    
    # Test domain connectivity
    $dcTest = Test-ComputerSecureChannel -Verbose
    if ($dcTest) {
      Write-Output "Domain trust relationship is working correctly"
    } else {
      Write-Warning "Domain trust relationship test failed"
    }
  } catch {
    Write-Error "Failed to verify domain join: $($_.Exception.Message)"
  }
  EOH
  action :run
  only_if { node['ebl_server']['ad_integration']['enabled'] }
end

Chef::Log.info('Active Directory integration completed')