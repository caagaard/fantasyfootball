#    Takes the output lists from player_url_find.py as input
#    For each (player, year) pair with a page in that list, writes their weekly game data
#    to a text file.

import urllib.request
from bs4 import BeautifulSoup

for year in ['2016']:#'2012', '2013' ,'2014', '2015', '2016']:
    year_url_list = open(year+'out.txt', 'r').readlines()

    for player in year_url_list:
        web_page = urllib.request.urlopen(player)
        soup = BeautifulSoup(web_page, 'lxml')
    
        name = soup.find('h1', {'itemprop' : 'name'}).contents[0]
        stat_table = soup.find('table', {'class' : 'sortable stats_table'}).find('tbody')
        print(name)
        games = stat_table.find_all('td', {'data-stat' : 'game_num'})
        out_title = year + name +'.txt'
        outfile = open(out_title, 'w')
        outfile.write('Name, team, opp, pos, snaps, fantasy_pts \n')
        for game in games:
            full_game = game.parent
            if len(full_game.find('td', {'data-stat' :'team'}).find('a').contents) !=0:
                player_data = [name]
                fantasy_points = full_game.find('td', {'data-stat':'fantasy_points'}).contents
                # Sometimes when a player scored 0 points, no data was recoded here.
                # Assigning fantasy_points = [0] makes sure something can be added to player_data
                if (len(fantasy_points) == 0):
                    fantasy_points = [0]
                player_data.append(full_game.find('td', {'data-stat':'team'}).find('a').contents[0])
                player_data.append(full_game.find('td', {'data-stat' : 'opp'}).find('a').contents[0])
                position = full_game.find('td', {'data-stat' :'starter_pos'}).contents
                if (len(position) == 0):
                    position = ['NA']
                player_data.append(position[0])
                snap_count = full_game.find('td', {'data-stat' : 'offense'}).contents
                if len(snap_count) == 0:
                    snap_count = ['NA']
                player_data.append(snap_count[0])
                player_data.append(fantasy_points[0])
                # Now we write the weeks's info to output
                for stat in player_data:
                    outfile.write(str(stat) + ', ')
                outfile.write('\n')
        outfile.close()

