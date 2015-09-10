#!/usr/bin/env ruby
# coding: utf-8

require 'csv'
require 'mechanize'
require 'json'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

#key_base = "http://2014.ausopen.com/en_AU/xml/gen/ps"
#pbp_base = "http://2014.ausopen.com/en_AU/xml/gen/ps"

#key_base = "http://2015.ausopen.com/en_AU/xml/gen/ps"
#pbp_base = "http://2015.ausopen.com/en_AU/xml/gen/ps"

#key_base = "http://2014.rolandgarros.com/en_FR/xml/gen/ps"
#pbp_base = "http://2014.rolandgarros.com/en_FR/xml/gen/ps"

#key_base = "http://2015.rolandgarros.com/en_FR/xml/gen/ps"
#pbp_base = "http://2015.rolandgarros.com/en_FR/xml/gen/ps"

#key_base = "http://2014.wimbledon.com/en_GB/xml/gen/ps"
#pbp_base = "http://2014.wimbledon.com/en_GB/xml/gen/ps"

#key_base = "http://2014.usopen.org/en_US/xml/gen/ps"
#pbp_base = "http://2014.usopen.org/en_US/xml/gen/ps"

key_base = "http://2015.usopen.org/en_US/xml/gen/ps"
pbp_base = "http://2015.usopen.org/en_US/xml/gen/ps"

days = ARGV

days.each do |day|

  day_name = day.split("/")[-1].split(".")[0].gsub("day","")
  
  dn = File.dirname(day)
  matches = JSON.parse(File.read(day))

  matches.each do |match|
  
    id = match["id"]
    crtId = match["crtId"]
  
    print "#{day_name} - #{id}/#{crtId} - "

    url = "#{key_base}/#{id}keys.json"
    #p url
    page = agent.get(url) rescue nil
    if not(page==nil)
      print "keys found - "
      j = JSON.parse(page.body)
      fn = "#{id}keys.json"
      File.write("#{dn}/#{fn}", j.to_json)
    else
      print "keys not found - "
    end

    url = "#{pbp_base}/#{id}C.json"
    #p url
    page = agent.get(url) rescue nil
    if not(page==nil)
      print "pbp found\n"
      j = JSON.parse(page.body)
      fn = "#{id}C.json"
      File.write("#{dn}/#{fn}", j.to_json)
    else
      print "pbp not found\n"
    end

  end

end

=begin
data["eventDays"].each do |day|
  url = day["url"]
  
  page = agent.get(url)
  j = JSON.parse(page.body)
  fn = url.split("/")[-1]
  File.write("#{dn}/#{fn}", j)
end
=end
