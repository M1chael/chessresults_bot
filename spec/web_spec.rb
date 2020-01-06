require 'web'
require 'spec_helper'

describe Web do
  include Web

  let(:draw) { {date: '2019/10/12', time: '14:00',
    player: 'Митин Кирилл', color: :black, desk: 4, 
    opponent: 'Доля  Семен', rating: 1000} }

  describe '#list_players' do
    before(:example) do
      stub_web(:get, %r{\Ahttp://chess-results.com/tnr\d+.aspx\?art=3&zeilen=99999\z}, 'tnr478864.html')
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
      stub_web(:get, %r{\Ahttp://chess-results.com/tnr\d+.aspx\?art=14\z}, 'schedule.html')
    end

    it 'returns title and dates of tournament' do
      expect(tournament_info(478864)).to eq({title: 
        'Традиционный детский шахматный фестиваль "Русская Зима". Турнир D. Рейтинг 1120-1199', 
        start_date: '2020/01/05', finish_date: '2020/01/08'})
    end
  end

  describe '#tournament_state' do
    it 'returns current draw and results published rounds' do
      stub_web(:get, 'http://chess-results.com/tnr478864.aspx', 'after1day.html')
      expect(tournament_state(478864)).to eq({draw: 3, result: 2})
    end

    it 'returns zeros for not started tournament' do
      stub_web(:get, 'http://chess-results.com/tnr502281.aspx', 'tnr502281.html')
      expect(tournament_state(502281)).to eq({draw: 0, result: 0})
    end
  end

  describe '#get_draw' do
    it 'returns draw info by tournament, player and round' do
      stub_web(:get, 'http://chess-results.com/tnr478864.aspx?art=2&rd=1', 'tnr478864_rd1_pairs.html')
      expect(get_draw(tnr: 478864, snr: 4, rd: 1)).to eq(draw)
    end
  end
end
