# InSpec tests for test-cookbook default recipe

describe file('/tmp/kitchen-docker-test.txt') do
  it { should exist }
  it { should be_file }
  its('mode') { should cmp '0644' }
  its('content') { should match(/Kitchen Docker test/) }
end

describe package('curl') do
  it { should be_installed }
end

describe file('/tmp/test-service.sh') do
  it { should exist }
  it { should be_file }
  it { should be_executable }
end

describe command('/tmp/test-service.sh') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/Test service is running/) }
end