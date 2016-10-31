#    Scrapes ESPN's 2012-2014 staff preseason rankings

#    Wrties the rankings for each year to a csv file

from bs4 import BeautifulSoup

for year in ['2012', '2013', '2014']:
    infile = open(year +'main.html', 'r').read()
    soup = BeautifulSoup(infile, 'lxml')

    rows = soup.find_all('tr', {'class' : 'last'})
    qbs = []
    rbs = []
    wrs = []
    tes = []
    dst = []
    ks = []
    for row in rows:
        name = row.a.contents[0]
        pos = row.find_all('td')[-2].contents[0]
        if pos[1] == 'Q':
            qbs.append(name)
        elif pos[1] == 'R':
            rbs.append(name)
        elif pos[1] == 'W':
            wrs.append(name)
        elif pos[1] == 'T':
            tes.append(name)
        elif pos[1] == 'D':
            dst.append(name)
        else:
            ks.append(name)

    outfile = open(year+'main.csv', 'w')
    list_o_lists = [qbs, rbs, wrs, tes, dst, ks]
    for group in list_o_lists:
        for name in group:
            outfile.write(name + ',\n')
    outfile.close()
