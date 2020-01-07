require 'bot'
require 'spec_helper'

describe Bot, :logger, :telegram, :db do
  let(:bot) { Bot.new(token: 'test_token', log: 'path/to/log') }
#   let(:player1) { double }
#   let(:player2) { double }
#   let(:players) { [player1, player2] }

  before(:example) do
    bot.instance_variable_set(:@telegram, telegram)
    allow(bot).to receive(:list_players).and_return(players)
    allow(bot).to receive(:tournament_info).and_return(tournament)
#     allow(player1).to receive(:to_hash).and_return(player1_hash)
#     allow(player2).to receive(:to_hash).and_return(player2_hash)
#     [player1, player2].each do |player| 
#       allow(player).to receive(:tracked_by?).and_return(false)
#       allow(player).to receive(:number).and_return(1)
#       allow(player).to receive(:track_by)
#       allow(player).to receive(:untrack_by)
#     end
#     allow(api).to receive(:edit_message_reply_markup)
  end

  describe '#read' do
    it 'says hello' do
      expect_reply('/start', text: STRINGS[:hello])
    end

    it 'says nothing found message' do
      allow(bot).to receive(:list_players).and_return([])
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
        allow(Tracker).to receive(:new)
      end

      it 'tracks player' do
        expect(Tracker).to receive(:new).with(tracker_options)
        bot.read(msg)
      end

      it 'shows notification about player tracking' do
        expect(api).to receive(:answer_callback_query).with(callback_query_id: 10,
          text: STRINGS[:player_added])
        bot.read(msg)        
      end
    end

#     it 'asks player name and surname' do
#       expect_reply('/find', STRINGS[:search_player])
#     end

#     it 'says about error when there is less than 2 words' do
#       expect_reply('surname', STRINGS[:error])
#     end

#     it 'says player not found' do
#       allow(bot).to receive(:search_players_on_site) { [] }
#       expect_reply('no body', STRINGS[:nobody] % {name: 'no', surname: 'body'})
#     end

#     it 'sends 2 messages about 2 founded players' do
#       allow(bot).to receive(:search_players_on_site) { players }
#       allow(msg).to receive(:text) { 'some body' }
#       expect(api).to receive(:send_message).twice
#       bot.read(msg)
#     end

#     it 'adds add-button for not tracked users' do
#       allow(bot).to receive(:search_players_on_site) { [player1] }
#       allow(msg).to receive(:text) { 'some body' }
#       expect(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
#         with(text: 'Добавить в отслеживаемые', callback_data: 'add:1')
#       bot.read(msg)
#     end

#     it 'adds del-button for tracked users' do
#       allow(bot).to receive(:search_players_on_site) { [player1] }
#       allow(player1).to receive(:tracked_by?).and_return(true)
#       allow(msg).to receive(:text) { 'some body' }
#       expect(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
#         with(text: 'Удалить из отслеживаемых', callback_data: 'del:1')
#       bot.read(msg)
#     end

#     context 'when add-buton pressed' do
#       before(:example) do
#         allow(msg).to receive(:data) { 'add:2' }
#         allow(Player).to receive(:new).with(number: 2).and_return(player1)
#       end

#       it 'tracks player' do
#         expect(player1).to receive(:track_by).with(1)
#         bot.read(msg)
#       end

#       it 'changes add-button to del-botton' do
#         allow(player1).to receive(:tracked_by?).and_return(true)
#         allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
#           with(text: 'Удалить из отслеживаемых', callback_data: 'del:1').and_return('del-button')
#         allow(Telegram::Bot::Types::InlineKeyboardMarkup). to receive(:new).
#           with(inline_keyboard: [['del-button']]).and_return('kb with del-button')
#         expect(api).to receive(:edit_message_reply_markup).with(chat_id: 1, message_id: 10, 
#           reply_markup: 'kb with del-button')
#         bot.read(msg)
#       end

#       it 'shows notification about player tracking' do
#         expect(api).to receive(:answer_callback_query).with(callback_query_id: 10,
#           text: STRINGS[:callback_response][:add])
#         bot.read(msg)        
#       end
#     end

#     context 'when del-buton pressed' do
#       before(:example) do
#         allow(msg).to receive(:data) { 'del:2' }
#         allow(Player).to receive(:new).with(number: 2).and_return(player1)
#       end

#       it 'untracks player' do
#         expect(player1).to receive(:untrack_by).with(1)
#         bot.read(msg)
#       end

#       it 'changes del-button to add-botton' do
#         allow(player1).to receive(:tracked_by?).and_return(false)
#         allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
#           with(text: 'Добавить в отслеживаемые', callback_data: 'add:1').and_return('add-button')
#         allow(Telegram::Bot::Types::InlineKeyboardMarkup). to receive(:new).
#           with(inline_keyboard: [['add-button']]).and_return('kb with add-button')
#         expect(api).to receive(:edit_message_reply_markup).with(chat_id: 1, message_id: 10, 
#           reply_markup: 'kb with add-button')
#         bot.read(msg)
#       end

#       it 'shows notification about player untracking' do
#         expect(api).to receive(:answer_callback_query).with(callback_query_id: 10,
#           text: STRINGS[:callback_response][:del])
#         bot.read(msg)        
#       end
#     end
  end

  describe '#post' do
    let(:information) { draw.dup }
      
    before(:example) do
      DB[:trackers].insert(uid: 1, tnr: 2, snr: 3, draw: 0, result: 0)
      allow(bot).to receive(:stage_info)
      information[:color] = 'белыми'
    end
    # it 'sends text to uid' do
    #   options = {chat_id: 1, text: 'text', parse_mode: 'HTML'}
    #   expect(api).to receive(:send_message).with(options)
    #   bot.post(chat_id: 1, text: 'text')
    # end
    # it 'sends message about starting tournament less than 24 hours' do
    #   allow_now(DateTime.parse('2020/01/04 14:05'))
    #   expect(api).to receive(:send_message).with(reply)
    # end
    it 'sends message about draw' do
      allow(bot).to receive(:tournament_stage).with(2).and_return(draw: 1, result: 0)
      allow(bot).to receive(:stage_info).with(stage: :draw, tnr: 2, snr: 3, rd: 1).
        and_return(draw)
      expect(api).to receive(:send_message).with(chat_id: 1, :parse_mode=>"HTML", 
        text: STRINGS[:draw] % information)
      bot.post
    end

    it 'sends message about result' do
      allow(bot).to receive(:tournament_stage).with(2).and_return(draw: 1, result: 1)
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
  end
end
