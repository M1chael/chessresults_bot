require 'bot'
require 'spec_helper'

describe Bot, :logger, :telegram do
  before(:example) do
    @bot = Bot.new(token: 'test_token', log: 'path/to/log')
    @bot.instance_variable_set(:@telegram, telegram)
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
  end
end
