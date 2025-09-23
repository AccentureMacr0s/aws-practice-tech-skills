require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.platform = 'windows'
  config.version = '2022'
  config.log_level = :error
end