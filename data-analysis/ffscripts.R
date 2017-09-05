#    Environment variables -
#    full_stats -- a data frame containing all of the weekly player fantasy scores
#                  gathered.  Currently these values are recorded for 2012-2015.


#### makeYearRanks
#
#    Takes as input a position from ('QB', 'RB', 'TE', 'WR', 'Def', 'K') and a year
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
  year <- sample(tmpYears, 1)[[1]]
  if (player_pos == 'QB') {
    if (year == 2012) {
      rankMat <- qbMat2012
      postMat <- post2012qb
    } else if (year == 2013) {
      rankMat <- qbMat2013
      postMat <- post2013qb
    } else if (year == 2014) {
      rankMat <- qbMat2014
      postMat <- post2014qb
    } else if (year == 2015) {
      rankMat <- qbMat2015
      postMat <- post2015qb
    }
    postRank <- sample(rankMat[pre_rank,],1)[[1]]
    if (is.na(postRank)){
      postRank <- 32
    }
    gameSet <- getGameSet(postRank, postMat, year)
  }else if (player_pos == 'RB') {
    if (year == 2012) {
      rankMat <- rbMat2012
      postMat <- post2012rb
    } else if (year == 2013) {
      rankMat <- rbMat2013
      postMat <- post2013rb
    } else if (year == 2014) {
      rankMat <- rbMat2014
      postMat <- post2014rb
    } else if (year == 2015) {
      rankMat <- rbMat2015
      postMat <- post2015rb
    }
    postRank <- sample(rankMat[pre_rank,],1)[[1]]
    if (is.na(postRank)) {
      postRank <- 70
    }
    gameSet <- getGameSet(postRank, postMat, year)
  }else if (player_pos == 'WR') {
    if (year == 2012) {
      rankMat <- wrMat2012
      postMat <- post2012wr
    } else if (year == 2013) {
      rankMat <- wrMat2013
      postMat <- post2013wr
    } else if (year == 2014) {
      rankMat <- wrMat2014
      postMat <- post2014wr
    } else if (year == 2015) {
      rankMat <- wrMat2015
      postMat <- post2015wr
    }
    postRank <- sample(rankMat[pre_rank,],1)[[1]]
    if(is.na(postRank)){
      postRank <- 70
    }
    gameSet <- getGameSet(postRank, postMat, year)
  }else if (player_pos == 'TE') {
    if (year == 2012) {
      rankMat <- teMat2012
      postMat <- post2012te
    } else if (year == 2013) {
      rankMat <- teMat2013
      postMat <- post2013te
    } else if (year == 2014) {
      rankMat <- teMat2014
      postMat <- post2014te
    } else if (year == 2015) {
      rankMat <- teMat2015
      postMat <- post2015te
    }
    postRank <- sample(rankMat[pre_rank,],1)[[1]]
    if (is.na(postRank)) {
      postRank <- 32
    }
    gameSet <- getGameSet(postRank, postMat, year)
  }else if (player_pos == 'Def') {
    if (year == 2012) {
      rankMat <- defMat2012
      postMat <- post2012def
    } else if (year == 2013) {
      rankMat <- defMat2013
      postMat <- post2013def
    } else if (year == 2014) {
      rankMat <- defMat2014
      postMat <- post2014def
    } else if (year == 2015) {
      rankMat <- defMat2015
      postMat <- post2015def
    }
    postRank <- sample(rankMat[pre_rank,],1)[[1]]
    if (is.na(postRank)){
      postRank <-32
    }
    gameSet <- getGameSet(postRank, postMat, year)
  }else {
    if (year == 2012) {
      rankMat <- kMat2012
      postMat <- post2012k
    } else if (year == 2013) {
      rankMat <- kMat2013
      postMat <- post2013k
    } else if (year == 2014) {
      rankMat <- kMat2014
      postMat <- post2014k
    } else if (year == 2015) {
      rankMat <- kMat2015
      postMat <- post2015k
    }
    postRank <- sample(rankMat[pre_rank,],1)[[1]]
    if(is.na(postRank)){
      postRank <- 32
    }
    gameSet <- getGameSet(postRank, postMat, year)
  }
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

getGameSet <- function(posRank, postMat, givenYear) {
  gameSet <- subset(full_stats, Name == factor(postMat$Name[posRank], levels(full_stats$Name)) & year == givenYear)$fantasy_pts
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
  years <- c(2012, 2013, 2014, 2015, 2016)
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
    ranking <- sample(position_rank[2], 1)
    scoreSample <- c(scoreSample, randomGameScore(c(position_rank[1], ranking)))
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

#Change after kickers to set up factor levels
# inList is a pre season ranking set
# inProjected is a set of projected games won at each rank
makePredictedGames<- function(inList, inProjected) {
  namesList <- levels(unlist(inList))
  outList <- data.frame(Names = namesList, gamesWon = rep(8, length(namesList)))
  for (i in 1:length(namesList)){
    rankVector <- integer()
    for (j in 1:5) {
      rankVector <- c(rankVector, which(inList[[j]] == namesList[i]))
    }
    print(rankVector)
    tmpSum <- numeric()
    for (j in 1:length(rankVector)){
      if (rankVector[j] > length(inProjected)) {
        tmpSum <- c(tmpSum, inProjected[length(inProjected)])
      }else {
        tmpSum <- c(tmpSum, inProjected[rankVector[j]])
      }
    }
    outList[i,2] <- sum(tmpSum)/length(rankVector)
  }
  return(outList)
}

bigTest <- function(rank1, rank2) {
  firstScores <- c(sample(top_def_hist$fantasy_pts,1), sample(top_k_hist$fantasy_pts,1), sample(top_rb_hist$fantasy_pts, 2),
                   sample(top_wr_hist$fantasy_pts, 2), sample(top_te_hist$fantasy_pts,1))
  qbScore <- makeRankedPosScore('QB', rank1)
  flexScore <- makeRankedPosScore('WR', rank2)
  finalScore <- c(firstScores, qbScore, flexScore)
  return(sum(finalScore))
}

# makes a list or predicted rank vectors for players at a given position
makeNameRanks <- function(){
  for (i in 1:length(qbnames)) {
    temprank <- c()
    for (j in 1:5) {
      temprank <- c(temprank, which(qb2016pre[[j]] == qbnames[i]))q
    }
    qbranklist[[i]] <- temprank
  }
  qbranklist
}
