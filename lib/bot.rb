require 'telegram/bot'
require 'logger'
require_relative 'strings'
require_relative 'web'

class Bot
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
    # params = Hash.new
    options[:chat_id] = @uid
    options[:text] = options[:text]
    options[:parse_mode] = 'HTML'
    @telegram.api.send_message(options)
  end

  def search_players(player)
    name, surname = player.strip.split(' ')
    send_message(text: STRINGS[:error])
    # players = Web::search_players(name: name, surname: surname)
  end
end
