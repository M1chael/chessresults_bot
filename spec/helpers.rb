require 'telegram/bot'
require 'logger'

module Helpers
  extend RSpec::SharedContext

  let(:logger) { instance_double(Logger) }
  let(:telegram) { double(Telegram::Bot::Client) }
  let(:chat) { double(Telegram::Bot::Types::Chat) }
  let(:api) { double }
  let(:from) { double }
  let(:msg) { double(Telegram::Bot::Types::Message) }
  let(:message) { double }
  let(:players) {[{snr: '123:1', name: 'Участник № 1'}, {snr: '123:2', name: 'Участник № 2'}]}
  let(:tournament) { {
    title: 'Традиционный детский шахматный фестиваль "Русская Зима". Турнир D. Рейтинг 1120-1199', 
    start_date: '2020/01/05', start_time: '14:00', finish_date: '2020/01/08'} }
  let(:tracker_instance) { instance_double(Tracker) }
  let(:tracker_options) { {uid: 1, tnr: 2, snr: 3} }
  let(:draw) { {tournament: 
    'Традиционный детский шахматный фестиваль "Русская Зима". Турнир D. Рейтинг 1120-1199', rd: 1,
    date: '2020/01/07', time: '12:30', 
    player: 'Бондарев Илья', color: 'белыми', desk: 6, 
    opponent: 'Попуца Дмитрий', rating: 1133} }
  let(:rank) { {tournament: 
    'Газовик опен юниор 2019, турнир Школьник, турнр А, рейтинг 1000-1100', rd: 1,
    player: 'Ольховик Анна', score: '1,0', rank: 7} }

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

  def allow_today(date)
    allow(Date).to receive(:today).and_return(date)
  end
end
