#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'csv'
require 'mechanize'

bad = " "

result_path = '//*[@id="overall"]/div[2]/table/tr[position()>1]'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_url = "http://itarankings.itatennis.com/TeamSchedule.aspx"

#page = agent.get(url)

#page_number = 0
total = 0

season_id = 10
year = 2010
teams = CSV.open("csv/ita_team.csv", "r", {:headers => TRUE})
results = CSV.open("csv/ita_team_results_#{year}.csv","w")
results << ["year", "season_id", "league_id", "team_id", "game_date", "opponent_string", "opponent_id", "opponent_url", "outcome", "score", "result_javascript"]

teams.each do |team|

  found = 0

  league_id = team["league_id"]
  team_id = team["team_id"]
  team_name = team["team_name"]

  url = base_url + "?did=#{league_id}&confid=0&teamid=#{team_id}&Seasonid=#{season_id}"

  page = agent.get(url)

  page.parser.xpath(result_path).each_with_index do |tr,i|

    row = [year, season_id, league_id, team_id]
    tr.xpath("td").each_with_index do |td,j|
      case j
      when 1
        text = td.inner_text.scrub.gsub(bad,"").strip rescue nil
        a = td.search("a").first
        href = a.attributes["href"].value.scrub.strip rescue nil
        opponent_id = href.split("&")[2].split("=")[1].scrub.strip rescue nil
        row += [text, opponent_id, href]
      when 3
        text = td.inner_text.scrub.gsub(bad,"").strip rescue nil
        a = td.search("a").first
        href = a.attributes["href"].value.scrub.strip rescue nil
        row += [text, href]
      else
        text = td.inner_text.scrub.gsub(bad,"").strip rescue nil
        row += [text]
      end
    end
    results << row
    found += 1
  end

  total += found
  print "#{team_name} found #{found}/#{total}\n"

  #next_exists = page.parser.xpath(next_path).first

  #if not(next_exists==nil)
  #  form = page.forms[0]
  #  form["ctl00$ContentPlaceHolder1$btnNext"] = "Next"
  #end

end
