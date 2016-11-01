#### These scripts help turn the data scraped from pro-football-reference and ESPN by the 
#### scripts in /scraping into simulated results from either an average team in a fantasy football
#### league, or an average team with a specific player substituted.  
####


#### METHODS ####
####
#### Two major problems with fantasy-football draft valuations are addressed (hopefully) by this 
#### project.

#### 1) Because of high interseason roster turnover, reliance on teammates, and changing strength of
#### schedule it seems unreasonable to accurately forecast a player's performance based on their 
#### previous individual performance.

#### 2) Most fantasy-football projection only address total points scored, although variance is just
#### as important.  As an example, consider two teams that each score on average 200 points per week.
#### If one scores 0 points half the time, and 400 half the time, they would win 50% of their games.
#### On the other hand, if the other team scores 200 points every game, they would have a 100% win rate.

#### To address the first problem, it is assumed that weekly scoring can be treated as a random variable
#### that is a function of end of season rank.  Chi squared tests were done to make sure it wasn't unreasonable
#### to assume each season shared a common distribution, and F-tests were done to make sure time wasn't an
#### impactful input variable.  Then projected rankings by professional analysts and aggregate
#### draft positions from the fantasy football community were used as estimates of how well 
#### players will perform, and uncertainty was addressed by mapping each preseason ranking to a 
#### distribution of historical outcomes of players with that preseason ranking.

#### To address the second problem, players were evaluated by simulating thousands of games.  Samples
#### were taken from a pool of historical individual performances with the player pool chosen to best
#### approximate the actual league results (mean scores differed by about .1 points per game, and the
#### simulated teams won about 49.5% of games).  Players within a position were ranked by simulating how
#### a team would perform substituting that player for the simulated 'average' player.

#### To Be Fixed/Added/Changed
####
#### Several functions should be vectorized that currently use loops
#### Once functions are vectorized, allow for simulating full teams of individual players


#### Global variables are listed below.  Many of them could be passed as parameters in functions,
#### but it would become unwieldy to type such large numbers of inputs into the functions.  If using
#### these scripts, be sure to either use these variable names, or change their names in the scripts 
#### to match your variable names

#    Environment variables -
#    full_stats -- a data frame containing all of the weekly player fantasy scores
#                  gathered.  Currently these values are recorded for 2012-2015.
#    **Mat201*  (qbMat2012, rbMat2015, etc) -- matrices mapping 5 columns of preseason
#                                              rankings to end of season ranks
#
#    top_*_hist -- history of the "startable" players' weekly scores.  The number of 
#                  players included is determined by makeYearSum and is explained there
#
#    post201*** (post2012qb, post2016wr, etc) -- final season rankings at a position by
#                                                total points scored. Output from makeYearRanks

#### makeYearRanks
#
#    Takes as input a position from ('QB', 'RB', 'TE', 'WR', 'Def', 'K) and a year
#    Computes the total fantasy points each player at that position scored that year
#
#    Returns a data frame containing the year, along with the name and points scored by
#    each of the top $rankCap players at the position
#
#    rankCap is chosen for each position such that players with worse rank would probably not
#    see play in the type of league used.
#    If your league has a different number of teams, or different lineup settings, change rankCap

makeYearRanks <- function(position, year) {
  tmpPos <- full_stats[full_stats$pos == position, c(1,6,7)]
  tmpPosYear <- tmpPos[tmpPos$year == year, c(1,2)]
  Name <- levels(factor(tmpPosYear$Name, levels = unique(tmpPosYear$Name)))
  tmpYearScore <- numeric()
  for (i in 1:length(Name)) {
    tmpYearScore[i] <- sum(tmpPosYear$fantasy_pts[tmpPosYear$Name == Name[i]])
  }
  tmpYearSum <- data.frame(Name, tmpYearScore)
  colnames(tmpYearSum)[2] <- 'score'
  tmpYearSum <- tmpYearSum[order(-tmpYearSum$score),]
  if (position == 'QB' | position == 'TE') {
    rankCap <- 32
  }else if (position == 'K' | position == 'Def') {
    rankCap <- 32
  } else if (position == 'RB') {
    rankCap <- 70
  }else if (position == 'WR') {
    rankCap <- 70
  } else {
    print('Invalid position')
    quit()
  }
  tmpTopPlayers <- cbind(tmpYearSum[1:rankCap,], rep(year, rankCap))
  colnames(tmpTopPlayers)[3] <- 'year'
  tmpTopPlayers
}

#### makeRankedPosScores
#
#    Takes as input a position and preseason rank
#    Finds a real season rank by sampling from the dataframes mapping preseason ranks to final ranks
#    Then uses the history of weekly scores from players at that position, with that final rank as a
#    population for the weekly score distribution, and returns a single sampled element from that population
    
