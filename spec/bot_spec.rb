require 'bot'
require 'spec_helper'

describe Bot, :logger, :telegram do
  let(:bot) { Bot.new(token: 'test_token', log: 'path/to/log') }

  before(:example) do
    bot.instance_variable_set(:@telegram, telegram)
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

    # it 'sends messages about founded players' do
    #   allow(Web).to receive(:search_players) { players } # set players
    # end
  end
end
