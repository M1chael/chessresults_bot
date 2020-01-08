require 'bot'
require 'spec_helper'

describe Bot, :logger, :telegram, :db do
  let(:bot) { Bot.new(token: 'test_token', logger: logger) }
  let(:tracker) { instance_double(Tracker) }

  before(:example) do
    bot.instance_variable_set(:@telegram, telegram)
    allow(bot).to receive(:list_players).and_return(players)
    allow(bot).to receive(:tournament_info).and_return(tournament)
    allow(Tracker).to receive(:new).and_return(tracker)
    allow(tracker).to receive(:set)
    allow(tracker).to receive(:update)
  end

  describe '#read' do
    it 'says hello' do
      expect_reply('/start', text: STRINGS[:hello])
    end

    it 'says nothing found when there are no players' do
      allow(bot).to receive(:list_players).and_return([])
      expect_reply('wrongnumber', text: STRINGS[:nothing_found])
    end

    it 'says nothing found when there is no finish date' do
      allow(bot).to receive(:tournament_info).and_return(finish_date: 'unknown')
      expect_reply('wrongnumber', text: STRINGS[:nothing_found])
    end   

    it 'lists players of tournament' do
      players.each do |player|
        allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
          with(text: player[:name], callback_data: player[:snr]).and_return(player[:name])
      end
      allow(Telegram::Bot::Types::InlineKeyboardMarkup).to receive(:new).
        with(inline_keyboard: [[players[0][:name]], [players[1][:name]]]).and_return('kb')
      expect_reply('123', text: STRINGS[:choose_player] % tournament, reply_markup: 'kb')
    end

    context 'when player button pressed' do
      before(:example) do
        allow(msg).to receive(:data) { "#{tracker_options[:tnr]}:#{tracker_options[:snr]}" }
      end

      it 'tracks player' do
        expect(Tracker).to receive(:new).with(tracker_options)
        expect(tracker).to receive(:set)
        bot.read(msg)
      end

      it 'shows notification about player tracking' do
        expect(api).to receive(:answer_callback_query).with(callback_query_id: 10,
          text: STRINGS[:player_added])
        bot.read(msg)        
      end
    end
  end

  describe '#post' do
    let(:information) { draw.dup }
      
    before(:example) do
      DB[:trackers].insert(uid: 1, tnr: 2, snr: 3, draw: 0, result: 0)
      allow(bot).to receive(:stage_info)
      information[:color] = 'белыми'
    end

    it 'sends message about draw' do
      allow(bot).to receive(:tournament_stage).with(2).and_return(draw: 1, result: 0)
      allow(bot).to receive(:stage_info).with(stage: :draw, tnr: 2, snr: 3, rd: 1).
        and_return(draw)
      expect(api).to receive(:send_message).with(chat_id: 1, :parse_mode=>"HTML", 
        text: STRINGS[:draw] % information)
      bot.post
    end

    it 'sends message about result' do
      allow(bot).to receive(:tournament_stage).with(2).and_return(draw: 0, result: 1)
      allow(bot).to receive(:stage_info).with(stage: :result, tnr: 2, snr: 3, rd: 1).
        and_return(rank)
       expect(api).to receive(:send_message).with(chat_id: 1, :parse_mode=>"HTML", 
        text: STRINGS[:result] % rank)
      bot.post           
    end

    it 'sends messages about multiple draws and results' do
      allow(bot).to receive(:tournament_stage).with(2).and_return(draw: 3, result: 2)
      allow(bot).to receive(:stage_info).with(hash_including(stage: :draw)).and_return(draw)
      allow(bot).to receive(:stage_info).with(hash_including(stage: :result)).and_return(rank)
      expect(api).to receive(:send_message).exactly(5).times
      bot.post           
    end

    it 'updates tracker' do
      allow(bot).to receive(:tournament_stage).with(2).and_return(draw: 0, result: 1)
      allow(bot).to receive(:stage_info).and_return(rank)
      expect(Tracker).to receive(:new).with(uid: 1, tnr: 2, snr: 3, draw: 0, result: 0)
      expect(tracker).to receive(:update).with(result: 1)
      bot.post
    end

    it 'removes tracker' do
      allow_today(Date.parse('2020/01/09'))
      expect(tracker).to receive(:delete)
      bot.post
    end
  end
end
