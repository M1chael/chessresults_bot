require 'player'
require 'spec_helper'

describe Player do
  describe '#add_tournament' do
    it 'add tournament' do
      player = Player.new(number: 1)
      player.add_tournament(name: 'name', finish_date: 'date')
      expect(player.tournaments[0]).to eq({name: 'name', finish_date: 'date'})
    end
  end

  describe '#to_hash' do
    it 'makes hash' do
      player = Player.new(fullname: 'fullname', number: 1, club: 'club', fed: 'fed')
      player.add_tournament(name: 'name', finish_date: '0000/01/01')
      expect(player.to_hash).to eq({fullname: 'fullname', number: 1, club: 'club', fed: 'fed',
        tournaments: "\n🏁 name — 0000/01/01"})
    end
  end

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
