require 'web'
require 'spec_helper'

describe Web do
  include Web

  let(:player) { instance_double('Player', name: 'иван', surname: 'иванов') }

  describe '#search_players' do
    before(:example) do
      stub_web(:get, 'http://chess-results.com/spielersuche.aspx', 'search_form.html')
      stub_web(:post, 'http://chess-results.com/spielersuche.aspx', 'search_ivanov_ivan.html')
      stub_web(:get, %r{\Ahttp://chess-results.com/tnr\d+.aspx\z}, 'tnr478864.html')
      stub_web(:get, %r{\Ahttp://chess-results.com/tnr\d+.aspx\?art=14\z}, 'schedule.html')
    end

    it 'returns array of 17 players' do
      expect(search_players_on_site(player).size).to eq(17)
    end
  end
end
