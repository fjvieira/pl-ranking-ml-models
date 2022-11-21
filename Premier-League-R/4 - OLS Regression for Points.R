# Using OLS to predict Points of a club in the end of the season

library("tidyverse")
library("nortest")
library("plotly")
library("car")
library("jtools")
library("olsrr")
library("PerformanceAnalytics")
library("lmtest")

#----------------------------------------------------------------

run_shapiro_francia_test <- function(model) {
  if((sf.test(model$residuals))$p.value < 0.05){
    print("Invalid model")
  } else {
    print("Valid model")    
  }
} 

run_breusch_pagan_test <- function(model) {
  if((ols_test_breusch_pagan(model))$p < 0.05){
    print("Heteroscedasticity detected")
  } else {
    print("No heteroscedasticity detected")
  }
} 

run_breusch_godfrey_test <- function(model) {
  if((bgtest(model))$p.value < 0.05){
    print("Residual autocorrelation detected")
  } else {
    print("No residual autocorrelation detected")
  }
} 

#----------------------------------------------------------------

load('RData/season_consolidated_10_22.RData')

load('RData/season_consolidated_00_22.RData')

#----------------------------------------------------------------
# Graphical rechecking correspondence between Pts/Rank and other independent vars 

chart.Correlation(
  season_consolidated_10_22[c("Rk","Pts","Arrivals","Departures","MktValue","Turnover","WageBill","Expenditure","Income",
                              "Balance", "AvgAge")],
  histogram = TRUE)

chart.Correlation(
  season_consolidated_10_22[c("Rk","Pts","RkLast","WLast","DLast","LLast","GFLast","GALast","GDLast","PtsLast","AvgAge")],
  histogram = TRUE)

chart.Correlation(
  season_consolidated_10_22[c("RkLast","WLast","DLast","LLast","Arrivals","Departures","MktValue","Turnover","WageBill","Expenditure","Income",
                              "Balance")],
  histogram = TRUE)


#Conclusion: there are many strong correlation between independent variables that can lead to multicollinearity.

#----------------------------------------------------------------
# Regression with all available variables 2010 - 2021 

# Remove last year due to the lack of Wage and turnover data
season_consolidated_10_21 <- filter(season_consolidated_10_22, season_consolidated_10_22$Year <2021)

season_model_10_21 <- lm(formula = Pts ~ `MktValue` + 
                      `WageBill` + `Turnover` +
                      `Expenditure` + `Arrivals` + `Income` + `Departures` + `Balance` +
                      `RkLast` + `WLast` + 
                      `DLast` + `LLast` + `GFLast` + `GALast` + `GDLast` + `PtsLast` +
                      `AvgAge`,
                   data = season_consolidated_10_21)

summary(season_model_10_21)

run_shapiro_francia_test(season_model_10_21)

step_season_10_21 <- step(season_model_10_21, k = 3.841459)

summary(step_season_10_21)

run_shapiro_francia_test(step_season_10_21)

run_breusch_pagan_test(step_season_10_21)

ols_vif_tol(step_season_10_21)

season_consolidated_10_21$PtsFitted <- step_season_10_21$fitted.values

season_consolidated_10_21$residuals <- step_season_10_21$residuals

summary(abs(season_consolidated_10_21$residuals))

season_consolidated_10_21 %>% ggplot(aes(x = residuals)) +
  geom_histogram(aes(y = ..density..), 
                 color = "grey50", 
                 fill = "grey90", 
                 bins = 30,
                 alpha = 0.6) +
  stat_function(fun = dnorm, 
                args = list(mean = mean(season_consolidated_10_21$residuals),
                            sd = sd(season_consolidated_10_21$residuals)),
                aes(color = ""),
                size = 2) +
  scale_color_manual("",
                     values = "#FDE725FF") +
  labs(x = "Resíduos",
       y = "Frequência") +
  theme(panel.background = element_rect("white"),
        panel.grid = element_line("grey95"),
        panel.border = element_rect(NA),
        legend.position = "bottom")

