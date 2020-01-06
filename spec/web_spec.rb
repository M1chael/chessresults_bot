require 'web'
require 'spec_helper'

describe Web do
  include Web

  # let(:player) { instance_double('Player', name: 'иван', surname: 'иванов') }

  describe '#list_players' do
    before(:example) do
      # stub_web(:get, 'http://chess-results.com/spielersuche.aspx', 'search_form.html')
      # stub_web(:post, 'http://chess-results.com/spielersuche.aspx', 'search_ivanov_ivan.html')
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
end
