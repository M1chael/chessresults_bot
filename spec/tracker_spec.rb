require 'tracker'
require 'spec_helper'

describe Tracker, :db do
  before(:example) do
    allow_any_instance_of(Web).to receive(:tournament_stage).
      and_return({draw: 3, result: 2})
    @tracker = Tracker.new(tracker_options)
    @tracker.set
  end

  describe '#set' do
    it 'sets new tracker' do
      expect(DB[:trackers][tracker_options]).not_to be_nil
    end

    it 'prevents duplicates' do
      Tracker.new(tracker_options)
      expect(DB[:trackers].where(tracker_options).all.size).to eq(1)
    end

    it 'sets current draw and result' do
      expect(DB[:trackers][tracker_options][:draw]).to eq(3)
      expect(DB[:trackers][tracker_options][:result]).to eq(2)
    end
  end

  describe '#update' do
    it 'updates draw and result' do
      @tracker.update(draw: 5, result: 4)
      expect(DB[:trackers][tracker_options][:draw]).to eq(5)
      expect(DB[:trackers][tracker_options][:result]).to eq(4)
    end
  end
end
