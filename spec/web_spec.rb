require 'web'
require 'spec_helper'

describe Web do
  include Web

  describe '#list_players' do
    before(:example) do
      stub_web(:get, %r{\Ahttp://chess-results.com/tnr\d+.aspx\?art=3&lan=11&zeilen=99999\z}, 'tnr478864.html')
    end

    it 'returns list of all players by tournament id' do
      expect(list_players(478864).size).to eq(52)
    end

    it 'returns players with tournament numbers and names' do
      list_players(478864).each{|player| expect(player.keys).to include(:snr, :name)}
    end
  end

  describe '#tournament_info' do
    before(:example) do
      stub_web(:get, %r{\Ahttp://chess-results.com/tnr\d+.aspx\?art=14&lan=11\z}, 'schedule.html')
    end

    it 'returns title and dates of tournament' do
      expect(tournament_info(478864)).to eq({title: 
        'Традиционный детский шахматный фестиваль "Русская Зима". Турнир D. Рейтинг 1120-1199', 
        start_date: '2020/01/05', start_time: '14:00', finish_date: '2020/01/08'})
    end
  end

  describe '#tournament_stage' do
    it 'returns current draw and results published rounds' do
      stub_web(:get, 'http://chess-results.com/tnr478864.aspx?lan=11', 'after1day.html')
      expect(tournament_stage(478864)).to eq({draw: 3, result: 2})
    end

    it 'returns zeros for not started tournament' do
      stub_web(:get, 'http://chess-results.com/tnr502281.aspx?lan=11&', 'tnr502281.html')
      expect(tournament_stage(502281)).to eq({draw: 0, result: 0})
    end
  end

  describe '#stage_info' do
    it 'returns draw info by tournament, player and round' do
      stub_web(:get, 'http://chess-results.com/tnr502281.aspx?lan=11&art=2&rd=1', 'tnr502281_rd5_draw.html')
      expect(stage_info(stage: :draw, tnr: 502281, snr: 4, rd: 1)).to eq(draw)
    end

   it 'returns rank by tournament, player and round' do
      stub_web(:get, 'http://chess-results.com/tnr478864.aspx?lan=11&art=1&rd=1', 'tnr478864_rd1_results.html')
      expect(stage_info(stage: :result, tnr: 478864, snr: 11, rd: 1)).to eq(rank)
    end   
  end

  # describe '#get_draw' do
  #   it 'returns draw info by tournament, player and round' do
  #     stub_web(:get, 'http://chess-results.com/tnr502281.aspx?art=2&rd=1', 'tnr502281_rd5_draw.html')
  #     expect(get_draw(tnr: 502281, snr: 4, rd: 1)).to eq(draw)
  #   end
  # end

  # describe '#get_rank' do
  #   it 'returns result by tournament, player and round' do
  #     stub_web(:get, 'http://chess-results.com/tnr478864.aspx?art=1&rd=1', 'tnr478864_rd1_results.html')
  #     expect(get_rank(tnr: 478864, snr: 11, rd: 1)).to eq(rank)
  #   end
  # end
end
