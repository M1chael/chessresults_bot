require 'telegram/bot'
require 'logger'
require 'date'
require_relative 'strings'
require_relative 'web'

class Bot
  include Web

  def initialize(options)
    @token = options[:token]
    @logger = Logger.new(options[:log], 'monthly')
  end

  def listen
    begin
      Telegram::Bot::Client.run(@token, logger: @logger) do |telegram|
        @telegram = telegram
        telegram.listen do |message|
          read(message)
        end
      end
    rescue => error
      @logger.fatal(error)
    end
  end

  def read(message)
    if message.respond_to?(:text)
      @uid = message.chat.id
      case message.text
      when '/start'
        send_message(text: STRINGS[:hello])
      when '/find'
        send_message(text: STRINGS[:search_player])
      else
        search_players(message.text)
      end
    end
  end

  private

  def send_message(options)
    options[:chat_id] = @uid
    options[:text] = options[:text]
    options[:parse_mode] = 'HTML'
    @telegram.api.send_message(options)
  end

  def search_players(data)
    player = {}
    player[:name], player[:surname] = data.strip.split(' ')
    if player[:name].nil? || player[:surname].nil?
      send_message(text: STRINGS[:error])
    else
      players = search_players_on_site(player)
      if players.size == 0
        send_message(text: STRINGS[:nobody] % player)
      else
        players.each do |player|
          player[:tournaments] = list_tournaments(player[:tournaments])
          send_message(text: STRINGS[:player] % player)
        end
      end
    end
  end

  def list_tournaments(tournaments)
    text = ''

    tournaments.each do |tournament|
      template = Date.parse(tournament[:finish_date]) >= Date.today ? 
        STRINGS[:not_finished_tournament] : STRINGS[:finished_tournament]
      text << template % tournament
    end

    return text
  end
end
