#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

#path = '//*[@id="ctl00_ContentPlaceHolder1_grvSingle"]/tr[position()>1]'
match_path = '//tr[position()>1]'

next_path = '//*[@id="ctl00_ContentPlaceHolder1_btnNext"]'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

url = "http://itarankings.itatennis.com/LatestResults.aspx"
page = agent.get(url)

form = page.forms[0]

form["__EVENTTARGET"] = "ctl00$ContentPlaceHolder1$lnkSingle"
form["__EVENTARGUMENT"] = ""

page_number = 0
total = 0

year = 2015
gender = "men"
type = "singles"

results = CSV.open("csv/ita_#{gender}_#{type}.csv","w")

begin

  found = 0

  page_number += 1
  page = form.submit

  print "Page #{page_number}, "

  page.parser.xpath(match_path).each_with_index do |tr,i|
    row = [year, gender, type]
    tr.xpath("td").each do |td|
      row << td.inner_text.scrub.strip
    end
    results << row
    found += 1
  end
  total += found
  print "found #{found}/#{total}\n"

  next_exists = page.parser.xpath(next_path).first

  if not(next_exists==nil)
    form = page.forms[0]
    form["ctl00$ContentPlaceHolder1$btnNext"] = "Next"
  end

end while not(next_exists==nil)

=begin

schools.each do |school|

  school_id = school[0]
  school_name = school[1]

  form.searchOrg = school_id
  form.academicYear = "X"
  form.searchSport = sport_code
  form.searchDiv = "X"
  page = form.submit

  sp = "/html/body/form/table/tr/td[1]/table/tr/td/table/tr/td/a"
  show = page.search(sp)
  pulls = show.to_html.scan(/javascript:showNext/).length

  if (pulls>0)
    path = "/html/body/form/table/tr/td[2]/table/tr/td/table/tr"
  else
    path = "/html/body/form/table/tr/td/table/tr/td/table/tr"
  end

  (0..pulls).each do |pull|

    print "#{school_name} - #{pull}\n"

    if (pull>0)
      form = page.forms[2]
      form.orgId = school_id
      form.academicYear = "X"
      form.sportCode = sport_code
      form.division = "X"
      form.idx = pull
      form.doWhat = 'showIdx'
      page = form.submit
    end

    page.search(path).each_with_index do |row,i|

      if (i<=pulls)
        next
      end

      r = [sport_code,school_name,school_id]
      row.search("td").each_with_index do |td,j|
        if (j==0)
          h = td.search("a").first
          if (h==nil)
            r += [td.text.strip,nil,nil,nil]
        else
          o = h["href"]
          year = o.split(",")[1].strip
          div = o.split(",")[3].strip
          r += [td.text.strip,h["href"],year,div]
        end
      else
        r += [td.text.strip]
      end
    end
      stats << r
    end
    stats.flush
  end
end

stats.close
=end
