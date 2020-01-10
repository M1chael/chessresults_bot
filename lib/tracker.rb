require 'sequel'
require_relative 'web'

class Tracker
  include Web

  def initialize(options)
    @options = options
  end

  def toggle
    DB[:trackers][@options].nil? ? 
      DB[:trackers].insert(@options.merge(tournament_stage(@options[:tnr]))) :
      delete
  end

  def update(options)
    DB[:trackers].where(@options).update(options)
    @options.update(options)
  end

  def delete
    DB[:trackers].where(@options).delete
  end
end
