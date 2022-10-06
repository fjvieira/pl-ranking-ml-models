## Using multinomial logistic to predict Rank and groups of a club in the end of the season

library("tidyverse")
library("nnet")
library("kableExtra")
library("pROC")
library("foreach")

#----------------------------------------------------------------

calc_qui2 <- function(x) {
  v_max <- logLik(x)
  v_min <- logLik(update(x, ~1, trace = F))
  Qui2 <- -2 * (v_min - v_max)
  pvalue <- pchisq(Qui2, df = 1, lower.tail = F)
  return(cbind.data.frame(Qui2, pvalue))
}

# 1. Season Champion
# 2. 2-4 positions (Qualified for UEFA Champions League)
# 3. 5-17 Remain in Premier League and can be qualified to second class continental cups
# 4. 18-20 Relegated to Championship League (2nd division)
determine_rk_group <- function(Rk) {
  return(ifelse(Rk == 1, 1, ifelse(Rk <= 4, 2, ifelse(Rk > 17, 4, 3))))
}

#----------------------------------------------------------------

load("RData/season_consolidated_10_22.RData")

load("RData/season_consolidated_00_22.RData")

#----------------------------------------------------------------
# Model for ranking of teams (1-20)

season_consolidated_10_22$Rk <- relevel(factor(season_consolidated_10_22$Rk),
  ref = 1
)

season_consolidated_10_21 <- filter(season_consolidated_10_22, season_consolidated_10_22$Year < 2021)

season_model_10_21 <- multinom(
  formula = Rk ~ `MktValue` +
    `WageBill` + `Turnover` +
    `Expenditure` + `Arrivals` + `Income` + `Departures` + `Balance` +
    `RkLast` + `WLast` +
    `DLast` + `LLast` + `GFLast` + `GALast` + `GDLast` + `PtsLast` +
    `AvgAge`,
  data = season_consolidated_10_21
)


summary(season_model_10_21)

logLik(season_model_10_21)

calc_qui2(season_model_10_21)

season_consolidated_10_21$prediction <- predict(season_model_10_21,
  newdata = season_consolidated_10_21,
  type = "class"
)

realXpred <- table(season_consolidated_10_21$Rk, season_consolidated_10_21$prediction)

# Accuracy
(round((sum(diag(realXpred)) / sum(realXpred)), 2))

step_season_10_21 <- step(season_model_10_21, k = qchisq(p = 0.05, df = 1, lower.tail = FALSE))

summary(step_season_10_21)

logLik(step_season_10_21)

calc_qui2(step_season_10_21)
#z-wald
zWald_step_season_10_21 <- (summary(step_season_10_21)$coefficients /
  summary(step_season_10_21)$standard.errors)

# p value
round((pnorm(abs(zWald_step_season_10_21), lower.tail = F) * 2), 4)

season_consolidated_10_21$prediction_step <- predict(season_model_10_21,
  newdata = season_consolidated_10_21,
  type = "class"
)

realXpred_step <- table(season_consolidated_10_21$Rk, season_consolidated_10_21$prediction_step)

# Accuracy
(round((sum(diag(realXpred_step)) / sum(realXpred_step)), 2))


# Conclusion 1: after stepwise only Turnover remains as an independent var
# Conclusion 2: High AIC (1178.42) and low accuracy (0.46), 
# Conclusion 3: z-wald out of scale for some categories

#----------------------------------------------------------------
# Model for groups in 2010 to 2021 seasons

load("RData/season_consolidated_10_22.RData")

season_consolidated_10_22$Rkgroup <- determine_rk_group(season_consolidated_10_22$Rk)

season_consolidated_10_22$Rkgroup <- relevel(factor(season_consolidated_10_22$Rkgroup),
  ref = 1
)

season_consolidated_10_21 <- filter(season_consolidated_10_22, season_consolidated_10_22$Year < 2021)

