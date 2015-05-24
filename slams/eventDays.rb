#!/usr/bin/env ruby
# coding: utf-8

require 'csv'
require 'mechanize'
require 'json'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

file_name = ARGV[0]

dn = File.dirname(file_name)

data = JSON.parse(File.read(file_name))

data["eventDays"].each do |day|
  url = day["url"]

  # Hack for the 2014 French Open
  #url.gsub!("wwww","2014")

  # Hack for the 2014 US Open, Wimbledon
  #url.gsub!("www","2014")  

  p url
  
  page = agent.get(url).body
  j = JSON.parse(page)
  fn = url.split("/")[-1]
  File.write("#{dn}/#{fn}", j.to_json)
end

#begin
#  page = agent.get(url, :referer => referer)
#rescue
#  print "  -> error\n"
#end

#jsonp = page.body
#data = JSON.parse(jsonp[/(\{.*\})/m])
#p data

