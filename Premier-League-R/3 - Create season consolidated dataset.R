# Season consolidated dataset creation

library("lubridate")
library("tidyverse")

#----------------------------------------------------------------

load('RData/season_basics_00_22.RData')

load("RData/club_finances_10_22.RData")

load('RData/club_seasonal_expenditure_00_22.RData')

load('RData/club_squad_mkt_value_10_22.RData')

#----------------------------------------------------------------

club_squad_mkt_value_beg_season <- filter(
  club_squad_mkt_value_10_22[, c("Year", "Club", "Value(mEuro)", "Current value(mEuro)", "Variation(%)")], 
  month(club_squad_mkt_value_10_22$Date) == "11" & year(club_squad_mkt_value_10_22$Date) != "2022"
) %>% union(filter(club_squad_mkt_value_10_22[, c("Year", "Club", "Value(mEuro)", "Current value(mEuro)", "Variation(%)")]
                   , month(club_squad_mkt_value_10_22$Date) == "7" & year(club_squad_mkt_value_10_22$Date) == "2022"))



season_consolidated_10_22 <- left_join(
  filter(season_basics_00_22, Year > "2009"),
  club_squad_mkt_value_beg_season,
  by = c("Year", "Club")
) %>% left_join(
  club_finances_10_22[, c("Year", "Club", "Turnover £m", "Wage Bill £m")],  
  by = c("Year", "Club")
) %>% left_join(
      club_seasonal_expenditure_00_22[c("Year","Club","Expenditure(mEuro)","Arrivals","Income(mEuro)","Departures","Balance(mEuro)")],  
      by = c("Year", "Club")
    )


season_consolidated_10_22$`MktValue` <- ave(season_consolidated_10_22$`Value(mEuro)`, season_consolidated_10_22$Year, FUN=scale)

season_consolidated_10_22$`Turnover` <- ave(season_consolidated_10_22$`Turnover £m`, season_consolidated_10_22$Year, FUN=scale)

season_consolidated_10_22$`WageBill` <- ave(season_consolidated_10_22$`Wage Bill £m`, season_consolidated_10_22$Year, FUN=scale)

season_consolidated_10_22$"Expenditure" <- ave(season_consolidated_10_22$"Expenditure(mEuro)", season_consolidated_10_22$Year, FUN=scale)

season_consolidated_10_22$"Income" <- ave(season_consolidated_10_22$"Income(mEuro)", season_consolidated_10_22$Year, FUN=scale)

season_consolidated_10_22$"Balance" <- ave(season_consolidated_10_22$"Balance(mEuro)", season_consolidated_10_22$Year, FUN=scale)

season_consolidated_10_22 <- season_consolidated_10_22 %>% mutate("Value(mEuro)" = NULL,
                                                                  "Turnover £m" = NULL,
                                                                  "Wage Bill £m" = NULL,
                                                                  "Expenditure(mEuro)" = NULL,
                                                                  "Income(mEuro)" = NULL,
                                                                  "Balance(mEuro)" = NULL,
                                                                  "Variation(%)" = NULL)


