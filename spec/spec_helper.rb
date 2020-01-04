$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'webmock/rspec'
require 'yaml'
require 'helpers'
require 'sequel'

wd = File.join(File.expand_path(File.dirname(__FILE__)), '../')
CONFIG = YAML.load_file(File.join(wd, 'assets', 'config.yml'))
DB = Sequel.sqlite(File.expand_path('../../assets/results.db', __FILE__))

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |c|
  c.include Helpers
  c.around(:example) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end

  c.before(:example, :logger) do
    allow(Logger).to receive(:new) { logger }
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
  end
  
  c.before(:example, :telegram) do
    allow(msg).to receive(:chat) { chat }
    allow(chat).to receive(:id) { 1 }
    allow(telegram).to receive(:api) { api }
    allow(api).to receive(:send_message)
    allow(api).to receive(:send_chat_action)
  end
end
