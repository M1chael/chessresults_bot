require 'nokogiri'
require 'uri'
require 'net/http'
require 'open-uri'
require_relative 'player'

module Web
  def search_players_on_site(player)
    load_params
    get_players(player)
    return @players
  end

  def load_params
    @params = nil
    page = get_content(:Get, URI(CONFIG[:search_form][:URL]))
    @params = CONFIG[:search_form][:params]
    @params.each do |name, value| 
      @params[name] = page.xpath("//*[@id=\"#{name}\"]")[0]['value'] if @params[name].nil?
    end
  end

  def get_players(player)
    @players = []
    @params['_ctl0:P1:txt_vorname'] = player.name
    @params['_ctl0:P1:txt_nachname'] = player.surname
    get_content(:Post, URI(CONFIG[:search_form][:URL])).xpath('//*[@class="CRs2"]/tr').each do |tr|
      cells = tr.xpath('td')
      number = cells[1].text.to_i
      if number != 0
        @players << Player.new(fullname: cells[0].text, number: number, club: cells[3].text,
          fed: cells[4].text) if @players.none?{|player| player.number == number}
        tournament_id = cells[5].xpath('a/@href').text[/tnr(\d+)\..+/, 1]
        title = get_content(:Get, URI("http://chess-results.com/tnr#{tournament_id}.aspx")).
          xpath('//*/h2')[0].text
        start_date = get_content(:Get, URI("http://chess-results.com/tnr#{tournament_id}.aspx?art=14")).
          xpath('//*/table[@class="CRs1"]/tr[2]/td[2]').text.strip
        # require 'byebug'; byebug
        @players[@players.find_index{|player| player.number == number}].add_tournament(
          {title: title, start_date: start_date, finish_date: cells[6].text})
      end
    end
  end

  def get_content(http_method, uri)
    http = Net::HTTP.new(uri.host, 80)
    headers = CONFIG[:ua]
    headers['Cookie'] = @cookies if !@cookies.nil?
    req = Net::HTTP.const_get(http_method).new(uri, headers)
    req.set_form_data(@params) if http_method == :Post
    data = http.request(req)
    @cookies = data&.response['set-cookie']
    @cookies = @cookies.split('; ')[0] if !@cookies.nil?
    return Nokogiri::HTML(data.body)
  end
end
