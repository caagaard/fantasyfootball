testGameScore <- function(player_pos) {
  rbs <- runif(1,0, 1)
  if (rbs < .5) {
    splits <- 3
  } else {
    splits <- 2
  }
  one_position_scores <- c(sample(top_te_hist$fantasy_pts, 1), sample(top_def_hist$fantasy_pts, 1),
    sample(top_qb_hist$fantasy_pts, 1), sample(top_k_hist$fantasy_pts, 1))
  rb_scores <- c(sample(top_rb_hist$fantasy_pts, splits, replace = T))
  wr_scores <- c(sample(top_wr_hist$fantasy_pts, (4-splits), replace = T))
  pl_score <- c(sample(player_pos, 1))
  sum(c(one_position_scores, rb_scores, wr_scores, pl_score))
}
