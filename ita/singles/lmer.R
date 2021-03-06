sink("diagnostics/singles_lmer.txt")

library(lme4)
library(nortest)
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname="tennis")

query <- dbSendQuery(con, "
select
r.year,
r.field,
r.player_id as player,
r.opponent_id as opponent,
won
from ita.singles_results r
--where
--    r.year between 2015 and 2015
;")

games <- fetch(query,n=-1)

dim(games)

attach(games)

pll <- list()

# Fixed parameters

#year <- as.factor(year)
#contrasts(year)<-'contr.sum'

field <- as.factor(field)
#field <- relevel(field, ref = "neutral")

#d_div <- as.factor(d_div)

#o_div <- as.factor(o_div)

#game_length <- as.factor(game_length)

fp <- data.frame(field)
fpn <- names(fp)

# Random parameters

#game_id <- as.factor(game_id)
#contrasts(game_id) <- 'contr.sum'

player <- as.factor(player)
#contrasts(offense) <- 'contr.sum'

opponent <- as.factor(opponent)
#contrasts(defense) <- 'contr.sum'

rp <- data.frame(player, opponent)
rpn <- names(rp)

for (n in fpn) {
  df <- fp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("fixed",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

for (n in rpn) {
  df <- rp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("random",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

# Model parameters

parameter_levels <- as.data.frame(do.call("rbind",pll))
dbWriteTable(con,c("ita","singles_parameter_levels"),parameter_levels,row.names=TRUE)

g <- cbind(fp,rp)

dim(g)

model <- won ~ field+(1|player)+(1|opponent)
fit <- glmer(model, data=g, REML=FALSE, family=binomial(logit), verbose=TRUE)

fit
summary(fit)

anova(fit)

# List of data frames

# Fixed factors

f <- fixef(fit)
fn <- names(f)

# Random factors

r <- ranef(fit)
rn <- names(r) 

results <- list()

for (n in fn) {

  df <- f[[n]]

  factor <- n
  level <- n
  type <- "fixed"
  estimate <- df

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

for (n in rn) {

  df <- r[[n]]

  factor <- rep(n,nrow(df))
  type <- rep("random",nrow(df))
  level <- row.names(df)
  estimate <- df[,1]

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

combined <- as.data.frame(do.call("rbind",results))

dbWriteTable(con,c("ita","singles_basic_factors"),as.data.frame(combined),row.names=TRUE)

f <- fitted(fit) 
r <- residuals(fit)

# Examine residuals

jpeg("diagnostics/singles_fitted_vs_residuals.jpg")
plot(f,r)
jpeg("diagnostics/singles_q-q_plot.jpg")
qqnorm(r,main="Q-Q plot for residuals")

quit("no")
