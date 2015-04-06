#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'csv'
require 'mechanize'

bad = " "

#result_path = '//*[@id="overall"]/div[2]/table/tr[position()>1]'
result_path = '//*[@id="overall"]/div[3]/table/tr[position()>1]'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_url = "http://itarankings.itatennis.com/TeamSchedule.aspx"

year = 2015
results = CSV.open("csv/ita_team_results_#{year}.csv", "r",
                   {:headers => TRUE})

singles = CSV.open("csv/ita_team_singles_#{year}.csv", "w")
doubles = CSV.open("csv/ita_team_doubles_#{year}.csv", "w")

#results << ["year", "season_id", "league_id", "team_id", "game_date", "opponent_string", "opponent_id", "opponent_url", "outcome", "score", "result_javascript"]

results.each do |result|

  season_id = result["season_id"]
  league_id = result["league_id"]
  pull_team_id = result["team_id"]
  game_date = result["game_date"]
  pull_opponent_id = result["opponent_id"]

#  if not(pull_team_id=="230")
#    next
#  end

  url = base_url+"?did=#{league_id}&confid=0&teamid=#{pull_team_id}&Seasonid=#{season_id}"


  begin
    page = agent.get(url)
  rescue
    sleep 3
    print "retrying get ...\n"
    retry
  end

  form = page.forms[0]

  js = result["result_javascript"]

  target = js.split("\'")[1] rescue nil
  if (target==nil)
    next
  end

  form['__EVENTTARGET'] = target
  form['__EVENTARGUMENT'] = ""

  begin
    page = form.submit
  rescue
    sleep 3

    begin
      page = agent.get(url)
    rescue
      sleep 3
      print "retrying get ...\n"
      retry
    end

    form = page.forms[0]

    print "retrying submit ...\n"
    retry
  end

  sheet_url = page.uri.to_s

  values = sheet_url.split("&")
  scse_id = values[0].split("=")[1].scrub.strip rescue nil
  page_id = values[1].split("=")[1].scrub.strip rescue nil

  found_singles = 0
  found_doubles = 0
  page.parser.xpath(result_path).each_with_index do |tr,i|

    type = nil
    row = [scse_id, page_id, sheet_url]
    tr.xpath("td").each_with_index do |td,j|
      case j
      when 0
        text = td.inner_text.scrub.gsub(bad," ").strip rescue nil
        values = text.split(" ")
        rank = values[0].gsub("#","")
        type = values[1].downcase
        row += [rank,type]
      when 1,2
        full_text = td.text.scrub.gsub(bad," ").strip rescue nil
        if not(full_text==nil) and (full_text.include?("#"))
          rank = full_text.split(" ")[0].gsub("#","")
        else
          rank = nil
        end
        td.search("a").each do |a|
          text = a.inner_text.scrub.gsub(bad,"").strip rescue nil
          href = a.attributes["href"].value.scrub.strip rescue nil
          values = href.split("&")
          div_id = values[0].split("=")[1].scrub.strip rescue nil
          conf_id = values[1].split("=")[1].scrub.strip rescue nil
          team_id = values[2].split("=")[1].scrub.strip rescue nil
          player_id = values[3].split("=")[1].scrub.strip rescue nil
          type_id = values[4].split("=")[1].scrub.strip rescue nil
          row += [rank, text, div_id, conf_id, team_id, player_id,
                  type_id, href]
        end
      else
        text = td.inner_text.scrub.gsub(bad,"").strip rescue nil
        row += [text]
      end
    end
    if (type=='singles')
      found_singles += 1
      singles << row
    else
      found_doubles += 1
      doubles << row
    end

  end
  print "#{pull_team_id}/#{pull_opponent_id} - #{game_date}: singles - #{found_singles}, doubles - #{found_doubles}\n"

end
