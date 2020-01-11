require 'sequel'
require_relative 'web'

class Tracker
  include Web

  def initialize(options)
    @options = options
  end

  def toggle
    if DB[:trackers][@options].nil?
      DB[:trackers].insert(@options.merge(tournament_stage(@options[:tnr])))
      return :tracker_added
    else
      delete
      return :tracker_deleted
    end
  end

  def update(options)
    DB[:trackers].where(@options).update(options)
    @options.update(options)
  end

  def delete
    DB[:trackers].where(@options).delete
  end

  def self.list_trackers(options={})
    DB[:trackers].where(options).all
  end
end
