require 'sequel'

class Tracker
  # attr_reader :name, :surname, :fullname, :number, :club, :fed, :tournaments

  def initialize(options)
    options.each{ |key, value| instance_variable_set("@#{key}", value) }
    DB[:trackers].insert(options) if DB[:trackers][options].nil?
  end

  # def tracked_by?(uid)
  #   !DB[:trackers][uid: uid, pid: @number].nil?
  # end

  # def track_by(uid)
  #   DB[:trackers].insert(uid: uid, pid: @number)
  # end

  # def untrack_by(uid)
  #   DB[:trackers].where(uid: uid, pid: @number).delete
  # end

  # private

  # def list_tournaments(tournaments)
  #   text = ''

  #   tournaments.each do |tournament|
  #     template = Date.parse(tournament[:finish_date]) >= Date.today ? 
  #       STRINGS[:not_finished_tournament] : STRINGS[:finished_tournament]
  #     text << template % tournament
  #   end

  #   return text
  # end
end
