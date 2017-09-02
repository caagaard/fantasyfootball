#    Reads in 2016 league data for assumption validation and updating

#    The pages to be read can't be scraped online like this, because it requires
#    a username and password to login, which would be inappropriate to share.

import urllib.request
from bs4 import BeautifulSoup
import re

year = '2016'

#    Check to see if a tag has the necessary attributes to be a box score
def isBoxScore(tag):
    if tag.has_attr('href'):
        href = tag['href']
        if re.search('.+boxscore.+', href):
            return True
    else:
        return False

page = open(year+'.html', 'r').read()
soup = BeautifulSoup(page, 'lxml')

year_scores = []
games = soup.find_all(isBoxScore)
for game in games:
    score_string = game.contents[0]
    splindex = score_string.index('-')
    year_scores.append(score_string[0:splindex])
    year_scores.append(score_string[splindex+1:])

outfile = open(year+'out.csv', 'w')
outfile.write('Score, \n')
for score in year_scores:
    outfile.write(score + ', \n')
