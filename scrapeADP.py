#    Scrapes ESPN's average draft position (ADP) lists for the years 2012-2016
#    ADP within a football position is used to measure the average popular opinion
#    on the preseason ranking for a player.

#    Writes those ADP lists to csv files

from bs4 import BeautifulSoup
import posSort

years = ['2017']#['2012', '2013', '2014', '2015', '2016']

for year in years:
    infile = open(year+'live.html', 'r').read()
    soup = BeautifulSoup(infile, 'lxml')

    row_links = soup.find_all('a', content=True)
    meta_position_list = posSort.makeLists()
    for link in row_links:
        name = link.contents[0]
        pos = link.parent.parent.find_all('td')[2].contents[0]
        meta_position_list[posSort.checkPos(pos, 0)].append(name)

    outfile = open(year+'ranksadp.csv', 'w')
    for group in meta_position_list:
        for name in group:
            outfile.write(name+',\n') 
        outfile.write('\n')
    outfile.close()
