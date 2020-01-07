require 'telegram/bot'
require 'logger'

module Helpers
  extend RSpec::SharedContext

  let(:logger) { instance_double(Logger) }
  let(:telegram) { double(Telegram::Bot::Client) }
  let(:chat) { double(Telegram::Bot::Types::Chat) }
  let(:api) { double }
  let(:from) { double }
  # let(:message) { double }
  let(:msg) { double(Telegram::Bot::Types::Message) }
  let(:players) {[{snr: '123:1', name: 'Участник № 1'}, {snr: '123:2', name: 'Участник № 2'}]}
  let(:tournament) { {
    title: 'Традиционный детский шахматный фестиваль "Русская Зима". Турнир D. Рейтинг 1120-1199', 
    start_date: '2020/01/05', start_time: '14:00', finish_date: '2020/01/08'} }
  let(:tracker_options) { {uid: 1, tnr: 2, snr: 3} }
  # let(:player1_hash) { {fullname: "Иванов Иван",
  #   number: 234,
  #   club: "Mount Sent Patrick Academy",
  #   fed: "IND",
  #   tournaments:
  #     [{name: "U-14 (Boys) Pune DSO Organise", start_date: "2019/08/19", finish_date: "2019/08/22"}]} }
  # let(:player2_hash) { {fullname: "Иванов Иван",
  #   number: 428,
  #   club: "Варна",
  #   fed: "BUL",
  #   tournaments:
  #     [{name: "Шах в Двореца 2200 - 3 турнир", start_date: "2019/12/10", finish_date: "2019/12/15"},
  #     {name: "Шах в Двореца 2200 - 2 турнир", start_date: "2019/11/01", finish_date: "2019/11/10"}]} }

  def stub_web(type, request, file_name)
	  stub_request(type, request).
	    with(:headers => {'User-Agent' => 'Telegram bot for the notifying about results: @chessresults_bot'}).
	    to_return(File.read(File.join('test/pages/', file_name)))
  end

  def expect_reply(request, reply)
    reply[:chat_id] = chat.id
    reply[:parse_mode] = 'HTML'
    allow(msg).to receive(:text) { request }
    expect(api).to receive(:send_message).with(reply)
    bot.read(msg)
  end

  def allow_now(datetime)
    allow(DateTime).to receive(:now).and_return(datetime)
  end
end
