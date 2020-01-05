require 'bot'
require 'spec_helper'

describe Bot, :logger, :telegram do
  let(:bot) { Bot.new(token: 'test_token', log: 'path/to/log') }
  let(:player1) { double }
  let(:player2) { double }
  let(:players) { [player1, player2] }

  before(:example) do
    bot.instance_variable_set(:@telegram, telegram)
    allow(player1).to receive(:to_hash).and_return(player1_hash)
    allow(player2).to receive(:to_hash).and_return(player2_hash)
    [player1, player2].each do |player| 
      allow(player).to receive(:tracked_by?).and_return(false)
      allow(player).to receive(:number).and_return(1)
      allow(player).to receive(:track_by)
      allow(player).to receive(:untrack_by)
    end
    allow(api).to receive(:edit_message_reply_markup)
  end

  describe '#read' do
    it 'says hello' do
      expect_reply('/start', STRINGS[:hello])
    end

    it 'asks player name and surname' do
      expect_reply('/find', STRINGS[:search_player])
    end

    it 'says about error when there is less than 2 words' do
      expect_reply('surname', STRINGS[:error])
    end

    it 'says player not found' do
      allow(bot).to receive(:search_players_on_site) { [] }
      expect_reply('no body', STRINGS[:nobody] % {name: 'no', surname: 'body'})
    end

    it 'sends 2 messages about 2 founded players' do
      allow(bot).to receive(:search_players_on_site) { players }
      allow(msg).to receive(:text) { 'some body' }
      expect(api).to receive(:send_message).twice
      bot.read(msg)
    end

    it 'adds add-button for not tracked users' do
      allow(bot).to receive(:search_players_on_site) { [player1] }
      allow(msg).to receive(:text) { 'some body' }
      expect(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
        with(text: 'Добавить в отслеживаемые', callback_data: 'add:1')
      bot.read(msg)
    end

    it 'adds del-button for tracked users' do
      allow(bot).to receive(:search_players_on_site) { [player1] }
      allow(player1).to receive(:tracked_by?).and_return(true)
      allow(msg).to receive(:text) { 'some body' }
      expect(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
        with(text: 'Удалить из отслеживаемых', callback_data: 'del:1')
      bot.read(msg)
    end

    it 'tracks player' do
      allow(msg).to receive(:data) { 'add:2' }
      allow(Player).to receive(:new).with(number: 2).and_return(player1)
      expect(player1).to receive(:track_by).with(1)
      bot.read(msg)
    end

    it 'untracks player' do
      allow(msg).to receive(:data) { 'del:2' }
      allow(Player).to receive(:new).with(number: 2).and_return(player2)
      expect(player2).to receive(:untrack_by).with(1)
      bot.read(msg)
    end

    it 'changes add-button to del-botton, when tracks player' do
      allow(msg).to receive(:data) { 'add:2' }
      allow(Player).to receive(:new).with(number: 2).and_return( player1 )
      allow(player1).to receive(:tracked_by?).and_return(true)
      allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
        with(text: 'Удалить из отслеживаемых', callback_data: 'del:1').and_return('del-button')
      allow(Telegram::Bot::Types::InlineKeyboardMarkup). to receive(:new).
        with(inline_keyboard: [['del-button']]).and_return('kb with del-button')
      expect(api).to receive(:edit_message_reply_markup).with(chat_id: 1, message_id: 10, 
        reply_markup: 'kb with del-button')
      bot.read(msg)
    end

    it 'changes del-button to add-botton, when untracks player' do
      allow(msg).to receive(:data) { 'del:2' }
      allow(Player).to receive(:new).with(number: 2).and_return( player1 )
      allow(player1).to receive(:tracked_by?).and_return(false)
      allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
        with(text: 'Добавить в отслеживаемые', callback_data: 'add:1').and_return('add-button')
      allow(Telegram::Bot::Types::InlineKeyboardMarkup). to receive(:new).
        with(inline_keyboard: [['add-button']]).and_return('kb with add-button')
      expect(api).to receive(:edit_message_reply_markup).with(chat_id: 1, message_id: 10, 
        reply_markup: 'kb with add-button')
      bot.read(msg)
    end
  end
end