season_consolidated_10_22 <- left_join(
  season_consolidated_10_22,
  season_basics_00_22[, c("Year", "Club", "Rk",  "W", "D", "L","GF","GA","GD","Pts")] %>% mutate(Year = Year + 1, 

                                                                                                 RkLast = coalesce(Rk,18),
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
) %>% mutate("Attendance" = NULL,
             "AvgAge" = avg_age,
             avg_age = NULL,
             "Current value(mEuro)" = NULL)


season_consolidated_10_22 <- left_join(season_consolidated_10_22, 
                                 filter(season_consolidated_10_22, Rk > 10) %>% group_by(Year
                                 ) %>% summarise_at(c("WLast","DLast","LLast","GFLast","GALast","GDLast","PtsLast"), 
                                                    mean, 
                                                    na.rm = TRUE
                                 ) %>% rename("WMean"="WLast","DMean"="DLast","LMean"="LLast","GFMean"="GFLast","GAMean"="GALast","GDMean"="GDLast","PtsMean"="PtsLast"
                                 ) %>% mutate_all(as.integer)
                                 , by = c("Year")
) %>% mutate(WLast = coalesce(WLast,WMean),
             DLast = coalesce(DLast,DMean),
             LLast = coalesce(LLast,LMean),
             GFLast = coalesce(GFLast,GFMean),
             GALast = coalesce(GALast,GAMean),
             GDLast = coalesce(GDLast,GDMean),
             PtsLast = coalesce(PtsLast,PtsMean),
             RkLast = coalesce(RkLast,18),
             WMean=NULL,
             DMean=NULL,
             LMean=NULL,
             GFMean=NULL,
             GAMean=NULL,
             GDMean=NULL,
             PtsMean=NULL)


save(season_consolidated_10_22, file = "RData/season_consolidated_10_22.RData")

#----------------------------------------------------------------

season_consolidated_00_22 <- left_join(
  season_basics_00_22,
  club_seasonal_expenditure_00_22[c("Year","Club","Expenditure(mEuro)","Arrivals","Income(mEuro)","Departures","Balance(mEuro)")],  
  by = c("Year", "Club")
)

season_consolidated_00_22$"Expenditure" <- ave(season_consolidated_00_22$"Expenditure(mEuro)", season_consolidated_00_22$Year, FUN=scale)

season_consolidated_00_22$"Income" <- ave(season_consolidated_00_22$"Income(mEuro)", season_consolidated_00_22$Year, FUN=scale)

season_consolidated_00_22$"Balance" <- ave(season_consolidated_00_22$"Balance(mEuro)", season_consolidated_00_22$Year, FUN=scale)

season_consolidated_00_22 <- season_consolidated_00_22 %>% mutate("Expenditure(mEuro)" = NULL,
                                                                  "Income(mEuro)" = NULL,
                                                                  "Balance(mEuro)" = NULL,
                                                                  )

season_consolidated_00_22 <-  left_join(
  season_consolidated_00_22,
  season_basics_00_22[, c("Year", "Club", "Rk",  "W", "D", "L","GF","GA","GD","Pts")] %>% mutate(
            Year = Year + 1,
            RkLast = coalesce(Rk,18),
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
) %>% mutate("Attendance" = NULL,
             "AvgAge" = avg_age,
             avg_age = NULL,
             "Current value(mEuro)" = NULL)



season_consolidated_00_22 <- left_join(season_consolidated_00_22, 
                                       filter(season_consolidated_00_22, Rk > 10) %>% group_by(Year
                                       ) %>% summarise_at(c("WLast","DLast","LLast","GFLast","GALast","GDLast","PtsLast"), 
                                                          mean, 
                                                          na.rm = TRUE
                                       ) %>% rename("WMean"="WLast","DMean"="DLast","LMean"="LLast","GFMean"="GFLast","GAMean"="GALast","GDMean"="GDLast","PtsMean"="PtsLast"
                                       ) %>% mutate_all(as.integer)
                                       , by = c("Year")
) %>% mutate(WLast = coalesce(WLast,WMean),
             DLast = coalesce(DLast,DMean),
             LLast = coalesce(LLast,LMean),
             GFLast = coalesce(GFLast,GFMean),
             GALast = coalesce(GALast,GAMean),
             GDLast = coalesce(GDLast,GDMean),
             PtsLast = coalesce(PtsLast,PtsMean),
             RkLast = coalesce(RkLast,16),
             WMean=NULL,
             DMean=NULL,
             LMean=NULL,
             GFMean=NULL,
             GAMean=NULL,
             GDMean=NULL,
             PtsMean=NULL)  


save(season_consolidated_00_22, file = "RData/season_consolidated_00_22.RData")
