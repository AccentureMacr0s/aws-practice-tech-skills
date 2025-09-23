#
# Cookbook:: ebl-server
# Recipe:: firewall
#
# Copyright:: 2024, AWS Practice Team
#
# Configures Windows Firewall rules for EBL application

Chef::Log.info('Configuring Windows Firewall for EBL application')

# Enable Windows Firewall
powershell_script 'enable_windows_firewall' do
  code <<-EOH
  Write-Output "Enabling Windows Firewall for all profiles"
  
  # Enable firewall for all profiles
  Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
  
  # Log firewall activity
  Set-NetFirewallProfile -Profile Domain,Public,Private -LogAllowed True -LogBlocked True -LogMaxSizeKilobytes 32767
  
  Write-Output "Windows Firewall enabled and logging configured"
  EOH
  action :run
end

# Create firewall rules for EBL application ports
node['ebl_server']['firewall']['ports'].each do |port_config|
  powershell_script "create_firewall_rule_#{port_config['name']}" do
    code <<-EOH
    $ruleName = "#{port_config['name']}"
    $port = #{port_config['port']}
    $protocol = "#{port_config['protocol']}"
    
    Write-Output "Creating firewall rule: $ruleName for port $port ($protocol)"
    
    # Remove existing rule if it exists
    Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    
    # Create new inbound rule
    New-NetFirewallRule -DisplayName $ruleName `
                        -Direction Inbound `
                        -Protocol $protocol `
                        -LocalPort $port `
                        -Action Allow `
                        -Profile Domain,Private,Public `
                        -Description "EBL Application - $ruleName"
    
    Write-Output "Firewall rule '$ruleName' created successfully"
    EOH
    action :run
  end
end

# Create outbound rule for EBL application
powershell_script 'create_ebl_outbound_rule' do
  code <<-EOH
  $ruleName = "EBL-Application-Outbound"
  $programPath = "#{node['ebl_server']['install_dir']}\\#{node['ebl_server']['package_name']}"
  
  Write-Output "Creating outbound firewall rule for EBL application"
  
  # Remove existing rule if it exists
  Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
  
  # Create outbound rule for EBL application
  if (Test-Path $programPath) {
    New-NetFirewallRule -DisplayName $ruleName `
                        -Direction Outbound `
                        -Program $programPath `
                        -Action Allow `
                        -Profile Domain,Private,Public `
                        -Description "Allow EBL Application outbound connections"
    
    Write-Output "Outbound firewall rule created for EBL application"
  } else {
    Write-Warning "EBL application not found at $programPath, skipping program-specific rule"
  }
  EOH
  action :run
end

# Configure firewall logging
powershell_script 'configure_firewall_logging' do
  code <<-EOH
  $logPath = "#{node['ebl_server']['log_dir']}\\firewall.log"
  
  Write-Output "Configuring firewall logging to $logPath"
  
  # Create log directory if it doesn't exist
  $logDir = Split-Path $logPath -Parent
  if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
  }
  
  # Configure firewall logging
  Set-NetFirewallProfile -Profile Domain,Public,Private `
                         -LogFileName $logPath `
                         -LogAllowed True `
                         -LogBlocked True `
                         -LogMaxSizeKilobytes 32767
  
  Write-Output "Firewall logging configured successfully"
  EOH
  action :run
end

# Create firewall management script
template "#{node['ebl_server']['install_dir']}\\scripts\\firewall_management.ps1" do
  source 'firewall_management.ps1.erb'
  variables(
    app_name: node['ebl_server']['app_name'],
    ports: node['ebl_server']['firewall']['ports'],
    install_dir: node['ebl_server']['install_dir'],
    package_name: node['ebl_server']['package_name']
  )
  action :create
end

# Test firewall rules
powershell_script 'test_firewall_rules' do
  code <<-EOH
  Write-Output "Testing firewall rules for EBL application"
  
  # List all EBL-related firewall rules
  $eblRules = Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*EBL*" }
  
  if ($eblRules) {
    Write-Output "Found $($eblRules.Count) EBL firewall rules:"
    $eblRules | ForEach-Object {
      Write-Output "  - $($_.DisplayName): $($_.Direction) $($_.Action) (Profile: $($_.Profile))"
    }
  } else {
    Write-Warning "No EBL firewall rules found"
  }
  
  # Test specific ports
  #{node['ebl_server']['firewall']['ports'].map { |p| 
    "$port = #{p['port']}\n" +
    "$protocol = '#{p['protocol']}'\n" +
    "$ruleName = '#{p['name']}'\n" +
    "$rule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue\n" +
    "if ($rule) {\n" +
    "  Write-Output \"Port $port ($protocol) rule '$ruleName' is configured\"\n" +
    "} else {\n" +
    "  Write-Warning \"Port $port ($protocol) rule '$ruleName' not found\"\n" +
    "}\n"
  }.join("\n")}
  
  Write-Output "Firewall rule testing completed"
  EOH
  action :run
end

Chef::Log.info('Windows Firewall configuration completed')