require 'web'
require 'spec_helper'

describe Web do
  include Web

  describe '#search_players' do
    before(:example) do
      stub_web(:get, 'http://chess-results.com/spielersuche.aspx', 'search_form.html')
      stub_web(:post, 'http://chess-results.com/spielersuche.aspx', 'search_ivanov_ivan.html')
    end

    it 'returns array of 17 players' do
      expect(search_players(name: 'иван', surname: 'иванов').size).to eq(17)
    end
  end
end