require 'telegram/bot'
require 'logger'
require 'date'
require_relative 'strings'
require_relative 'web'
require_relative 'player'

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
    @uid = message.chat.id
    if message.respond_to?(:text)
      case message.text
      when '/start'
        send_message(text: STRINGS[:hello])
      when '/find'
        send_message(text: STRINGS[:search_player])
      else
        @telegram.api.send_chat_action(chat_id: @uid, action: :typing)
        search_players(message.text)
      end
    elsif message.respond_to?(:data)
      player = Player.new(number: message.data.split(':')[1].to_i)
      case message.data.split(':')[0]
      when 'add'
        player.track_by(@uid)
      when 'del'
        player.untrack_by(@uid)
      end
    end
  end

  private

  def send_message(options)
    options[:chat_id] = @uid
    options[:parse_mode] = 'HTML'
    @telegram.api.send_message(options)
  end

  def search_players(data)
    player = {}
    player[:name], player[:surname] = data.strip.split(' ')
    if player[:name].nil? || player[:surname].nil?
      send_message(text: STRINGS[:error])
    else
      players = search_players_on_site(Player.new(player))
      if players.size == 0
        send_message(text: STRINGS[:nobody] % player)
      else
        players.each do |player|
          send_message(text: STRINGS[:player] % player.to_hash, reply_markup: markup(player))
        end
      end
    end
  end

  def markup(player)
    actions = {add: 'Добавить в отслеживаемые', del: 'Удалить из отслеживаемых'}
    action = player.tracked_by?(@uid) ? :del : :add
    kb = [[Telegram::Bot::Types::InlineKeyboardButton.new(text: actions[action], 
      callback_data: "#{action}:#{player.number}")]]

    return Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)    
  end
end
