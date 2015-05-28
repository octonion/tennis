#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

menus = Array.new

conferences = CSV.open("csv/ita_conference.csv", "w")
conferences << ["league_id", "conference_id", "conference_name"]

teams = CSV.open("csv/ita_team.csv", "w")
teams << ["league_id", "team_id", "team_name"]

seasons = CSV.open("csv/ita_season.csv", "w")
seasons << ["league_id", "season_id", "season_name"]

menus << ["conference", '//*[@id="ctl00_ContentPlaceHolder1_drpConference"]/option', conferences]

menus << ["team", '//*[@id="ctl00_ContentPlaceHolder1_drpTeam"]/option', teams]

menus << ["season", '//*[@id="ctl00_ContentPlaceHolder1_drpSeason"]/option', seasons]

leagues = CSV.open("csv/ita_league.csv", "r", {:headers => TRUE})

url = "http://itarankings.itatennis.com/TeamSchedule.aspx"
page = agent.get(url)

form = page.forms[0]

leagues.each do |league|

  league_id = league["league_id"]
  league_name = league["league_name"]
  form["ctl00$ContentPlaceHolder1$drpLeague"] = league_id

  page = form.submit

  menus.each do |menu|

    category = menu[0]
    search = menu[1]
    file = menu[2]
    
    found = 0

    row = [league_id]
    page.parser.xpath(search).each do |option|
      id = option.attributes["value"]
      name = option.inner_text.scrub.strip
      file << row+[id, name]
      found += 1
    end

    print "#{league_name}/#{category} found #{found}\n"

  end

end

conferences.close
teams.close
seasons.close
