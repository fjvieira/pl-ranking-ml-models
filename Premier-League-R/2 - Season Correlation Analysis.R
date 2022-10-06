# This script is used to correlation analysis of variables that impact clubs' performance per season

library("tidyverse")
library("plotly")
library("correlation")
library("PerformanceAnalytics")
library("lubridate")
library("kableExtra")


#----------------------------------------------------------------

load("RData/season_basics_00_22.RData")

load("RData/club_finances_10_22.RData")

load("RData/club_seasonal_expenditure_00_22.RData")

load("RData/club_squad_mkt_value_10_22.RData")

#----------------------------------------------------------------
# Evolution of teams' turnover and wage

ggplotly(
  ggplot(club_finances_10_22, aes(x = Year, y = `Turnover £m`, color = Club)) +
    geom_boxplot(fill = "white", colour = "grey80", show.legend = F) +
    geom_jitter(width = 0.1, shape = 1, size = 1, show.legend = NA) +
    scale_color_manual(values = c("Chelsea FC" = "blue", "Liverpool FC" = "red", 
      "Manchester City" = "blue", "Manchester United" = "red", "Tottenham Hotspur" = "blue", "Arsenal FC" = "red")) +
    xlab("Ano") +
    ylab("Receita") +
    theme_classic()
)

ggplotly(
  ggplot(club_finances_10_22, aes(x = Year, y = `Wage Bill £m`, color = Club), show.legend = F) +
    geom_boxplot(fill = "white", colour = "grey80", show.legend = F) +
    geom_jitter(width = 0.1, shape = 1, size = 1, show.legend = FALSE) +
    scale_color_manual(values = c("Chelsea FC" = "blue", "Liverpool FC" = "red", 
      "Manchester City" = "blue", "Manchester United" = "red", "Tottenham Hotspur" = "blue", "Arsenal FC" = "red")) +
    xlab("Ano") +
    ylab("Salários") +
    theme_classic()
)

#----------------------------------------------------------------
# Basic season data correlation

chart.Correlation(
  season_basics_00_22[c("Rk", "Pts", "W", "D", "L", "GF", "GA", "GD", "avg_age")],
  histogram = TRUE
)

#----------------------------------------------------------------
# Season x Mean age + Club finances + Squad mkv value

# Filter mkt value to have a start mkt value in each season
club_squad_mkt_value_beg_season <- filter(
  club_squad_mkt_value_10_22,
  month(club_squad_mkt_value_10_22$Date) == "11" & year(club_squad_mkt_value_10_22$Date) != "2022"
) %>% union(filter(club_squad_mkt_value_10_22, 
    month(club_squad_mkt_value_10_22$Date) == "7" & year(club_squad_mkt_value_10_22$Date) == "2022"))



club_basic_perf_finances <- left_join(
  season_basics_00_22 %>% filter(Year > "2009"),
  club_squad_mkt_value_beg_season[, c("Year", "Club", "Value(mEuro)", "Current value(mEuro)", "Variation(%)")],
  by = c("Year", "Club")
) %>% left_join(
  club_finances_10_22[, c("Year", "Club", "Turnover £m", "Wage Bill £m")],
  by = c("Year", "Club")
)


club_basic_perf_finances$`Turnover £m` <- ave(club_basic_perf_finances$`Turnover £m`, club_finances_10_22$Year, FUN = scale)

club_basic_perf_finances$`Wage Bill £m` <- ave(club_basic_perf_finances$`Wage Bill £m`, club_finances_10_22$Year, FUN = scale)

club_basic_perf_finances$`Value(mEuro)` <- ave(club_basic_perf_finances$`Value(mEuro)`, club_basic_perf_finances$Year, FUN = scale)

chart.Correlation(
  club_basic_perf_finances[c("Rk", "Pts", "W", "D", "L", "GF", "GA", "GD", "avg_age", "Value(mEuro)", "Turnover £m", "Wage Bill £m")],
  histogram = TRUE
)

#--------------
# Conclusion1: mean age of a squad does not have big influence in performance (contrary to the public belief - aged squads perform better).
#--------------
# Conclusion2: market value of a team has direct correlation with the performance.
#--------------
# Conclusion3: club turnover and wages have direct correlation with the performance.
#--------------

# Season X Expenditure

