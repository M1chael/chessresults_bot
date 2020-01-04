require 'player'
require 'spec_helper'

describe Player do
  describe '#tracked_by?' do
    it 'is false, when player is not tracked by user' do
      DB[:trackers].insert(uid: 1, pid: 2)
      player = Player.new(number: 2)
      expect(player.tracked_by?(2)).to be false
    end

    it 'is true, when player is tracked by user' do
      DB[:trackers].insert(uid: 1, pid: 2)
      player = Player.new(number: 2)
      expect(player.tracked_by?(1)).to be true
    end
  end
end
