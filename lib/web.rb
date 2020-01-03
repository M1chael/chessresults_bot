require 'nokogiri'
require 'uri'
require 'net/http'
require 'open-uri'

module Web
  def search_players(player)
    load_params
    get_players(player)
    return @players
  end

  def load_params
    @params = nil
    get_content(:Get, URI(CONFIG[:search_form][:URL]))
    @params = CONFIG[:search_form][:params]
    @params.each do |name, value| 
      @params[name] = @page.xpath("//*[@id=\"#{name}\"]")[0]['value'] if @params[name].nil?
    end
  end

  def get_players(player)
    @players = []
    @params['_ctl0:P1:txt_vorname'] = player[:name]
    @params['_ctl0:P1:txt_nachname'] = player[:surname]
    get_content(:Post, URI(CONFIG[:search_form][:URL])).xpath('//*[@class="CRs2"]/tr').each do |tr|
      cells = tr.xpath('td')
      number = cells[1].text.to_i
      if number != 0
        if @players.none?{|player| player[:number] == number}
          @players << {name: cells[0].text, number: number, club: cells[3].text, 
            fed: cells[4].text, tournaments: [{name: cells[5].text, finish_date: cells[6].text}]}
        else
          @players[@players.find_index{|player| player[:number] == number}][:tournaments] << 
            {name: cells[5].text, finish_date: cells[6].text}
        end
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
    @page = Nokogiri::HTML(data.body)
  end
end
