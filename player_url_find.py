#    The web page pro-football-reference.com has individual game data for all (or at least almost all)
#    nfl players.  For each pair (player, year), pro-football-reference.com has a page of the site 
#    with that data.
#
#    This script reads the yearly league-wide fantasy stats data from pro-football-reference, extracts
#    the top X players at each position for the year (X should be high enough to include all players used
#    in fantasy football), and writes the page with their weekly fantasy data to a file called '$year$.txt'

import urllib.request
from bs4 import BeautifulSoup

for year in['2012', '2013', '2014', '2015']:
    web_page = urllib.request.urlopen('http://www.pro-football-reference.com/years/' + year + '/fantasy.htm')
    soup = BeautifulSoup(web_page, 'lxml')

    #    Checks if each player is in the top $rank$ of players at their position
    #    If they are, they are added to the list of players for whom to record pages
    player_list = []
    for player in soup.find_all('td', {'data-stat' : 'fantasy_rank_pos'}):
        rank = int(player.contents[0])
        position = player.parent.find('td', {'data-stat' : 'fantasy_pos'}).contents
        if position == []:
            position = ['check']
        if position[0] == 'RB' or position[0] == 'WR':
            if rank < 100:
                row = player.parent
                name_link = row.find('td', {'data-stat' : 'player'})
                player_list.append(name_link.a['href'])
        else:
            if rank < 55:
                row = player.parent
                name_link = row.find('td', {'data-stat' : 'player'})
                player_list.append(name_link.a['href'])
    
    url_list = []
    for player in player_list:
        url = 'http://www.pro-football-reference.com'+player[:-4]+'/fantasy/'+year
        url_list.append(url)
    
    out_title = year+'out.txt'
    outfile = open(out_title, 'w')
    for url in url_list:
        outfile.write(url + '\n')
    outfile.close()
