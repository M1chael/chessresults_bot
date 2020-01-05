require 'telegram/bot'
require 'logger'

module Helpers
  extend RSpec::SharedContext

  let(:logger) { instance_double(Logger) }
  let(:telegram) { double(Telegram::Bot::Client) }
  let(:chat) { double(Telegram::Bot::Types::Chat) }
  let(:api) { double }
  let(:from) { double }
  let(:message) { double }
  let(:msg) { double(Telegram::Bot::Types::Message) }
  let(:player1_hash) { {:fullname=>"Иванов Иван",
    :number=>234,
    :club=>"Mount Sent Patrick Academy",
    :fed=>"IND",
    :tournaments=>
      [{:name=>"U-14 (Boys) Pune DSO Organise", :finish_date=>"2019/08/22"}]} }
  let(:player2_hash) { {:fullname=>"Иванов Иван",
    :number=>428,
    :club=>"Варна",
    :fed=>"BUL",
    :tournaments=>
      [{:name=>"Шах в Двореца 2200 - 3 турнир", :finish_date=>"2019/12/15"},
      {:name=>"Шах в Двореца 2200 - 2 турнир", :finish_date=>"2019/11/10"}]} }

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

  def allow_today(date)
    allow(Date).to receive(:today).and_return(date)
  end
end
