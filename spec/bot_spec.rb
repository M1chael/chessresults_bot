require 'bot'
require 'spec_helper'

describe Bot, :logger, :telegram, :tracker do
  let(:bot) { Bot.new(token: 'test_token', logger: logger) }
  let(:tnr) { instance_double(Tournament) }

  before(:example) do
    bot.instance_variable_set(:@telegram, telegram)
    allow(tnr).to receive(:list_players_for_user) {players}
    allow(tnr).to receive(:info) {tournament}
    allow(Tournament).to receive(:new) {tnr}
  end

  describe '#read' do
    it 'says hello' do
      expect_reply('/start', text: STRINGS[:hello])
    end

    it 'lists trackers' do
      trackers = [{uid: 1, tnr: 2, snr: 3, draw: 0, result: 0}, 
        {uid: 1, tnr: 2, snr: 1, draw: 1, result: 2}]
      allow(Tracker).to receive(:list_trackers) {trackers}
      trackers.each do|tracker| 
        allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
          with(text: 'Удалить', callback_data: '%{tnr}:%{snr}' % tracker).
          and_return('%{tnr}:%{snr}' % tracker)
        allow(Telegram::Bot::Types::InlineKeyboardMarkup).to receive(:new).
          with(inline_keyboard: [['%{tnr}:%{snr}' % tracker]]).
          and_return('%{tnr}:%{snr}' % tracker)
      end
      trackers.each do |tracker|
        tracker_info = {tournament: "tournament#{tracker[:tnr]}",
          name: "player#{tracker[:snr]}"}
        allow(tracker_instance).to receive(:info).and_return(tracker_info)
        expect_reply('/list', text: STRINGS[:tracker] % tracker_info, 
          reply_markup: '%{tnr}:%{snr}' % tracker)
        end
    end

    it 'says no trackers' do
      expect_reply('/list', text: STRINGS[:notrackers])
    end

    it 'says nothing found when there are no players' do
      allow(tnr).to receive(:list_players_for_user) {[]}
      expect_reply('wrongnumber', text: STRINGS[:nothing_found])
    end

    it 'says nothing found when there is no finish date' do
      allow(tnr).to receive(:info) {{finish_date: 'unknown'}}
      expect_reply('wrongnumber', text: STRINGS[:nothing_found])
    end   

    it 'lists all players of tournament if there are no already setted trackers' do
      players.each do |player|
        allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
          with(text: player[:name], callback_data: player[:snr]).and_return(player[:name])
      end
      allow(Telegram::Bot::Types::InlineKeyboardMarkup).to receive(:new).
        with(inline_keyboard: [[players[0][:name]], [players[1][:name]]]).and_return('kb')
      expect_reply('123', text: STRINGS[:choose_player] % tournament, reply_markup: 'kb')
    end

    it 'lists all players of tournament without already tracked' do
      allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
        with(text: players[1][:name], callback_data: players[1][:snr]).and_return(players[1][:name])
      allow(Telegram::Bot::Types::InlineKeyboardMarkup).to receive(:new).
        with(inline_keyboard: [[players[1][:name]]]).and_return('kb')
      allow(tnr).to receive(:list_players_for_user) {[players[1]]}
      expect_reply('123', text: STRINGS[:choose_player] % tournament, reply_markup: 'kb')
    end

    context 'when inline button pressed' do
      before(:example) do
        allow(msg).to receive(:data) { "#{tracker_options[:tnr]}:#{tracker_options[:snr]}" }
        allow(tracker_instance).to receive(:toggle) {:tracker_added}
        allow(message).to receive(:reply_markup) { {inline_keyboard: [[{'text'=> '1', 'callback_data'=> '1'}], 
          [{'text'=>'2', 'callback_data'=> "#{tracker_options[:tnr]}:#{tracker_options[:snr]}"}]]} }
        allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
          with('text'=> '1', 'callback_data'=> '1') { '1' }
        allow(Telegram::Bot::Types::InlineKeyboardMarkup).to receive(:new).
          with(inline_keyboard: [['1']]).and_return('kb')
      end

      context 'when player button pressed' do
        it 'tracks player' do
          expect(Tracker).to receive(:new).with(tracker_options)
          expect(tracker_instance).to receive(:toggle).and_return(:tracker_added)
          bot.read(msg)
        end

        it 'shows notification about player tracking' do
          expect(api).to receive(:answer_callback_query).with(callback_query_id: 10,
            text: STRINGS[:tracker_added])
          bot.read(msg)    
        end

        it 'updates markup' do
          expect(api).to receive(:edit_message_reply_markup).with(chat_id: 1, message_id: 10,
            reply_markup: 'kb')          
          bot.read(msg)    
        end
      end

      context 'when delete button pressed' do
        before(:example) do
          allow(tracker_instance).to receive(:toggle) {:tracker_deleted}
        end

        it 'untracks player' do
          expect(Tracker).to receive(:new).with(tracker_options)
          expect(tracker_instance).to receive(:toggle).and_return(:tracker_deleted)
          bot.read(msg)          
        end

        it 'shows notification about player untracking' do
          expect(api).to receive(:answer_callback_query).with(callback_query_id: 10,
            text: STRINGS[:tracker_deleted])
          bot.read(msg)                  
        end

        it 'deletes message with deleted tracker' do
          expect(api).to receive(:delete_message).with(chat_id: 1, message_id: 10)
          bot.read(msg)                  
        end
      end
    end
  end

  describe '#post' do
    before(:example) do
      allow_today(Date.parse('2020/01/07'))
      allow(tnr).to receive(:results)
      allow(Tracker).to receive(:list_trackers) {[{uid: 1, tnr: 2, snr: 3, draw: 0, result: 0}]}
    end

    it 'sends message about draw' do
      allow(tnr).to receive(:stage) {{draw: 1, result: 0}}
      allow(tnr).to receive(:results).with(stage: :draw, snr: 3, rd: 1) {draw}
      expect(api).to receive(:send_message).with(chat_id: 1, parse_mode: 'HTML', 
        text: STRINGS[:draw] % draw)
      bot.post
    end

    it 'sends message about result' do
      allow(tnr).to receive(:stage) {{draw: 0, result: 1}}
      allow(tnr).to receive(:results).with(stage: :result, snr: 3, rd: 1) {rank}
      expect(api).to receive(:send_message).with(chat_id: 1, parse_mode: 'HTML', 
        text: STRINGS[:result] % rank)
      bot.post           
    end

    it 'sends messages about multiple draws and results' do
      allow(tnr).to receive(:stage) {{draw: 3, result: 2}}
      allow(tnr).to receive(:results).with(hash_including(stage: :draw)) {draw}
      allow(tnr).to receive(:results).with(hash_including(stage: :result)) {rank}
      expect(api).to receive(:send_message).exactly(5).times
      bot.post           
    end

    it 'updates tracker' do
      allow(tnr).to receive(:stage) {{draw: 0, result: 1}}
      allow(tnr).to receive(:results) {rank}
      expect(Tracker).to receive(:new).with(uid: 1, tnr: 2, snr: 3, draw: 0, result: 0)
      expect(tracker_instance).to receive(:update).with(result: 1)
      bot.post
    end

    it 'removes tracker' do
      allow_today(Date.parse('2020/01/09'))
      expect(tracker_instance).to receive(:delete)
      bot.post
    end
  end
end