makeRankedPosScore <- function(player_pos, pre_rank) {
  tmpYears <- c(2012, 2013, 2014, 2015)
  if (player_pos == 'QB') {
    postRank <- sample(c(qbMat2012[pre_rank,], qbMat2013[pre_rank,], qbMat2014[pre_rank,], qbMat2015[pre_rank,]),1)[[1]]
    if (is.na(postRank)){
      postRank <- 32
    }
    gameSet <- getGameSet(postRank[[1]], post2012qb, post2013qb, post2014qb, post2015qb)
  }else if (player_pos == 'RB') {
    postRank <- sample(c(rbMat2012[pre_rank,], rbMat2013[pre_rank,], rbMat2014[pre_rank,], rbMat2015[pre_rank,]), 1)[[1]]
    if (is.na(postRank)) {
      postRank <- 70
    }
    gameSet <- getGameSet(postRank, post2012rb, post2013rb, post2014rb, post2015rb)
  }else if (player_pos == 'WR') {
    postRank <- sample(c(wrMat2012[pre_rank,], wrMat2013[pre_rank,], wrMat2014[pre_rank,], wrMat2015[pre_rank,]), 1)[[1]]
    if(is.na(postRank)){
      postRank <- 70
    }
    gameSet <- getGameSet(postRank, post2012wr, post2013wr, post2014wr, post2015wr)
  }else if (player_pos == 'TE') {
    postRank <- sample(c(teMat2012[pre_rank,], teMat2013[pre_rank,], teMat2014[pre_rank,], teMat2015[pre_rank,]), 1)[[1]]
    if (is.na(postRank)) {
      postRank <- 32
    }
    gameSet <- getGameSet(postRank, post2012te, post2013te, post2014te, post2015te)
  }else if (player_pos == 'Def') {
    postRank <- sample(c(defMat2012[pre_rank,], defMat2013[pre_rank,], defMat2014[pre_rank,], defMat2015[pre_rank,]), 1)[[1]]
    if (is.na(postRank)){
      postRank <-32
    }
    gameSet <- getGameSet(postRank, post2012def, post2013def, post2014def, post2015def)
  }else {
    postRank <- sample(c(kMat2012[pre_rank,], kMat2013[pre_rank,], kMat2014[pre_rank,], kMat2015[pre_rank,]), 1)[[1]]
    if(is.na(postRank)){
      postRank <- 32
    }
    gameSet <- getGameSet(postRank, post2012k, post2013k, post2014k, post2015k)
  }
  print(gameSet)
  sample(gameSet, 1)
}

#### getGameSet
#
#    Takes as inputs an end of season rank at a position, and a frame of season totals
#    for each player at that position.
#
#    For each season, takes the player ranked posRank, at the given position, and adds
#    their weekly game scores to a vector.
#    Returns the vector with the weekly scores over all recorded seasons.

getGameSet <- function(posRank, firstYear, secondYear, thirdYear, fourthYear) {
  first <- subset(full_stats, Name == factor(firstYear$Name[posRank], levels(full_stats$Name)) & year == 2012)$fantasy_pts
  second <- subset(full_stats, Name == factor(secondYear$Name[posRank], levels(full_stats$Name)) & year == 2013)$fantasy_pts
  third <- subset(full_stats, Name == factor(thirdYear$Name[posRank], levels(full_stats$Name)) & year == 2014)$fantasy_pts
  fourth <- subset(full_stats, Name == factor(fourthYear$Name[posRank], levels(full_stats$Name)) & year == 2015)$fantasy_pts
  gameSet <- c(first, second, third, fourth)
  gameSet
}

#### makeYearSums
#
#    Takes as inputs a position and year
#    Output is a data frame of all the weekly  game scores for the top $rankCap$
#    of players at that position for that year.
#
#    In this function, rankCap has a special purpose.  The values for rankCap are
#    chosen to optimize the fit of the distribution of randomGameScore outputs to
#    the distribution of actual league results.  Change these rankCap values to
#    bets fit your league
#
#    Eventually a function will be added to calculate optimal rankCap values based
#    on any history of league scores

makeYearSums <- function(position, year) {
  tmpPos <- full_stats[full_stats$pos == position, c(1, 6, 7)]
  tmpPosYear <- tmpPos[tmpPos$year == year, c(1,2)]
  Name <- levels(factor(tmpPosYear$Name, levels = unique(tmpPosYear$Name)))
  tmpYearScore <- numeric()
  for (i in 1:length(Name)) {
    tmpYearScore[i] <- sum(tmpPosYear$fantasy_pts[tmpPosYear$Name == Name[i]])
  }
# Sums players' weekly scores over the season to identify the top $rankCap$ of
# players
  tmpYearSum <- data.frame(Name, tmpYearScore)
  colnames(tmpYearSum)[2] <- 'score'
  tmpYearSum <- tmpYearSum[order(-tmpYearSum$score),]
  if (position == 'QB' | position == 'TE') {
    rankCap <- 15
  } else if (position =='K' | position == 'Def') {
    rankCap <- 20
  } else if (position == 'RB') {
    rankCap <- 40
  } else {
    rankCap <- 42
  }
  tmpTopPlayers <- tmpYearSum[1:rankCap,]
  tmpWeeklyScores <- tmpPosYear[tmpPosYear$Name %in% tmpTopPlayers$Name,]
  tmpWeeklyScores
}

#### makeTopHist
#
#    Takes as input a postion
#
#    Creates and returns a data frame of all the weekly scores from 'starter'
#    players at a given position over 2012-2015.  'Starter' players are determined
#    in makeYearSums

