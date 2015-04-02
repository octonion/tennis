#!/usr/bin/python

import csv
import lxml.html as lh

base = 'http://espn.go.com/tennis/matchSchedule?date=20130601&tournamentId=172'

# Date range - two weeks
first = [9,8,2012]
last = [9,22,2012]

path = '//*[contains(@id,"matchContainer")]/div/table'

results = csv.writer(file(r'tennis_espn.csv','wb'))

url = 'http://espn.go.com/tennis/matchSchedule?date=20130601&tournamentId=172'

#url = '%s/q/hp?s=%s&a=%i&b=%i&c=%i&d=%i&e=%i&f=%i&g=%s' % (base,stock,first[0],first[1],first[2],last[0],last[1],last[2],freq)

while True:
    try:
        page = lh.parse(url)
        break
    except:
        print "  -> error, retrying\n"
        continue

for table in page.xpath(path):
    for tr in table.xpath('tr'):
        r = []
        for td in tr.xpath('td/text() | td/a/text() | td/a/@href'):
            r += [td.encode('utf8').strip()]
        results.writerow(r)
