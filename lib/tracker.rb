require 'sequel'

class Tracker
  def initialize(options)
    options.each{ |key, value| instance_variable_set("@#{key}", value) }
    DB[:trackers].insert(options) if DB[:trackers][options].nil?
  end
end
