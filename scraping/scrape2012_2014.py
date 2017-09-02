#    Scrapes preseason rankings from each of ESPN's 3 analyst ranking sets during the years
#    2012,2013,2014

#    For each analyst, writes their rankings to a csv file
from bs4 import BeautifulSoup

raters = ['berry', 'harris', 'kara']

for year in ['2012', '2013', '2014']:
    for rater in raters:
        text_name = year+rater +'.html'
        print(text_name)
        infile = open(text_name, 'r').read()
        soup = BeautifulSoup(infile, 'lxml')

        table = soup.find('tr', {'class' : 'last'}).parent
        ks = []
        dst = []
        qbs = []
        rbs = []
        tes = []
        wrs = []
        for row in table.find_all('tr', {'class' :'last'}):
            if row.find_all('a') != []:
                name = row.a.contents[0]
            else:
                name = row.find_all('td')[1].contents[0]
            if year == '2014':
                index = -2
            else:
                index = -1
            pos = row.find_all('td')[index].contents[0]
            if pos[1] == 'K':
                ks.append(name)
            elif pos[1] == 'D':
                dst.append(name)
            elif pos[1] == 'Q':
                qbs.append(name)
            elif pos[1] == 'R':
                rbs.append(name)
            elif pos[1] == 'T':
                tes.append(name)
            else:
                wrs.append(name)

        outfile = open(year + 'rank'+rater+'.csv', 'w')
        list_o_lists = [qbs, rbs, wrs, tes, dst, ks]
        for group in list_o_lists:
            for rank, name in enumerate(group):
                outfile.write(name + ', ' + str(rank + 1)+',\n')
        outfile.close()
