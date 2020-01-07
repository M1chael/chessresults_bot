require 'telegram/bot'
require 'logger'
require 'date'
require_relative 'strings'
require_relative 'web'
require_relative 'tracker'

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
      if message.text == '/start'
        send_message(text: STRINGS[:hello]) 
      else
        tournament = message.text.to_i
        players = list_players(tournament)
        if players.size == 0
          send_message(text: STRINGS[:nothing_found])
        else
          send_message(text: STRINGS[:choose_player] % tournament_info(tournament), 
            reply_markup: markup(players))
        end
      end
      # case message.text
      # when '/start'
      #   send_message(text: STRINGS[:hello])
      # when '/find'
      #   send_message(text: STRINGS[:search_player])
      # else
      #   @telegram.api.send_chat_action(chat_id: @uid, action: :typing)
      #   search_players(message.text)
      # end
    elsif message.respond_to?(:data)
      @uid = message.from.id
      tnr, snr = message.data.split(':').map(&:to_i)
      Tracker.new(uid: @uid, tnr: tnr, snr: snr)
    #   player = Player.new(number: message.data.split(':')[1].to_i)
    #   action = message.data.split(':')[0].to_sym
    #   player_actions = {add: :track_by, del: :untrack_by}
    #   player.send(player_actions[action], @uid)
    #   edit_message(message_id: message.message.message_id, reply_markup: markup(player))
      @telegram.api.answer_callback_query(callback_query_id: message.id, 
        text: STRINGS[:player_added])
    end
  end

  def post
    # DB[:trackers].each do |tracker|
    #   stage = tournament_stage(tracker[:tid])
    #   stage.keys.each do |key|
    #     (tracker[key] + 1..stage[:key]).each do |st|
          
    #     end
    #   end
    # end
  end

  private

  def send_message(options)
    options[:chat_id] ||= @uid
    options[:parse_mode] = 'HTML'
    @telegram.api.send_message(options)
  end

  def markup(players)
    kb = []
    players.each do |player| 
      kb << [Telegram::Bot::Types::InlineKeyboardButton.new(text: player[:name],
        callback_data: player[:snr])]
    end
    return Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  end

  # def edit_message(options)
  #   options[:chat_id] = @uid
  #   @telegram.api.edit_message_reply_markup(options)
  # end

  # def search_players(data)
  #   player = {}
  #   player[:name], player[:surname] = data.strip.split(' ')
  #   if player[:name].nil? || player[:surname].nil?
  #     send_message(text: STRINGS[:error])
  #   else
  #     players = search_players_on_site(Player.new(player))
  #     if players.size == 0
  #       send_message(text: STRINGS[:nobody] % player)
  #     else
  #       players.each do |player|
  #         send_message(text: STRINGS[:player] % player.to_hash, reply_markup: markup(player))
  #       end
  #     end
  #   end
  # end

  # def markup(player)
  #   actions = {add: 'Добавить в отслеживаемые', del: 'Удалить из отслеживаемых'}
  #   action = player.tracked_by?(@uid) ? :del : :add
  #   kb = [[Telegram::Bot::Types::InlineKeyboardButton.new(text: actions[action], 
  #     callback_data: "#{action}:#{player.number}")]]

  #   return Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)    
  # end
end
