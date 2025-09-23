require 'spec_helper'

describe 'ebl-server::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'windows', version: '2022') do |node|
      node.automatic['domain'] = 'bank.local'
      node.override['ebl_server']['application_path'] = 'C:\Program Files\EBL'
      node.override['ebl_server']['service_name'] = 'EBLService'
    end.converge(described_recipe)
  end

  before do
    stub_command('Get-NetFirewallRule -DisplayName "EBL Application" -ErrorAction SilentlyContinue').and_return(false)
    stub_command('Get-Service -Name \'EBLService\' -ErrorAction SilentlyContinue').and_return(false)
    stub_command('[System.Diagnostics.EventLog]::SourceExists("EBL.exe")').and_return(false)
  end

  it 'includes the certificates recipe' do
    expect(chef_run).to include_recipe('ebl-server::certificates')
  end

  it 'includes the ebl_application recipe' do
    expect(chef_run).to include_recipe('ebl-server::ebl_application')
  end

  it 'includes the windows_admin_groups recipe' do
    expect(chef_run).to include_recipe('ebl-server::windows_admin_groups')
  end

  it 'installs IIS-WebServerRole feature' do
    expect(chef_run).to install_windows_feature('IIS-WebServerRole')
  end

  it 'installs IIS-WebServer feature' do
    expect(chef_run).to install_windows_feature('IIS-WebServer')
  end

  it 'creates application directory' do
    expect(chef_run).to create_directory('C:\Program Files\EBL').with(
      recursive: true
    )
  end

  it 'configures EBL firewall rules' do
    expect(chef_run).to run_powershell_script('configure_ebl_firewall')
  end

  it 'logs successful completion' do
    expect(chef_run).to write_log('EBL Server configuration completed successfully')
  end
end