var(season_consolidated_10_21$residuals)

run_breusch_godfrey_test(step_season_10_21)

# Conclusion: Multiple R-squared:  0.7282, Adjusted R-squared:  0.7205, High variance
# Some VIF values are over 10, indicating 

#----------
#Regression with Box-cox transformation

lambda_BC <- powerTransform(season_consolidated_10_21$Pts)

season_consolidated_10_21$bc_Pts <- (((season_consolidated_10_21$Pts ^ lambda_BC$lambda) - 1) / 
                                      lambda_BC$lambda)

season_model_10_21_bc <- lm(formula = bc_Pts ~ `MktValue` + 
                        `WageBill` + `Turnover` +
                        `Expenditure` + `Arrivals` + `Income` + `Departures` + `Balance` +
                        `RkLast` + `WLast` + `DLast` + `LLast` + `GFLast` + `GALast` + `GDLast`+`PtsLast` +
                        `AvgAge`,
                      data = season_consolidated_10_21)


step_season_model_10_21_bc <- step(season_model_10_21_bc, k = 3.841459)

summary(step_season_model_10_21_bc)

run_shapiro_francia_test(step_season_model_10_21_bc)

#Conclusion: p < 0.05 - no valid model for Box-Cox.

#----------------------------------------------------------------
# Regression for data available since 2001 no Mkt Value, turnover and wage

season_consolidated_01_22 <- filter(season_consolidated_00_22, season_consolidated_00_22$Year > 2000)

season_model_01_22 <- lm(formula = Pts ~ 
                     `Expenditure` + `Arrivals` + `Income` + `Departures` + `Balance` +
                     `RkLast` + `WLast` + `DLast` + `LLast` + `GFLast` + `GALast` + `GDLast`+`PtsLast` +
                     `AvgAge`,
                   data = season_consolidated_01_22)

summary(season_model_01_22)

run_shapiro_francia_test(season_model_01_22)

step_season_model_01_22 <- step(season_model_01_22, k = 3.841459)

summary(step_season_model_01_22)

run_shapiro_francia_test(step_season_model_01_22)

run_breusch_pagan_test(step_season_model_01_22)

ols_vif_tol(step_season_model_01_22)

run_breusch_godfrey_test(step_season_10_21)

var(step_season_model_01_22$residuals)

# Conclusion 1: Multiple R-squared:  0.6603,	Adjusted R-squared:  0.6554, high variance.
# Conclusion 2: High VIF values for some variables indicates multicollinearity.

#----------
#Regression with Box-cox transformation

lambda_BC <- powerTransform(season_consolidated_01_22$Rk)

season_consolidated_01_22$bc_Pts <- (((season_consolidated_01_22$Pts ^ lambda_BC$lambda) - 1) / 
                                      lambda_BC$lambda)

season_modeld_01_22_bc <- lm(formula = bc_Pts ~
                               `Expenditure` + `Arrivals` + `Income` + `Departures` + `Balance` +
                               `RkLast` + `WLast` + `DLast` + `LLast` + `GFLast` + `GALast` + `GDLast`+`PtsLast` +
                               `AvgAge`,
                      data = season_consolidated_01_22)

summary(season_modeld_01_22_bc)

run_shapiro_francia_test(season_modeld_01_22_bc)

run_breusch_pagan_test(season_modeld_01_22_bc)

ols_vif_tol(season_modeld_01_22_bc)

step_season_model_01_22_bc <- step(season_modeld_01_22_bc, k = 3.841459)

summary(step_season_model_01_22_bc)

run_shapiro_francia_test(step_season_model_01_22_bc)

run_breusch_pagan_test(step_season_model_01_22_bc)

ols_vif_tol(step_season_model_01_22_bc)

run_breusch_godfrey_test(step_season_model_01_22_bc)

var(step_season_model_01_22_bc$residuals)

# Conclusion 1: R-squared:  0.6456,	Adjusted R-squared:  0.6404, but with residual autocorrelation.
# Conclusion 2: High VIF values for some variables indicates multicollinearity.
