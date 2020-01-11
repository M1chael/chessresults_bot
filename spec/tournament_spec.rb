require 'tournament'
require 'spec_helper'

describe Tournament, :tracker do
  let(:tnr_id) { 1 }
  let(:tnr) { Tournament.new(tnr_id) }

  describe '#list_players_for_user' do
    it 'returns Web#list_players without already tracked' do
      uid = 1
      allow(tnr).to receive(:list_players).with(tnr_id) {players.dup}
      allow(Tracker).to receive(:list_trackers).
        with(uid: uid) {[uid: uid, tnr: 123, snr: 1, draw: 0, result: 0]}
      expect(tnr.list_players_for_user(uid)).to eq([players[1]])
    end
  end

  describe '#info' do
    it 'returns Web#tournament_info(tnr_id)' do
      allow(tnr).to receive(:tournament_info)
      expect(tnr).to receive(:tournament_info).with(tnr_id)
      tnr.info
    end
  end

  describe '#stage' do
    it 'returns Web#tournament_stage(tnr_id)' do
      allow(tnr).to receive(:tournament_stage)
      expect(tnr).to receive(:tournament_stage).with(tnr_id)
      tnr.stage
    end
  end

  describe '#results' do
    before(:example) do
      @options = {stage: :draw, snr: 2, rd: 1}
    end

    it 'returns Web#stage_info with sended options plus tnr_id' do
      allow(tnr).to receive(:stage_info)
      options = @options.dup
      options[:tnr] = tnr_id
      expect(tnr).to receive(:stage_info).with(options)
      tnr.results(@options)
    end

    it 'colors draw with white' do
      allow(tnr).to receive(:stage_info) {{color: :white}}
      expect(tnr.results(@options)[:color]).to eq('белыми')
    end

    it 'colors draw with black' do
      allow(tnr).to receive(:stage_info) {{color: :black}}
      expect(tnr.results(@options)[:color]).to eq('чёрными')
    end
  end
end
