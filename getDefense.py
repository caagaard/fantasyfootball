#    Because kickers and defense weren't listed on the main fantasy rankings
#    they need special treatment.

#    This script records the fantasy points scored by each defense each week
import urllib.request
from bs4 import BeautifulSoup
import re

years = ['2012', '2013', '2014', '2015']
weeks = list(range(18))

header = ['Name', 'team', 'opp', 'pos', 'snaps', 'fantasy_pts', 'year']
team = 'NA'
opp = 'NA'
snaps = 'NA'
pos = 'Def'

def findRow(tag):
    if tag.has_attr('href'):
        href = tag['href']
        if re.search('/stats/players.+', href):
            print(tag.contents)
            return True
    

for year in years:
    for week in weeks:
        outfile = open(year+'week'+str(week)+'Def.csv', 'w')
        for column in header[:-1]:
            outfile.write(column + ', ')
        outfile.write(header[-1] + '\n')
        url = 'http://www.fftoday.com/stats/playerstats.php?Season=' + (
               year) + '&GameWeek=' + str(week) + '&PosID=99&LeagueID=1'
        page = urllib.request.urlopen(url)
        soup = BeautifulSoup(page, 'lxml')

        for row in soup.find_all(findRow):
            root = row.parent.parent
            name = root.a.contents[0]
            cols = root.find_all('td')
            #team = cols[1].contents[0]
            fantasy_pts = cols[-2].contents[0]
            data = [name, team, opp, pos, snaps, fantasy_pts, year]
            #Write to output
            for datum in data[:-1]:
                outfile.write(datum +', ')
            outfile.write(data[-1] + '\n')
        outfile.close()
        
