require 'telegram/bot'
require 'logger'
require_relative 'strings'

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
      end
    end
  end

  private

  def send_message(options)
    params = Hash.new
    params[:chat_id] = @uid
    params[:text] = options[:text]
    params[:parse_mode] = 'HTML'
    @telegram.api.send_message(params)
  end
end
