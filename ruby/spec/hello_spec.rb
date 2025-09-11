# frozen_string_literal: true

RSpec.describe 'Hello Ruby' do
  it 'should be able to run hello world file' do
    expect { load File.expand_path('../file_operations/hello.rb', __dir__) }.not_to raise_error
  end

  it 'should generate unique IDs' do
    load File.expand_path('../file_operations/hello.rb', __dir__)
    expect(defined?(generate_unique_id)).to be_truthy
    expect(generate_unique_id).to be_a(String)
    expect(generate_unique_id.length).to eq(16)
  end
end
