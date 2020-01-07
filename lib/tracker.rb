require 'sequel'
require_relative 'web'

class Tracker
  include Web

  def initialize(options)
    @options = options
  end

  def set
    DB[:trackers].insert(@options.merge(tournament_stage(@options[:tnr]))) if DB[:trackers][@options].nil?
  end

  def update(options)
    DB[:trackers].where(@options).update(options)
    @options.update(options)
  end
end
