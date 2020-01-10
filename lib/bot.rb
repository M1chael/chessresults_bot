require 'telegram/bot'
require 'logger'
require 'date'
require_relative 'strings'
require_relative 'web'
require_relative 'tracker'

class Bot
  include Web

  def initialize(options)
    options.each{ |key, value| instance_variable_set("@#{key}", value) }
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
      elsif message.text == '/list'
        trackers = DB[:trackers].where(uid: @uid).all
        if trackers.size == 0
          send_message(text: STRINGS[:notrackers])
        else
          trackers.each do |tracker|
            send_message(text: STRINGS[:tracker] % tracker_info(tracker), 
              reply_markup: markup(tracker: tracker))
          end
        end
      else
        tournament = message.text.to_i
        players = list_players(tournament)
        info = tournament_info(tournament)
        if players.size == 0 || info[:finish_date] == 'unknown'
          send_message(text: STRINGS[:nothing_found])
        else
          send_message(text: STRINGS[:choose_player] % info, 
            reply_markup: markup(players: players))
        end
      end
    elsif message.respond_to?(:data)
      @uid = message.from.id
      tnr, snr = message.data.split(':').map(&:to_i)
      tracker = Tracker.new(uid: @uid, tnr: tnr, snr: snr)
      result = tracker.toggle
      @telegram.api.answer_callback_query(callback_query_id: message.id, 
        text: STRINGS[result])
      if result == :player_added
        markup = message.reply_markup.to_h
        markup[:delete] = message.data
        @telegram.api.edit_message_reply_markup(chat_id: @uid, message_id: message.id,
          reply_markup: markup(markup))
      else
        @telegram.api.delete_message(chat_id: @uid, message_id: message.id)
      end
    end
  end

  def post
    begin
      Telegram::Bot::Client.run(@token, logger: @logger) do |telegram|
        @telegram = telegram
        DB[:trackers].each do |tracker|
          upd_tracker = Tracker.new(tracker)
          finish_date = Date.parse(tournament_info(tracker[:tnr])[:finish_date])
          if Date.today > finish_date
            upd_tracker.delete
          else
            stage = tournament_stage(tracker[:tnr])
            stage.keys.each do |stage_name|
              (tracker[stage_name] + 1..stage[stage_name]).each do |rd|
                info = stage_info(stage: stage_name, tnr: tracker[:tnr], snr: tracker[:snr], rd: rd)
                if !info.nil?
                  send_message(chat_id: tracker[:uid], 
                    text: STRINGS[stage_name] % color(info))
                  upd_tracker.update(:"#{stage_name}"=>rd)
                end
              end
            end
          end
        end
      end
    rescue => error
      @logger.fatal(error)
    end
  end

  private

  def send_message(options)
    options[:chat_id] ||= @uid
    options[:parse_mode] = 'HTML'
    @telegram.api.send_message(options)
  end

  def markup(options)
    kb = []

    if !options[:players].nil?
      options[:players].each do |player| 
        kb << [get_button(text: player[:name], callback_data: player[:snr])]
      end
    elsif !options[:tracker].nil?
      kb << [get_button(text: 'Удалить', callback_data: '%{tnr}:%{snr}' % options[:tracker])]
    else
      options[:inline_keyboard].each do |row|
        new_row = []
        row.each do |button|
          new_row << get_button(button) if button[:callback_data] != options[:delete]
        end
        kb << new_row if new_row.size > 0
      end
    end
    return Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  end

  def get_button(options)
    Telegram::Bot::Types::InlineKeyboardButton.new(options)
  end

  def color(info)
    if !info[:color].nil?
      colors = {white: 'белыми', black: 'чёрными'}
      info[:color] = colors[info[:color]]
    end
    return info
  end
end
