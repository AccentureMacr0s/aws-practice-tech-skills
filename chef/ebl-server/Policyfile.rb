# Policyfile.rb - Describes and locks the run_list and cookbook versions used by this cookbook

# A name that describes what the system you're building with Chef does.
name 'ebl-server'

# Where to find external cookbooks:
default_source :supermarket

# Run_list: chef-client will run these recipes in the order specified.
run_list 'ebl-server::default'

# Cookbook dependencies from the Chef Supermarket
cookbook 'ad_join', '~> 1.0'
cookbook 'windows', '~> 4.0' 
cookbook 'chef-vault', '~> 4.0'

# Specify a custom source for a cookbook:
cookbook 'ebl-server', path: '.'

# Named run_lists for different environments
named_run_list 'base', 'ebl-server::install'
named_run_list 'configure', 'ebl-server::configure'
named_run_list 'ad_integration', 'ebl-server::ad_join'