makeTopHist <- function(position) {
  years <- c(2012, 2013, 2014, 2015)
  in_year <- 2012
  tmpData <- makeYearSums(position, in_year)
  tmp_top_hist <- cbind(tmpData, rep(in_year, length(tmpData$Name)))
  colnames(tmp_top_hist)[3] <- 'year'
  tmp_top_hist$year <- as.factor(tmp_top_hist$year)
  for (i in 2:4) {
    in_year <- years[i]
    tmpData <- makeYearSums(position, in_year)
    tmpData <- cbind(tmpData, rep(in_year, length(tmpData$Name)))
    colnames(tmpData)[3] <- 'year'
    tmpData$year <- as.factor(tmpData$year)
    tmp_top_hist <- rbind(tmp_top_hist, tmpData)
  }
  return(tmp_top_hist)
}

#### randomGameScore
#
#    Takes as optional input a vector of length 2 (a position and a preseason rank)
#    
#    Simulates a weekly team score for a typical team in the league.  If position_rank
#    is used, then a simulated score for that player replaces the random score used for
#    a typical team.
#
#    By comparing results with a given optional input to results without an optional input
#    the effect of drafting a specific player can hopefully be observed

randomGameScore <- function(position_rank) {
  rbs <- runif(1,0, 1)
  if (rbs < .5) {
    splits <- 3
  } else {
    splits <- 2
  }
  one_position_scores <- c(sample(top_k_hist$fantasy_pts, 1), sample(top_def_hist$fantasy_pts, 1), 
      sample(top_te_hist$fantasy_pts, 1), sample(top_qb_hist$fantasy_pts, 1)) 
  rb_scores <- c(sample(top_rb_hist$fantasy_pts, splits, replace = T))
  wr_scores <- c(sample(top_wr_hist$fantasy_pts, (5-splits), replace = T))
  position_scores <- c(one_position_scores, rb_scores, wr_scores)
  if (length(position_rank)==2) {
    subbed_score <- makeRankedPosScore(position_rank[1], as.integer(position_rank[2]))
    if (position_rank[1] == 'K'){
      position_scores[1] <- subbed_score
    }else if(position_rank[1] == 'Def'){
      position_scores[2] <- subbed_score
    }else if(position_rank[1] == 'TE') {
      position_scores[3] <- subbed_score
    }else if(position_rank[1] == 'QB') {
      position_scores[4] <- subbed_score
    }else if(position_rank[1] == 'RB') {
      position_scores[5] <- subbed_score
    }else {
      position_scores[9] <- subbed_score
    }
  }
  sum(position_scores)
}

##### gameScoreSamples
#
#    Takes as input the desired sample size and and optional vector position_rank
#    position_rank, if used, should be a vector of length 2 (position, preseason rank)
#    
#    This function generates a sample of of the desired size of simulated games
#    By default the games simulated follow the distribution of game scores in the league
#    If position_rank is used, simulated games represent a typical lineup, with
#    the specified rank at the specified position instead of a random player

gameScoreSamples <- function(size, position_rank = c()) {
  i = 0
  scoreSample <- numeric()
  while (i < size) {
    scoreSample <- c(scoreSample, randomGameScore(position_rank))
    i <- i +1
  }
  return(scoreSample)
}

#### makePositionMatrix
#
#    Takes as input a data frame of preseason rankings, the postseason ranks at that position
#    and a variable rankCap, as the lowest rank to be recorded
#
#    Returns a data frame where each column represents one set of preseason rankings, and the 
#    entry in the ith row for a column is the real rank of the player predicted to be rank i
#    by that column's prediction source (an individual analyst, ESPN staff, or ADP)
makePositionMatrix <- function(preRanks, postRanks, rankCap) {
  posMat <- data.frame(r1= integer(), r2 = integer(), r3= integer(), r4 = integer(), r5 = integer())
  for (i in (1:5)) {
    preRanks[[i]] <- as.character(preRanks[[i]])
    preRanks[[i]] <- factor(preRanks[[i]], levels = levels(postRanks$Name))
    for (j in 1:rankCap) {
      if (j <= length(preRanks[[i]])) {
          tempStore <- which(postRanks$Name == preRanks[[i]][j])
          if (length(tempStore) == 0){
            posMat[j,i] <- NA
          }else {
            posMat[j,i] <- tempStore
          }
        } else {
        posMat[j,i] <- NA
      }
    }
  }
  posMat
}

#### fixDefenseToFactor
#
#    Defenses weren't named consistently in source pages.
#    This takes the text names for defenses and unifies their
#    format across years and teams

fixDefensetoFactor <- function(toBeChanged, sourceList) {
  for (i in 1:5) {
    toBeChanged[[i]] <- as.character(toBeChanged[[i]])
    toBeChanged[[i]] <- gsub(' .*', '', toBeChanged[[i]])
    for (j in 1:length(toBeChanged[[i]])) {
      toBeChanged[[i]][j] <- sourceList[grep(toBeChanged[[i]][j], sourceList)]
    }
  }
  return(toBeChanged)
}
