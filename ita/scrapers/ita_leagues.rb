#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

menus = Array.new

menus << ["league", '//*[@id="ctl00_ContentPlaceHolder1_drpLeague"]/option']

#[position()>1]']

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

url = "http://itarankings.itatennis.com/TeamSchedule.aspx"

page = agent.get(url)

menus.each do |menu|

  category = menu[0]
  search = menu[1]
    
  results = CSV.open("csv/ita_#{category}.csv","w")
  results << ["#{category}_id", "#{category}_name"]

  found = 0

  page.parser.xpath(search).each do |option|
    id = option.attributes["value"]
    name = option.inner_text.scrub.strip
    results << [id, name]
    found += 1
  end

  print "#{category} found #{found}\n"

  results.close

end
