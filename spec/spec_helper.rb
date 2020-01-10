$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'webmock/rspec'
require 'yaml'
require 'helpers'
require 'sequel'
require 'strings'

wd = File.join(File.expand_path(File.dirname(__FILE__)), '../')
CONFIG = YAML.load_file(File.join(wd, 'assets', 'config.yml'))
DB = Sequel.sqlite(File.expand_path('../../assets/trackers.db', __FILE__))

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |c|
  c.include Helpers
  c.around(:example, :db) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) { DB[:trackers].delete; example.run }
  end

  c.before(:example, :logger) do
    allow(Logger).to receive(:new) { logger }
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
  end
  
  c.before(:example, :telegram) do
    allow(msg).to receive(:from) { from }
    allow(from).to receive(:id) { 1 }
    allow(msg).to receive(:id) { 10 }
    allow(msg).to receive(:chat) { chat }
    allow(msg).to receive(:message) { message }
    allow(message).to receive(:reply_markup)
    allow(message).to receive(:message_id) { 10 }
    allow(chat).to receive(:id) { 1 }
    allow(telegram).to receive(:api) { api }
    allow(api).to receive(:send_message)
    allow(api).to receive(:answer_callback_query)
    allow(api).to receive(:edit_message_reply_markup)
    allow(Telegram::Bot::Client).to receive(:run).
      with('test_token', logger: logger).and_yield(telegram)
    allow(bot).to receive(:tracker_info)
    allow(api).to receive(:delete_message)
  end
end
