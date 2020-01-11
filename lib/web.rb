require 'nokogiri'
require 'uri'
require 'net/http'
require 'open-uri'
require_relative 'strings'

module Web
  def list_players(tournament)
    players = []
    page = get_content(URI("http://chess-results.com/tnr#{tournament.to_i}.aspx?lan=11&art=3&zeilen=99999"))
    page.xpath('//*[@class="CRs1"]/tr/td[3]/a').each do |a|
      players << {snr: "#{tournament.to_i}:#{a.xpath('@href').text[/snr=(\d+)/, 1].to_i}", name: a.text}
    end
    return players
  end

  def tournament_info(tournament)
    result = {}
    xpath = {title: '(//h2)[1]', start_date: '//table[@class="CRs1"]/tr[2]/td[2]',
      start_time: '//table[@class="CRs1"]/tr[2]/td[3]',
      finish_date: '//table[@class="CRs1"]/tr[last()]/td[2]'}
    page = get_content(URI("http://chess-results.com/tnr#{tournament.to_i}.aspx?lan=11&art=14"))
    xpath.each{|key, value| result[key] = page.xpath(value).text.strip}
    return result
  end

  def tournament_stage(tournament)
    result = {draw: 0, result: 0}
    search = {draw: 'Пары по доскам', result: 'Положение после'}
    page = get_content(URI("http://chess-results.com/tnr#{tournament.to_i}.aspx?lan=11"))
    search.each do |field, str|
      page.xpath('//tr/td[normalize-space(text())="%s"]/../td[2]/a' % str).each do |a|
        val = a.text[/Тур(\d)+/, 1].to_i
        result[field] = val if val > result[field]
      end
    end
    return result
  end

  def tracker_info(options)
    result = {}
    page = get_content(URI(
      'http://chess-results.com/tnr%{tnr}.aspx?lan=11&art=9&snr=%{snr}' % options))
    result[:tournament] = page.xpath('(//h2)[1]').text.strip
    result[:name] = page.xpath('//table[@class="CRs1"][1]/tr[1]/td[2]').text.strip
    return result
  end

  def stage_info(options)
    options[:info] = {rd: options[:rd]}
    stage = options[:stage]
    options[:art] = stage == :draw ? 2 : 1
    options[:page] = get_content(URI('http://chess-results.com/tnr%{tnr}.aspx?lan=11&art=%{art}&rd=%{rd}' % options))
    options[:info][:tournament] = options[:page].xpath('(//h2)[1]').text.strip
    return stage == :draw ? get_draw(options) : get_rank(options)
  end

  def get_draw(options)
    info = options[:info]
    info.merge!(options[:page].xpath('//h3').text.match(/(?<date>\d+\/\d+\/\d+) в (?<time>\d+(:|\.)\d+)/).
      named_captures.transform_keys(&:to_sym))
    row_indexes = {white_snr: 2, black_snr: 12, snr: options[:snr].to_i}
    row = options[:page].xpath(STRINGS[:row] % row_indexes).collect(&:text)
    info[:desk] = row[0].to_i
    info[:color] = row[1].to_i == options[:snr].to_i ? :white : :black
    info[:player] = info[:color] == :white ? row[3].strip : row[9].strip
    info[:opponent] = info[:color] == :white ? row[9].strip : row[3].strip
    info[:rating] = info[:color] == :white ? row[10].to_i : row[4].to_i
    return info
  end

  def get_rank(options)
    info = options[:info]
    row = options[:page].xpath('//table[@class="CRs1"]/tr/td[2][normalize-space(text())=%d]/../td' % 
      options[:snr].to_i).collect(&:text)
    info[:player] = row[3].strip
    score_td = options[:page].xpath('count(//table[@class="CRs1"]/tr[1]/td[normalize-space(text())=
      "Очки"]/preceding-sibling::*)')
    info[:score] = row[score_td].strip
    info[:rank] = options[:page].xpath('count(//table[@class="CRs1"]/tr/td[2]
      [normalize-space(text())=%d]/../preceding-sibling::*)' % options[:snr].to_i).to_i
    return info
  end

  def get_content(uri)
    http = Net::HTTP.new(uri.host, 80)
    headers = CONFIG[:ua]
    req = Net::HTTP::Get.new(uri, headers)
    data = http.request(req)
    return Nokogiri::HTML(data.body)
  end
end
