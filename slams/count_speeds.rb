#!/usr/bin/env ruby
# coding: utf-8

require 'json'

matches = ARGV

count = 0
matches.each do |match|
  points = JSON.parse(File.read(match))
  points.each do |point|
    if (not(point["Speed_MPH"]==nil) and not(point["Speed_MPH"]==0))
      count += 1
    end
  end
  print "#{count}\n"
end
