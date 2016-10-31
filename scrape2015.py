#    ESPN changed their website in 2015, and one of their analysts, so 
#    a new script was needed to scrape preseason rankings for 2015.  One 
#    particular change was combining the individual analyst rankings onto
#    the same page as the full staff rankings, so this script handles the 
#    individual analyst rankings and the staff ones

from bs4 import BeautifulSoup
import re

names = ['berry', 'cockroft', 'kara']

def posRanks(tableIn, cap):
    rows = tableIn.find_all('tr')[1:cap+1]
    ranks = []
    for row in rows:
        name = row.a.contents[0]
        ranks.append(name)
    return(ranks)

#    Writes preseason ranks for the individual analysts
for name in names:
    infile = open('2015'+name + '.html', 'r').read()
    soup = BeautifulSoup(infile, 'lxml')

    tables = soup.find_all(cellspacing = '0')
    qb_table = tables[2]
    qbs = posRanks(qb_table, 15)
    rb_table = tables[3]
    rbs = posRanks(rb_table, 40)
    wr_table = tables[4]
    wrs = posRanks(wr_table, 42)
    te_table = tables[5]
    tes = posRanks(te_table, 15)
    def_table = tables[6]
    dst = posRanks(def_table, 15)
    k_table = tables[7]
    ks = posRanks(k_table, 15)

    outfile = open('2015ranks'+name+'.csv', 'w')
    list_o_lists= [qbs, rbs, wrs, tes, dst, ks]
    for group in list_o_lists:
        for name in group:
            outfile.write(name + ',\n')
    outfile.close()

#    Handles ESPN's full staff rankings
infile = open('2015main.html', 'r').read()
soup = BeautifulSoup(infile,'lxml')

tables = soup.find_all(cellspacing = '0')
rank_table = tables[1]
rbs = []
qbs = []
wrs = []
tes = []
dst = []
ks = []
for row in rank_table.find_all('tr')[1:161]:
    name = row.a.contents[0]
    cols = row.find_all('td')
    rank = cols[-2].contents[0]
    print(rank)
    if rank[0] == 'K':
        ks.append(name)
    elif rank[0] == 'D':
        dst.append(name)
    elif rank[0] == 'Q':
        qbs.append(name)
    elif rank[0] == 'T':
        tes.append(name)
    elif rank[0] =='R':
        rbs.append(name)
    else:
        wrs.append(name)

outfile = open('2015ranksmain.csv', 'w')
list_o_lists =[qbs, rbs ,wrs, tes, dst, ks]
for group in list_o_lists:
    for name in group:
        outfile.write(name+',\n')
outfile.close()
