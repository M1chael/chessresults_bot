require 'web'
require_relative 'tracker'

class Tournament
  include Web

  def initialize(id)
    @id = id
  end

  def list_players_for_user(uid)
    players = list_players(@id).
      delete_if do |player| 
        Tracker.list_trackers(uid: uid).any? do |tracker| 
          "#{tracker[:tnr]}:#{tracker[:snr]}" == player[:snr]
        end
      end
    return players
  end

  def info
    return tournament_info(@id)
  end

  def stage
    return tournament_stage(@id)
  end

  def results(options)
    options[:tnr] = @id
    return color(stage_info(options))
  end

  private

  def color(info)
    if !info.nil?
      if !info[:color].nil?
        colors = {white: 'белыми', black: 'чёрными'}
        info[:color] = colors[info[:color]]
      end
    end
    return info
  end
end
