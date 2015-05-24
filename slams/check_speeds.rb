#!/usr/bin/env ruby
# coding: utf-8

require 'json'

data = ARGV[0]

points = JSON.parse(File.read(data))
points.each do |point|
  p point["Speed_MPH"]
end

