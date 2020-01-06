require 'sequel'
require_relative 'web'

class Tracker
  include Web

  def initialize(options)
    DB[:trackers].insert(options.merge(tournament_state(options[:tid]))) if DB[:trackers][options].nil?
  end
end
