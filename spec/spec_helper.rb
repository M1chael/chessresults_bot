$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'webmock/rspec'
require 'yaml'
require 'helpers'

wd = File.join(File.expand_path(File.dirname(__FILE__)), '../')
CONFIG = YAML.load_file(File.join(wd, 'assets', 'config.yml'))

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |c|
  c.before(:example) do
    c.include Helpers
  end
end
