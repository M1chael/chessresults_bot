require 'sequel'

class Player
  def initialize(options)
    options.each{ |key, value| instance_variable_set("@#{key}", value) }
  end

  def tracked_by?(uid)
    # require 'byebug'
    # byebug
    !DB[:trackers][uid: uid, pid: @number].nil?
  end
end
