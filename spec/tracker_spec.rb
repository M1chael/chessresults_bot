require 'tracker'
require 'spec_helper'

describe Tracker, :db do
  before(:example) do
    allow_any_instance_of(Web).to receive(:tournament_stage) {{draw: 3, result: 2}}
    @tracker = Tracker.new(tracker_options)
    @result = @tracker.toggle
  end

  describe '#toggle' do
    context 'when there is no tracker for the player' do
      it 'sets new tracker' do
        expect(DB[:trackers][tracker_options]).not_to be_nil
      end

      it 'returns :tracker_added' do
        expect(@result).to eq(:tracker_added)
      end

      it 'sets current draw and result' do
        expect(DB[:trackers][tracker_options][:draw]).to eq(3)
        expect(DB[:trackers][tracker_options][:result]).to eq(2)
      end
    end

    context 'when there is already setted tracker for the player' do
      before(:example) do
        @result = Tracker.new(tracker_options).toggle
      end

      it 'removes already setted tracker' do
        expect(DB[:trackers].where(tracker_options).all.size).to eq(0)
      end

      it 'returns :tracker_deleted' do
        expect(@result).to eq(:tracker_deleted)
      end
    end
  end

  describe '#update' do
    it 'updates draw and result' do
      @tracker.update(draw: 5, result: 4)
      expect(DB[:trackers][tracker_options][:draw]).to eq(5)
      expect(DB[:trackers][tracker_options][:result]).to eq(4)
    end

    it 'updates multiple times' do
      @tracker.update(draw: 5)
      @tracker.update(draw: 7)
      expect(DB[:trackers][tracker_options][:draw]).to eq(7)
    end
  end

  describe '#delete' do
    it 'deletes tracker' do
      @tracker.delete
      expect(DB[:trackers][tracker_options]).to be_nil
    end
  end

  describe '#list_trackers' do
    before(:example) do
      @tr_o = tracker_options.dup
      @tr_o[:draw] = 3
      @tr_o[:result] = 2
      @tracker = {uid: 2, tnr: 2, snr: 4, draw: 0, result: 0}
      DB[:trackers].insert(@tracker)
    end

    it 'lists all trackers' do
      expect(Tracker.list_trackers).to eq([@tr_o, @tracker])
    end

    it 'filters list of trackers by uid' do
      expect(Tracker.list_trackers(uid: 2)).to eq([@tracker])
    end
  end

  describe '#info' do
    it 'returns Web#tracker_info' do
      expect(@tracker).to receive(:tracker_info).with(tracker_options)
      @tracker.info
    end
  end
end
