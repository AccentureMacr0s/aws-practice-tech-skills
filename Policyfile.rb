# Policyfile.rb - Describes and locks the software dependencies for EBL Server cookbook

# Policy Name
name 'ebl-server'

# Base run_list
default_source :supermarket

# Cookbook dependencies
cookbook 'ebl-server', path: './cookbooks/ebl-server'
cookbook 'windows'
cookbook 'powershell'

# Assuming ad_join cookbook is available
cookbook 'ad_join', '~> 1.0'

# Default run list for nodes managed by this policy
run_list 'ebl-server::default'

# Specify a named run list for specific environments
named_run_list :ad_integration, 'ebl-server::ad_join', 'ebl-server::default'

# Policy attributes
default['ebl_server']['application_path'] = 'C:\Program Files\EBL'
default['ebl_server']['service_name'] = 'EBLService'
default['ebl_server']['ad_domain'] = 'bank.local'
default['ebl_server']['admin_group'] = 'Bank Admins'
default['ebl_server']['secrets_manager']['region'] = 'us-east-1'
default['ebl_server']['cert_secret_name'] = 'ebl-server/certificates'
default['ebl_server']['ad_secret_name'] = 'ebl-server/ad-credentials'