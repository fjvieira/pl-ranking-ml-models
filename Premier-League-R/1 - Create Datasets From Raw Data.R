# This script is used to recreate datasets as .RData files in case a new extraction is provided.

library(readr)
library("tidyverse")


#### Team names site relations.

teams_name_matches <- read_delim(
  file = "RAW_DATA/teams-name-matches.csv",
  delim = ",",
  escape_double = FALSE,
  trim_ws = TRUE
)

#### Seasonal data from fbref.com

fbref_com_league <- read_delim(
  file = "RAW_DATA/fbref.com_LEAGUE.csv",
  delim = ",",
  col_types = cols(
    .default = "d",
    Season = "c",
    Club = "c"
  ),
  escape_double = FALSE,
  trim_ws = TRUE
)

fbref_com_league_ha <- read_delim(
  file = "RAW_DATA/fbref.com_LEAGUE_HOME_AWAY.csv",
  delim = ",",
  col_types = cols(
    .default = "d",
    Season = "c",
    Club = "c"
  ),
  escape_double = FALSE,
  trim_ws = TRUE
)

fbref_com_squad <- read_delim(
  file = "RAW_DATA/fbref.com_SQUAD.csv",
  delim = ",",
  col_types = cols(
    .default = "d",
    Season = "c",
    Club = "c"
  ),
  escape_double = FALSE,
  trim_ws = TRUE
)

fbref_com_o_squad <- read_delim(
  file = "RAW_DATA/fbref.com_O_SQUAD.csv",
  delim = ",",
  col_types = cols(
    .default = "d",
    Season = "c",
    Club = "c"
  ),
  escape_double = FALSE,
  trim_ws = TRUE
)

fbref_com_league_gk <- read_delim(
  file = "RAW_DATA/fbref.com_GK.csv",
  delim = ",",
  col_types = cols(
    .default = "d",
    Season = "c",
    Club = "c"
  ),
  escape_double = FALSE,
  trim_ws = TRUE
)

fbref_com_league_o_gk <- read_delim(
  file = "RAW_DATA/fbref.com_O_GK.csv",
  delim = ",",
  col_types = cols(
    .default = "d",
    Season = "c",
    Club = "c"
  ),
  escape_double = FALSE,
  trim_ws = TRUE
)

fbref_com_league_shooting <- read_delim(
  file = "RAW_DATA/fbref.com_SHOOTING.csv",
  delim = ",",
  col_types = cols(
    .default = "d",
    Season = "c",
    Club = "c"
  ),
  escape_double = FALSE,
  trim_ws = TRUE
)


season_00_22 <- left_join(
  fbref_com_league,
  fbref_com_league_ha,
  by = c("Season", "Club", "Position")
) %>%
  left_join(
    fbref_com_squad,
    by = c("Season", "Club")
  ) %>%
  left_join(
    fbref_com_o_squad,
    by = c("Season", "Club")
  ) %>%
  left_join(
    fbref_com_league_gk,
    by = c("Season", "Club")
  ) %>%
  left_join(
    fbref_com_league_o_gk,
    by = c("Season", "Club")
  ) %>%
  left_join(
    fbref_com_league_shooting,
    by = c("Season", "Club")
  ) %>%
  left_join(
    select(teams_name_matches, c(Tfmkt, fbref)),
    by = c("Club" = "fbref")
  ) %>%
  mutate(
    "Club" = Tfmkt,
    fbref = NULL,
    Tfmkt = NULL,
    "Year" = as.integer(substr(Season, 1, 4))
  ) %>%
  relocate("Year")

save(season_00_22, file = "RData/season_00_22.RData")

fbref_com <- read_delim(
  file = "RAW_DATA/fbref.com.csv",
  delim = ",",
  col_types = cols(
    .default = "d",
    Season = "c",
    Squad = "c"
  ),
  escape_double = FALSE,
  trim_ws = TRUE
)

season_basics_00_22 <- left_join(
  fbref_com,
  select(teams_name_matches, c(Tfmkt, fbref)),
  by = c("Squad" = "fbref")
) %>%
  mutate(
    "Squad" = Tfmkt,
    fbref = NULL,
    Tfmkt = NULL,
    Year = as.integer(substr(Season, 1, 4))
  ) %>%
  rename("Club" = "Squad") %>%
  relocate("Year") %>%
  left_join(season_00_22[, c("Year", "Club", "avg_age")], 
  by = c("Year", "Club"))

save(season_basics_00_22, file = "RData/season_basics_00_22.RData")

#### Matches data from football-data.co.uk

football_data_co_uk <- read_delim(
  file = "RAW_DATA/football-data.co.uk.csv",
  delim = ",",
  escape_double = FALSE,
  trim_ws = TRUE
)

match_results_00_22 <- left_join(
  football_data_co_uk,
  select(teams_name_matches, c(football_data, Tfmkt)),
  by = c("HomeTeam" = "football_data")
) %>%
  mutate(
    "HomeTeam" = Tfmkt,
    footbaall_data = NULL,
    Tfmkt = NULL
  ) %>%
  left_join(
    select(teams_name_matches, c(football_data, Tfmkt)),
    by = c("AwayTeam" = "football_data")
  ) %>%
  mutate(
    "AwayTeam" = Tfmkt,
    football_data = NULL,
    Tfmkt = NULL
  ) %>%
  rename(
    "AwayClub" = "AwayTeam",
    "HomeClub" = "HomeTeam"
  )

save(match_results_00_22, file = "RData/match_results_00_22.RData")

##### Club expenditure from TransferMarket.com

club_seasonal_expenditure_00_22 <-
  read_delim(
    file = "RAW_DATA/transfermarkt.com-expenditure.csv",
    delim = ",",
    escape_double = FALSE,
    trim_ws = TRUE
  ) %>%
  mutate(
    Year = as.integer(substr(Season, 1, 4)),
    Competition = NULL
  ) %>%
  relocate("Year")

save(club_seasonal_expenditure_00_22, file = "RData/club_seasonal_expenditure_00_22.RData")

##### Club squad market value from TransferMarket.com

club_squad_mkt_value_10_22 <-
  read_delim(
    file = "RAW_DATA/transfermarkt.com-market-value-change.csv",
    delim = ",",
    escape_double = FALSE,
    trim_ws = TRUE
  )

club_squad_mkt_value_10_22$Date <- as.Date(club_squad_mkt_value_10_22$Date, format = "%Y-%m-%d")

save(club_squad_mkt_value_10_22, file = "RData/club_squad_mkt_value_10_22.RData")

##### Club turnover and wages from multi collected sources


club_finances_10_22 <-
  read_delim(
    file = "RAW_DATA/premier_league_finances_2009-2021.csv",
    delim = ",",
    escape_double = FALSE,
    trim_ws = TRUE
  ) %>%
  mutate("Year" = as.integer(substr(Season, 1, 4))) %>%
  relocate("Year")

save(club_finances_10_22, file = "RData/club_finances_10_22.RData")
