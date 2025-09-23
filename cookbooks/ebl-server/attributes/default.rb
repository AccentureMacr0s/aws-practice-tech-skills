#
# Cookbook:: ebl-server
# Attributes:: default
#
# Copyright:: 2024, AWS Practice Team, MIT Licensed.
#
# Default attributes for EBL server configuration

# Application settings
default['ebl_server']['application_path'] = 'C:\Program Files\EBL'
default['ebl_server']['service_name'] = 'EBLService'
default['ebl_server']['service_user'] = 'ebl_service'
default['ebl_server']['service_password'] = 'ComplexP@ssw0rd123!'

# Active Directory settings
default['ebl_server']['ad_domain'] = 'bank.local'
default['ebl_server']['admin_group'] = 'Bank Admins'
default['ebl_server']['operators_group'] = 'EBL Operators'

# AWS Secrets Manager settings
default['ebl_server']['secrets_manager']['region'] = 'us-east-1'
default['ebl_server']['cert_secret_name'] = 'ebl-server/certificates'
default['ebl_server']['ad_secret_name'] = 'ebl-server/ad-credentials'

# Certificate settings
default['ebl_server']['certificates']['store_location'] = 'LocalMachine'
default['ebl_server']['certificates']['store_name'] = 'My'
default['ebl_server']['certificates']['expiry_threshold_days'] = 30

# Network settings
default['ebl_server']['network']['http_port'] = 8080
default['ebl_server']['network']['https_port'] = 8443
default['ebl_server']['network']['management_port'] = 9090

# Logging settings
default['ebl_server']['logging']['level'] = 'INFO'
default['ebl_server']['logging']['max_file_size'] = '100MB'
default['ebl_server']['logging']['max_files'] = 10
default['ebl_server']['logging']['log_path'] = 'C:\Logs\EBL'

# Security settings
default['ebl_server']['security']['enable_ssl'] = true
default['ebl_server']['security']['min_tls_version'] = '1.2'
default['ebl_server']['security']['cipher_suites'] = [
  'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
  'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
  'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
  'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'
]

# Monitoring settings
default['ebl_server']['monitoring']['enable_health_check'] = true
default['ebl_server']['monitoring']['health_check_interval'] = 30
default['ebl_server']['monitoring']['metrics_enabled'] = true

# Backup settings
default['ebl_server']['backup']['enable_auto_backup'] = true
default['ebl_server']['backup']['backup_schedule'] = '0 2 * * *' # Daily at 2 AM
default['ebl_server']['backup']['retention_days'] = 30

# Windows-specific settings
default['ebl_server']['windows']['features'] = [
  'IIS-WebServerRole',
  'IIS-WebServer',
  'IIS-CommonHttpFeatures',
  'IIS-HttpErrors',
  'IIS-HttpLogging',
  'IIS-RequestFiltering',
  'IIS-StaticContent'
]

# Firewall rules
default['ebl_server']['firewall']['rules'] = [
  {
    'name' => 'EBL Application HTTP',
    'direction' => 'Inbound',
    'protocol' => 'TCP',
    'local_port' => node['ebl_server']['network']['http_port'],
    'action' => 'Allow'
  },
  {
    'name' => 'EBL Application HTTPS',
    'direction' => 'Inbound',
    'protocol' => 'TCP',
    'local_port' => node['ebl_server']['network']['https_port'],
    'action' => 'Allow'
  },
  {
    'name' => 'EBL Management',
    'direction' => 'Inbound',
    'protocol' => 'TCP',
    'local_port' => node['ebl_server']['network']['management_port'],
    'action' => 'Allow'
  }
]