season_model_10_21 <- multinom(
  formula = Rkgroup ~ `MktValue` +
    `WageBill` + `Turnover` +
    `Expenditure` + `Arrivals` + `Income` + `Departures` + `Balance` +
    `RkLast` + `WLast` +
    `DLast` + `LLast` + `GFLast` + `GALast` + `GDLast` + `PtsLast` +
    `AvgAge`,
  data = season_consolidated_10_21
)


summary(season_model_10_21)

logLik(season_model_10_21)

calc_qui2(season_model_10_21)

season_consolidated_10_21$prediction <- predict(season_model_10_21,
  newdata = season_consolidated_10_21,
  type = "class"
)

realXpred <- table(season_consolidated_10_21$Rkgroup, season_consolidated_10_21$prediction)

# Accuracy
(round((sum(diag(realXpred)) / sum(realXpred)), 2))

step_season_10_21 <- step(season_model_10_21, k = qchisq(p = 0.05, df = 1, lower.tail = FALSE))

summary(step_season_10_21)

logLik(step_season_10_21)

calc_qui2(step_season_10_21)

#z-wald
zWald_step_season_10_21 <- (summary(step_season_10_21)$coefficients /
  summary(step_season_10_21)$standard.errors)

# p value
round((pnorm(abs(zWald_step_season_10_21), lower.tail = F) * 2), 4)



season_consolidated_10_21$prediction_step <- predict(season_model_10_21,
  newdata = season_consolidated_10_21,
  type = "class"
)



realXpred_step <- table(season_consolidated_10_21$Rkgroup, season_consolidated_10_21$prediction_step)

# Accuracy
(round((sum(diag(realXpred_step)) / sum(realXpred_step)), 2))

summary(season_consolidated_10_21[c("Rkgroup", "prediction_step")])

# Conclusion: A model with 83% of accuracy for predict RkGroups were found.
#----------------------------------------------------------------------
# Model for groups in 2001 to 2022 seasons - Without business data.

season_consolidated_00_22$Rkgroup <- determine_rk_group(season_consolidated_00_22$Rk)

season_consolidated_00_22$Rkgroup <- relevel(factor(season_consolidated_00_22$Rkgroup),
  ref = 1
)

season_consolidated_01_22 <- filter(season_consolidated_00_22, season_consolidated_00_22$Year > 2000)

season_model_01_22 <- multinom(
  formula = Rkgroup ~
    `Expenditure` + `Arrivals` + `Income` + `Departures` + `Balance` +
    `RkLast` + `WLast` +
    `DLast` + `LLast` + `GFLast` + `GALast` + `GDLast` + `PtsLast` +
    `AvgAge`,
  data = season_consolidated_01_22
)


summary(season_model_01_22)

logLik(season_model_01_22)

calc_qui2(season_model_01_22)

season_consolidated_01_22$prediction <- predict(season_model_01_22,
  newdata = season_consolidated_01_22,
  type = "class"
)

realXpred <- table(season_consolidated_01_22$Rkgroup, season_consolidated_01_22$prediction)

# Accuracy
(round((sum(diag(realXpred)) / sum(realXpred)), 2))

step_season_01_22 <- step(season_model_01_22, k = qchisq(p = 0.05, df = 1, lower.tail = FALSE))

summary(step_season_01_22)

logLik(step_season_01_22)

calc_qui2(step_season_01_22)

#z-wald
zWald_step_season_01_22 <- (summary(step_season_01_22)$coefficients /
                              summary(step_season_01_22)$standard.errors)

# p value
round((pnorm(abs(zWald_step_season_01_22), lower.tail = F) * 2), 4)

season_consolidated_01_22$prediction_step <- predict(step_season_01_22,
  newdata = season_consolidated_01_22,
  type = "class"
)


realXpred_step <- table(season_consolidated_01_22$Rkgroup, season_consolidated_01_22$prediction_step)

# Accuracy
(round((sum(diag(realXpred_step)) / sum(realXpred_step)), 2))


# Conclusion: For 22 years, but without business data, accuracy is 75%
#----------------------------------------------------------------------
