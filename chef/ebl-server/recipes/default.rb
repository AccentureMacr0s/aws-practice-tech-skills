#
# Cookbook:: ebl-server
# Recipe:: default
#
# Copyright:: 2024, AWS Practice Team
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Ensure we're on a Windows platform
unless platform_family?('windows')
  Chef::Log.fatal('This cookbook is designed for Windows systems only')
  raise 'Unsupported platform'
end

# Main orchestration recipe for EBL server setup
Chef::Log.info('Starting EBL server configuration')

# Include sub-recipes in the correct order
include_recipe 'ebl-server::prerequisites'
include_recipe 'ebl-server::install'
include_recipe 'ebl-server::configure'

# Conditionally include additional recipes
include_recipe 'ebl-server::certificates' if node['ebl_server']['certificates']['enabled']
include_recipe 'ebl-server::ad_join' if node['ebl_server']['ad_integration']['enabled']
include_recipe 'ebl-server::firewall' if node['ebl_server']['firewall']['enabled']

Chef::Log.info('EBL server configuration completed successfully')