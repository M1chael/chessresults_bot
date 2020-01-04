require 'telegram/bot'
require 'logger'

module Helpers
  extend RSpec::SharedContext

  let(:logger) { instance_double(Logger) }
  let(:telegram) { double(Telegram::Bot::Client) }
  let(:message) { double(Telegram::Bot::Types::Message) }
  let(:chat) { double(Telegram::Bot::Types::Chat) }
  let(:api) { double }
  let(:msg) { double(Telegram::Bot::Types::Message) }

  def stub_web(type, request, file_name)
	  stub_request(type, request).
	    with(:headers => {'User-Agent' => 'Telegram bot for the notifying about results: @chessresults_bot'}).
	    to_return(File.read(File.join('test/pages/', file_name)))
  end

  def expect_reply(request, reply)
    allow(msg).to receive(:text) { request }
    expect(api).to receive(:send_message).with(chat_id: chat.id, text: reply, parse_mode: 'HTML')
    bot.read(msg)  
  end
end
