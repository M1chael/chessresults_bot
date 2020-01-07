require 'sequel'
require_relative 'web'

class Tracker
  include Web

  def initialize(options)
    DB[:trackers].insert(options.merge(tournament_stage(options[:tnr]))) if DB[:trackers][options].nil?
  end
end
