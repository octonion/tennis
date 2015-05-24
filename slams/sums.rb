#!/usr/bin/env ruby
# coding: utf-8

require 'csv'
require 'mechanize'

require 'json'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

referer = "http://2015.ausopen.com/en_AU/scores/completed_matches/day6.html"

url = "http://2015.ausopen.com/en_AU/xml/gen/sumScores/sumScores_jsonp.json" #?callback=ssb_callback"

begin
  page = agent.get(url, :referer => referer)
rescue
  print "  -> error\n"
end

jsonp = page.body
data = JSON.parse(jsonp[/(\{.*\})/m])
p data

