#
# Cookbook:: ebl-server
# Recipe:: windows_admin_groups
#
# Copyright:: 2024, AWS Practice Team, MIT Licensed.
#
# Recipe for configuring Windows local admin groups with Bank/AD integration

# Create local bank admin group
powershell_script 'create_bank_admin_group' do
  code <<-EOH
    $groupName = "Bank Local Admins"
    $groupDescription = "Local administrators group for bank operations"
    
    try {
        # Check if group exists
        $group = Get-LocalGroup -Name $groupName -ErrorAction SilentlyContinue
        
        if ($null -eq $group) {
            # Create the local group
            New-LocalGroup -Name $groupName -Description $groupDescription
            Write-Output "Created local group: $groupName"
        } else {
            Write-Output "Local group already exists: $groupName"
        }
        
        # Add the group to local Administrators
        Add-LocalGroupMember -Group "Administrators" -Member $groupName -ErrorAction SilentlyContinue
        Write-Output "Added $groupName to local Administrators group"
        
    } catch {
        Write-Error "Failed to create or configure bank admin group: $_"
        throw
    }
  EOH
  guard_interpreter :powershell_script
  not_if 'Get-LocalGroup -Name "Bank Local Admins" -ErrorAction SilentlyContinue'
end

# Create EBL operators group
powershell_script 'create_ebl_operators_group' do
  code <<-EOH
    $groupName = "EBL Operators"
    $groupDescription = "Operators group for EBL application management"
    
    try {
        # Check if group exists
        $group = Get-LocalGroup -Name $groupName -ErrorAction SilentlyContinue
        
        if ($null -eq $group) {
            # Create the local group
            New-LocalGroup -Name $groupName -Description $groupDescription
            Write-Output "Created local group: $groupName"
        } else {
            Write-Output "Local group already exists: $groupName"
        }
        
        # Grant specific permissions to EBL application
        $eblPath = "#{node['ebl_server']['application_path']}"
        icacls $eblPath /grant "${groupName}:(OI)(CI)F" /T
        
        Write-Output "Configured permissions for $groupName on EBL application"
        
    } catch {
        Write-Error "Failed to create or configure EBL operators group: $_"
        throw
    }
  EOH
  guard_interpreter :powershell_script
  not_if 'Get-LocalGroup -Name "EBL Operators" -ErrorAction SilentlyContinue'
end

# Configure User Rights Assignment for bank operations
powershell_script 'configure_user_rights' do
  code <<-EOH
    # Grant Log on as a service right to EBL service user
    $userRight = "SeServiceLogonRight"
    $user = "ebl_service"
    
    # Use secedit to configure user rights (requires restart of policy)
    $tempFile = "C:\\temp\\secedit_temp.inf"
    $tempDB = "C:\\temp\\secedit_temp.sdb"
    
    # Create temp directory
    if (!(Test-Path "C:\\temp")) {
        New-Item -Path "C:\\temp" -ItemType Directory
    }
    
    # Export current security settings
    secedit /export /cfg $tempFile /quiet
    
    # Read current settings
    $content = Get-Content $tempFile
    
    # Add user to SeServiceLogonRight if not already present
    $updated = $false
    for ($i = 0; $i -lt $content.Length; $i++) {
        if ($content[$i] -like "*SeServiceLogonRight*") {
            if ($content[$i] -notlike "*$user*") {
                $content[$i] = $content[$i] + ",$user"
                $updated = $true
            }
            break
        }
    }
    
    if ($updated) {
        # Write updated settings
        $content | Set-Content $tempFile
        
        # Import updated settings
        secedit /configure /db $tempDB /cfg $tempFile /quiet
        
        # Clean up temp files
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        Remove-Item $tempDB -Force -ErrorAction SilentlyContinue
        
        Write-Output "Granted SeServiceLogonRight to $user"
    } else {
        Write-Output "User $user already has SeServiceLogonRight"
    }
  EOH
  guard_interpreter :powershell_script
  action :run
end

# Configure audit policy for bank compliance
powershell_script 'configure_audit_policy' do
  code <<-EOH
    # Enable audit policies for bank compliance
    auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
    auditpol /set /category:"Account Management" /success:enable /failure:enable
    auditpol /set /category:"Privilege Use" /success:enable /failure:enable
    auditpol /set /category:"Object Access" /success:enable /failure:enable
    
    Write-Output "Configured audit policies for bank compliance"
  EOH
  guard_interpreter :powershell_script
  action :run
end

# Set up PowerShell execution policy for admin scripts
powershell_script 'configure_execution_policy' do
  code <<-EOH
    # Set execution policy to allow signed scripts
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    
    # Configure PowerShell logging for security
    $registryPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\PowerShell\\ModuleLogging"
    if (!(Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }
    Set-ItemProperty -Path $registryPath -Name "EnableModuleLogging" -Value 1
    
    $registryPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\PowerShell\\ScriptBlockLogging"
    if (!(Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }
    Set-ItemProperty -Path $registryPath -Name "EnableScriptBlockLogging" -Value 1
    
    Write-Output "Configured PowerShell execution policy and logging"
  EOH
  guard_interpreter :powershell_script
  action :run
end