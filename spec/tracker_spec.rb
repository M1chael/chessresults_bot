require 'tracker'
require 'spec_helper'

describe Tracker, :db do
  let(:tracker_options) { {uid: 1, tid: 1, snr: 1} }
  let!(:tracker) { Tracker.new(tracker_options) }

  describe '#new' do
    it 'sets new tracker' do
      expect(DB[:trackers][tracker_options]).not_to be_nil
    end
  end
end