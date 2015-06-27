#!/usr/bin/env ruby
# coding: utf-8

require 'csv'
require 'mechanize'
require 'json'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

year = 2015

tn = "wimbledon"

#url = "http://2015.rolandgarros.com/en_FR/xml/gen/apps/cmatch/eventDays.json"
url = "http://www.wimbledon.com/en_GB/xml/gen/apps/cmatch/eventDays.json"

page = agent.get(url).body
j = JSON.parse(page)
fn = url.split("/")[-1]

file_name = "#{tn}/#{year}/#{fn}"
p file_name

File.write("#{tn}/#{year}/#{fn}", j.to_json)
