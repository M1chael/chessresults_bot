require 'player'
require 'spec_helper'

describe Player, :db do
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
      tournament = {title: 'title', start_date: '0000/01/01', finish_date: '0000/01/05'}
      player.add_tournament(tournament)
      expect(player.to_hash).to eq({fullname: 'fullname', number: 1, club: 'club', fed: 'fed',
        tournaments: STRINGS[:finished_tournament] % tournament})
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

  describe '#track_by' do
    it 'sets tracker' do
      player = Player.new(number: 1)
      player.track_by(2)
      expect(player.tracked_by?(2)).to be true
    end
  end

  describe '#untrack_by' do
    it 'removes tracker' do
      player = Player.new(number: 1)
      DB[:trackers].insert(uid: 2, pid: 1)
      player.untrack_by(2)
      expect(player.tracked_by?(2)).to be false
    end
  end
end
