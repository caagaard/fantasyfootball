#    Deals with tasks expected to be repeated for several preseason rank scraping scripts

#    It turned out to be unnecessary, at least in this form, because of the changes from year to
#    year and ranking set to ranking set

#    Makes a separate player ranking list for each position
def makeLists ():
    qbs = []
    rbs = []
    wrs = []
    tes = []
    dst = []
    ks = []
    return [qbs, rbs, wrs, tes, dst, ks]


#   Determines what a player's position is, to add them to the appropriate list
def checkPos(pos, index):
    if pos[index] == 'Q':
        return(0)
    elif pos[index] == 'R':
        return(1)
    elif pos[index] == 'W':
        return(2)
    elif pos[index] == 'T':
        return(3)
    elif pos[index] == 'D':
        return(4)
    else:
        return(5)