club_basic_expend <- left_join(
  season_basics_00_22,
  club_seasonal_expenditure_00_22[c("Year", "Club", "Expenditure(mEuro)", "Arrivals", "Income(mEuro)", "Departures", "Balance(mEuro)")],
  by = c("Year", "Club")
)

club_basic_expend$"Expenditure(mEuro)" <- ave(club_basic_expend$"Expenditure(mEuro)", club_basic_expend$Year, FUN = scale)

club_basic_expend$"Income(mEuro)" <- ave(club_basic_expend$"Income(mEuro)", club_basic_expend$Year, FUN = scale)

chart.Correlation(
  club_basic_expend[c("Rk", "Pts", "W", "D", "L", "GF", "GA", "GD", "Expenditure(mEuro)", "Arrivals", "Income(mEuro)", "Departures", "Balance(mEuro)")],
  histogram = TRUE
)

#--------------
# Conclusion 4: Expenditure and Income have relevant correlation with the performance.
#--------------

#----------------------------------------------------------------
# Analyzing the influence of last season in the current season results.

season_basics_00_22 <- left_join(
  season_basics_00_22 %>% filter(Year > "2009"),
  season_basics_00_22[, c("Year", "Club", "Rk", "W", "D", "L", "GF", "GA", "GD", "Pts")] %>% mutate(
    Year = Year + 1,
    RkLast = Rk,
    Rk = NULL,
    WLast = W,
    W = NULL,
    DLast = D,
    D = NULL,
    LLast = L,
    L = NULL,
    GFLast = GF,
    GF = NULL,
    GALast = GA,
    GA = NULL,
    GDLast = GD,
    GD = NULL,
    PtsLast = Pts,
    Pts = NULL
  ),
  by = c("Year", "Club")
)

chart.Correlation(
  season_basics_00_22[c("Rk", "Pts", "W", "D", "L", "GF", "GA", "GD", "RkLast", "WLast", "DLast", "LLast", "GFLast", "GALast", "GDLast", "PtsLast")],
  histogram = TRUE
)

#--------------
# Conclusion 5: There is correlation between two adjacent seasons
#--------------
# Trying: Gives ranking 18 and mean of 10 last teams in variables to season promoted teams (because their performance is usually poor)

# Justifying sentence Performance of promoted teams is poor.
promoted_performance <- data.frame(
  Max = max((filter(season_basics_00_22, is.na(RkLast)))$Rk),
  Min = min((filter(season_basics_00_22, is.na(RkLast)))$Rk),
  Mean = mean((filter(season_basics_00_22, is.na(RkLast)))$Rk),
  Median = median((filter(season_basics_00_22, is.na(RkLast)))$Rk)
)

kable(promoted_performance) %>%
  kable_styling(
    bootstrap_options = "striped",
    full_width = F,
    font_size = 19
  )

season_basics_00_22 <- left_join(season_basics_00_22,
  filter(season_basics_00_22, Rk > 10) %>% group_by(Year) %>% summarise_at(c("WLast", "DLast", "LLast", "GFLast", "GALast", "GDLast", "PtsLast"),
    mean,
    na.rm = TRUE
  ) %>% rename("WMean" = "WLast", "DMean" = "DLast", "LMean" = "LLast", "GFMean" = "GFLast", "GAMean" = "GALast", "GDMean" = "GDLast", "PtsMean" = "PtsLast") %>% mutate_all(as.integer),
  by = c("Year")
) %>% mutate(
  WLast = coalesce(WLast, WMean),
  DLast = coalesce(DLast, DMean),
  LLast = coalesce(LLast, LMean),
  GFLast = coalesce(GFLast, GFMean),
  GALast = coalesce(GALast, GAMean),
  GDLast = coalesce(GDLast, GDMean),
  PtsLast = coalesce(PtsLast, PtsMean),
  RkLast = coalesce(RkLast, 16),
  WMean = NULL,
  DMean = NULL,
  LMean = NULL,
  GFMean = NULL,
  GAMean = NULL,
  GDMean = NULL,
  PtsMean = NULL
)

chart.Correlation(
  season_basics_00_22[c("Rk", "Pts", "W", "D", "L", "GF", "GA", "GD", "RkLast", "WLast", "DLast", "LLast", "GFLast", "GALast", "GDLast", "PtsLast")],
  histogram = TRUE
)

#--------------
# Conclusion 6: Rank as 18 for promoted clubs improves the correlation.
#----------------------------------------------------------------
