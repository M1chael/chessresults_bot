require 'bot'
require 'spec_helper'

describe Bot, :logger, :telegram do
  before(:example) do
    @bot = Bot.new(token: 'test_token', log: 'path/to/log')
    @bot.instance_variable_set(:@telegram, telegram)
  end

  describe '#read' do
    it 'says hello' do 
      allow(msg).to receive(:text) { '/start' }
      expect(api).to receive(:send_message).with(chat_id: chat.id, text: STRINGS[:hello], 
        parse_mode: 'HTML')
      @bot.read(msg)
    end

    it 'asks player name and surname' do
      allow(msg).to receive(:text) { '/find' }
      expect(api).to receive(:send_message).with(chat_id: chat.id, text: STRINGS[:search_player], 
        parse_mode: 'HTML')
      @bot.read(msg)      
    end
  end
end
