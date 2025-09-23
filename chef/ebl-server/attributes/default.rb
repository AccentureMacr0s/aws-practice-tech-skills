# Default attributes for EBL server cookbook

# Application settings
default['ebl_server']['app_name'] = 'EBL Application'
default['ebl_server']['version'] = '1.0.0'
default['ebl_server']['install_dir'] = 'C:\Program Files\EBL'
default['ebl_server']['data_dir'] = 'C:\ProgramData\EBL'
default['ebl_server']['log_dir'] = 'C:\ProgramData\EBL\logs'
default['ebl_server']['service_name'] = 'EBLService'
default['ebl_server']['service_display_name'] = 'EBL Application Service'

# Application user settings
default['ebl_server']['app_user'] = 'ebl_service'
default['ebl_server']['app_user_password'] = nil # Will be retrieved from secrets manager

# Download settings
default['ebl_server']['download_url'] = nil # Will be set based on version
default['ebl_server']['package_name'] = 'EBL.exe'
default['ebl_server']['checksum'] = nil

# Certificate settings
default['ebl_server']['certificates']['enabled'] = true
default['ebl_server']['certificates']['ssl_cert_secret'] = 'ebl/ssl-certificate'
default['ebl_server']['certificates']['aws_region'] = 'us-east-1'
default['ebl_server']['certificates']['cert_store'] = 'LocalMachine'
default['ebl_server']['certificates']['cert_store_location'] = 'My'

# Active Directory settings
default['ebl_server']['ad_integration']['enabled'] = false
default['ebl_server']['ad_integration']['domain'] = nil
default['ebl_server']['ad_integration']['username'] = nil
default['ebl_server']['ad_integration']['password'] = nil
default['ebl_server']['ad_integration']['admin_groups'] = ['Domain Admins', 'EBL Administrators']

# Windows features and roles
default['ebl_server']['windows_features'] = [
  'IIS-WebServerRole',
  'IIS-WebServer',
  'IIS-CommonHttpFeatures',
  'IIS-HttpErrors',
  'IIS-HttpRedirect',
  'IIS-ApplicationDevelopment',
  'IIS-NetFxExtensibility45',
  'IIS-ASPNET45',
  'IIS-ISAPIExtensions',
  'IIS-ISAPIFilter'
]

# Firewall settings
default['ebl_server']['firewall']['enabled'] = true
default['ebl_server']['firewall']['ports'] = [
  { 'name' => 'EBL-HTTP', 'port' => 80, 'protocol' => 'TCP' },
  { 'name' => 'EBL-HTTPS', 'port' => 443, 'protocol' => 'TCP' },
  { 'name' => 'EBL-Custom', 'port' => 8080, 'protocol' => 'TCP' }
]