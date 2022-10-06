
from inspect import trace
from numpy import equal
import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
import time


def currencyStringCleanup(value):
    if(value == '-'):
        return '0'
    value2 = re.sub(r'€(-?\d*\.?\d*)m', r'\1', value)
    return re.sub(r'€(-?)(\d+)Th\.', r'\g<1>0.\2', value2)


base_url = 'https://fbref.com'

next_year_url = '/en/comps/9/47/2000-2001-Premier-League-Stats'

# Declaring data objects
league_data = []
home_away_data = []
squad_data = []
o_squad_data = []
goalkeeping_data = []
opponent_goalkeeping_data = []
shooting_data = []

for year in range(2000, 2022):
    print('Getting data for year {}..'.format(year))

    soup = BeautifulSoup(requests.get(
        base_url + next_year_url).content, 'html.parser')

    next_year_url = soup.select(
        'div#info > div#meta > div > div.prevnext > .next')[0]['href']

    stats_resultset = soup.select(
        'div#content > .table_wrapper > div > div > table')

    # League data
    for tr in stats_resultset[0].select('tbody > tr'):
        league_data.append({
            'Season': f'{year}-{year+1}',
            'Position': tr.find('th', {"data-stat": "rank"}).get_text(strip=True),
            'Club': tr.find('td', {"data-stat": "squad"}).get_text(strip=True),
            'games': tr.find('td', {"data-stat": "games"}).get_text(strip=True),
            'wins': tr.find('td', {"data-stat": "wins"}).get_text(strip=True),
            'draws': tr.find('td', {"data-stat": "draws"}).get_text(strip=True),
            'losses': tr.find('td', {"data-stat": "losses"}).get_text(strip=True),
            'goals_for': tr.find('td', {"data-stat": "goals_for"}).get_text(strip=True),
            'goals_against': tr.find('td', {"data-stat": "goals_against"}).get_text(strip=True),
            'goal_diff': tr.find('td', {"data-stat": "goal_diff"}).get_text(strip=True),
            'points': tr.find('td', {"data-stat": "points"}).get_text(strip=True),
            'points_avg': tr.find('td', {"data-stat": "points_avg"}).get_text(strip=True),
            'xg_for': '' if tr.find('td', {"data-stat": "xg_for"}) == None else tr.find('td', {"data-stat": "xg_for"}).get_text(strip=True),
            'xg_against': '' if tr.find('td', {"data-stat": "xg_against"}) == None else tr.find('td', {"data-stat": "xg_against"}).get_text(strip=True),
            'xg_diff': '' if tr.find('td', {"data-stat": "xg_diff"}) == None else tr.find('td', {"data-stat": "xg_diff"}).get_text(strip=True),
            'xg_diff_per90': '' if tr.find('td', {"data-stat": "xg_diff_per90"}) == None else tr.find('td', {"data-stat": "xg_diff_per90"}).get_text(strip=True)
        })

    # Home - Away data
    for tr in stats_resultset[1].select('tbody > tr'):
        home_away_data.append({
            'Season': f'{year}-{year+1}',
            'Position': tr.find('th', {"data-stat": "rank"}).get_text(strip=True),
            'Club': tr.find('td', {"data-stat": "squad"}).get_text(strip=True),
            'games_home': tr.find('td', {"data-stat": "games_home"}).get_text(strip=True),
            'wins_home': tr.find('td', {"data-stat": "wins_home"}).get_text(strip=True),
            'draws_home': tr.find('td', {"data-stat": "draws_home"}).get_text(strip=True),
            'losses_home': tr.find('td', {"data-stat": "losses_home"}).get_text(strip=True),
            'goals_for_home': tr.find('td', {"data-stat": "goals_for_home"}).get_text(strip=True),
            'goals_against_home': tr.find('td', {"data-stat": "goals_against_home"}).get_text(strip=True),
            'goal_diff_home': tr.find('td', {"data-stat": "goal_diff_home"}).get_text(strip=True),
            'points_home': tr.find('td', {"data-stat": "points_home"}).get_text(strip=True),
            'points_avg_home': tr.find('td', {"data-stat": "points_avg_home"}).get_text(strip=True),
            'xg_for_home': '' if tr.find('td', {"data-stat": "xg_for_home"}) == None else tr.find('td', {"data-stat": "xg_for_home"}).get_text(strip=True),
            'xg_for_home': '' if tr.find('td', {"data-stat": "xg_for_home"}) == None else tr.find('td', {"data-stat": "xg_for_home"}).get_text(strip=True),
            'xg_for_home': '' if tr.find('td', {"data-stat": "xg_for_home"}) == None else tr.find('td', {"data-stat": "xg_for_home"}).get_text(strip=True),
            'games_away': tr.find('td', {"data-stat": "games_away"}).get_text(strip=True),
            'wins_away': tr.find('td', {"data-stat": "wins_away"}).get_text(strip=True),
            'draws_away': tr.find('td', {"data-stat": "draws_away"}).get_text(strip=True),
            'losses_away': tr.find('td', {"data-stat": "losses_away"}).get_text(strip=True),
            'goals_for_away': tr.find('td', {"data-stat": "goals_for_away"}).get_text(strip=True),
            'goals_against_away': tr.find('td', {"data-stat": "goals_against_away"}).get_text(strip=True),
            'goal_diff_away': tr.find('td', {"data-stat": "goal_diff_away"}).get_text(strip=True),
            'points_away': tr.find('td', {"data-stat": "points_away"}).get_text(strip=True),
            'points_avg_away': tr.find('td', {"data-stat": "points_avg_away"}).get_text(strip=True),
            'xg_for_away': '' if tr.find('td', {"data-stat": "xg_for_away"}) == None else tr.find('td', {"data-stat": "xg_for_away"}).get_text(strip=True),
            'xg_against_away': '' if tr.find('td', {"data-stat": "xg_against_away"}) == None else tr.find('td', {"data-stat": "xg_against_away"}).get_text(strip=True),
            'xg_for_away': '' if tr.find('td', {"data-stat": "xg_for_away"}) == None else tr.find('td', {"data-stat": "xg_for_away"}).get_text(strip=True)
        })

    # Squad data
    for tr in stats_resultset[2].select('tbody > tr'):
        squad_data.append({
            'Season': f'{year}-{year+1}',
            'Club': tr.find('th', {"data-stat": "squad"}).get_text(strip=True),
            'players_used': tr.find('td', {"data-stat": "players_used"}).get_text(strip=True),
            'avg_age': tr.find('td', {"data-stat": "avg_age"}).get_text(strip=True),
            'possession': tr.find('td', {"data-stat": "possession"}).get_text(strip=True),
            # 'games': tr.find('td', {"data-stat": "games"}).get_text(strip=True),
            'games_starts': tr.find('td', {"data-stat": "games_starts"}).get_text(strip=True),
            'minutes': tr.find('td', {"data-stat": "minutes"}).get_text(strip=True),
            'minutes_90s': tr.find('td', {"data-stat": "minutes_90s"}).get_text(strip=True),
            'goals': tr.find('td', {"data-stat": "goals"}).get_text(strip=True),
            'assists': tr.find('td', {"data-stat": "assists"}).get_text(strip=True),
            'goals_pens': tr.find('td', {"data-stat": "goals_pens"}).get_text(strip=True),
            'pens_made': tr.find('td', {"data-stat": "pens_made"}).get_text(strip=True),
            'pens_att': tr.find('td', {"data-stat": "pens_att"}).get_text(strip=True),
            'cards_yellow': tr.find('td', {"data-stat": "cards_yellow"}).get_text(strip=True),
            'cards_red': tr.find('td', {"data-stat": "cards_red"}).get_text(strip=True),
            'goals_per90': tr.find('td', {"data-stat": "goals_per90"}).get_text(strip=True),
            'assists_per90': tr.find('td', {"data-stat": "assists_per90"}).get_text(strip=True),
            'goals_assists_per90': tr.find('td', {"data-stat": "goals_assists_per90"}).get_text(strip=True),
            'goals_pens_per90': tr.find('td', {"data-stat": "goals_pens_per90"}).get_text(strip=True),
            'goals_assists_pens_per90': tr.find('td', {"data-stat": "goals_assists_pens_per90"}).get_text(strip=True),
            'xg': '' if tr.find('td', {"data-stat": "xg"}) == None else tr.find('td', {"data-stat": "xg"}).get_text(strip=True),
            'npxg': '' if tr.find('td', {"data-stat": "npxg"}) == None else tr.find('td', {"data-stat": "npxg"}).get_text(strip=True),
            'xa': '' if tr.find('td', {"data-stat": "xa"}) == None else tr.find('td', {"data-stat": "xa"}).get_text(strip=True),
            'npxg_xa': '' if tr.find('td', {"data-stat": "npxg_xa"}) == None else tr.find('td', {"data-stat": "npxg_xa"}).get_text(strip=True),
            'xg_per90': '' if tr.find('td', {"data-stat": "xg_per90"}) == None else tr.find('td', {"data-stat": "xg_per90"}).get_text(strip=True),
            'xa_per90': '' if tr.find('td', {"data-stat": "xa_per90"}) == None else tr.find('td', {"data-stat": "xa_per90"}).get_text(strip=True),
            'xg_xa_per90': '' if tr.find('td', {"data-stat": "xg_xa_per90"}) == None else tr.find('td', {"data-stat": "xg_xa_per90"}).get_text(strip=True),
            'npxg_per90': '' if tr.find('td', {"data-stat": "npxg_per90"}) == None else tr.find('td', {"data-stat": "npxg_per90"}).get_text(strip=True),
            'npxg_xa_per90': '' if tr.find('td', {"data-stat": "npxg_xa_per90"}) == None else tr.find('td', {"data-stat": "npxg_xa_per90"}).get_text(strip=True)
        })

    # Opponent squad data
    for tr in stats_resultset[3].select('tbody > tr'):
        o_squad_data.append({
            'Season': f'{year}-{year+1}',
            'Club': tr.find('th', {"data-stat": "squad"}).get_text(strip=True).replace('vs ', ''),
            'o_players_used': tr.find('td', {"data-stat": "players_used"}).get_text(strip=True),
            'o_avg_age': tr.find('td', {"data-stat": "avg_age"}).get_text(strip=True),
            'o_possession': tr.find('td', {"data-stat": "possession"}).get_text(strip=True),
            # 'o_games': tr.find('td', {"data-stat": "games"}).get_text(strip=True),
            'o_games_starts': tr.find('td', {"data-stat": "games_starts"}).get_text(strip=True),
            'o_minutes': tr.find('td', {"data-stat": "minutes"}).get_text(strip=True),
            'o_minutes_90s': tr.find('td', {"data-stat": "minutes_90s"}).get_text(strip=True),
            'o_goals': tr.find('td', {"data-stat": "goals"}).get_text(strip=True),
            'o_assists': tr.find('td', {"data-stat": "assists"}).get_text(strip=True),
            'o_goals_pens': tr.find('td', {"data-stat": "goals_pens"}).get_text(strip=True),
            'o_pens_made': tr.find('td', {"data-stat": "pens_made"}).get_text(strip=True),
            'o_pens_att': tr.find('td', {"data-stat": "pens_att"}).get_text(strip=True),
            'o_cards_yellow': tr.find('td', {"data-stat": "cards_yellow"}).get_text(strip=True),
            'o_cards_red': tr.find('td', {"data-stat": "cards_red"}).get_text(strip=True),
            'o_goals_per90': tr.find('td', {"data-stat": "goals_per90"}).get_text(strip=True),
            'o_assists_per90': tr.find('td', {"data-stat": "assists_per90"}).get_text(strip=True),
            'o_goals_assists_per90': tr.find('td', {"data-stat": "goals_assists_per90"}).get_text(strip=True),
            'o_goals_pens_per90': tr.find('td', {"data-stat": "goals_pens_per90"}).get_text(strip=True),
            'o_goals_assists_pens_per90': tr.find('td', {"data-stat": "goals_assists_pens_per90"}).get_text(strip=True),
            'o_xg': '' if tr.find('td', {"data-stat": "xg"}) == None else tr.find('td', {"data-stat": "xg"}).get_text(strip=True),
            'o_npxg': '' if tr.find('td', {"data-stat": "npxg"}) == None else tr.find('td', {"data-stat": "npxg"}).get_text(strip=True),
            'o_xa': '' if tr.find('td', {"data-stat": "xa"}) == None else tr.find('td', {"data-stat": "xa"}).get_text(strip=True),
            'o_npxg_xa': '' if tr.find('td', {"data-stat": "npxg_xa"}) == None else tr.find('td', {"data-stat": "npxg_xa"}).get_text(strip=True),
            'o_xg_per90': '' if tr.find('td', {"data-stat": "xg_per90"}) == None else tr.find('td', {"data-stat": "xg_per90"}).get_text(strip=True),
            'o_xa_per90': '' if tr.find('td', {"data-stat": "xa_per90"}) == None else tr.find('td', {"data-stat": "xa_per90"}).get_text(strip=True),
            'o_xg_xa_per90': '' if tr.find('td', {"data-stat": "xg_xa_per90"}) == None else tr.find('td', {"data-stat": "xg_xa_per90"}).get_text(strip=True),
            'o_npxg_per90': '' if tr.find('td', {"data-stat": "npxg_per90"}) == None else tr.find('td', {"data-stat": "npxg_per90"}).get_text(strip=True),
            'o_npxg_xa_per90': '' if tr.find('td', {"data-stat": "npxg_xa_per90"}) == None else tr.find('td', {"data-stat": "npxg_xa_per90"}).get_text(strip=True)
        })

    # Goalkeping data
    for tr in stats_resultset[4].select('tbody > tr'):
        goalkeeping_data.append({
            'Season': f'{year}-{year+1}',
            'Club': tr.find('th', {"data-stat": "squad"}).get_text(strip=True),
            'gk_players_used': tr.find('td', {"data-stat": "players_used"}).get_text(strip=True),
            # 'gk_games': tr.find('td', {"data-stat": "games_gk"}).get_text(strip=True),
            # 'gk_games_starts': tr.find('td', {"data-stat": "games_starts_gk"}).get_text(strip=True),
            'gk_minutes': tr.find('td', {"data-stat": "minutes_gk"}).get_text(strip=True).replace(',', ''),
            'gk_minutes_90s': tr.find('td', {"data-stat": "minutes_90s"}).get_text(strip=True),
            'gk_goals_against': tr.find('td', {"data-stat": "goals_against_gk"}).get_text(strip=True),
            'gk_goals_against_per90': tr.find('td', {"data-stat": "goals_against_per90_gk"}).get_text(strip=True),
            'gk_shots_on_target_against': tr.find('td', {"data-stat": "shots_on_target_against"}).get_text(strip=True),
            'gk_saves': tr.find('td', {"data-stat": "saves"}).get_text(strip=True),
            'gk_save_pct': tr.find('td', {"data-stat": "save_pct"}).get_text(strip=True),
            'gk_wins': tr.find('td', {"data-stat": "wins_gk"}).get_text(strip=True),
            'gk_draws': tr.find('td', {"data-stat": "draws_gk"}).get_text(strip=True),
            'gk_losses': tr.find('td', {"data-stat": "losses_gk"}).get_text(strip=True),
            'gk_clean_sheets': tr.find('td', {"data-stat": "clean_sheets"}).get_text(strip=True),
            'gk_clean_sheets_pct': tr.find('td', {"data-stat": "clean_sheets_pct"}).get_text(strip=True),
            'gk_pens_att_gk': tr.find('td', {"data-stat": "pens_att_gk"}).get_text(strip=True),
            'gk_pens_allowed': tr.find('td', {"data-stat": "pens_allowed"}).get_text(strip=True),
            'gk_pens_saved': tr.find('td', {"data-stat": "pens_saved"}).get_text(strip=True),
            'gk_pens_missed': tr.find('td', {"data-stat": "pens_missed_gk"}).get_text(strip=True),
            'gk_pens_save_pct': tr.find('td', {"data-stat": "pens_save_pct"}).get_text(strip=True)
        })

    # Opponent goalkeeping data
    for tr in stats_resultset[5].select('tbody > tr'):
        opponent_goalkeeping_data.append({
            'Season': f'{year}-{year+1}',
            'Club': tr.find('th', {"data-stat": "squad"}).get_text(strip=True).replace('vs ', ''),
            'o_gk_players_used': tr.find('td', {"data-stat": "players_used"}).get_text(strip=True),
            # 'o_gk_games': tr.find('td', {"data-stat": "games_gk"}).get_text(strip=True),
            # 'o_gk_games_starts': tr.find('td', {"data-stat": "games_starts_gk"}).get_text(strip=True),
            'o_gk_minutes': tr.find('td', {"data-stat": "minutes_gk"}).get_text(strip=True).replace(',', ''),
            'o_gk_minutes_90s': tr.find('td', {"data-stat": "minutes_90s"}).get_text(strip=True),
            'o_gk_goals_against': tr.find('td', {"data-stat": "goals_against_gk"}).get_text(strip=True),
            'o_gk_goals_against_per90': tr.find('td', {"data-stat": "goals_against_per90_gk"}).get_text(strip=True),
            'o_gk_shots_on_target_against': tr.find('td', {"data-stat": "shots_on_target_against"}).get_text(strip=True),
            'o_gk_saves': tr.find('td', {"data-stat": "saves"}).get_text(strip=True),
            'o_gk_save_pct': tr.find('td', {"data-stat": "save_pct"}).get_text(strip=True),
            'o_gk_wins': tr.find('td', {"data-stat": "wins_gk"}).get_text(strip=True),
            'o_gk_draws': tr.find('td', {"data-stat": "draws_gk"}).get_text(strip=True),
            'o_gk_losses': tr.find('td', {"data-stat": "losses_gk"}).get_text(strip=True),
            'o_gk_clean_sheets': tr.find('td', {"data-stat": "clean_sheets"}).get_text(strip=True),
            'o_gk_clean_sheets_pct': tr.find('td', {"data-stat": "clean_sheets_pct"}).get_text(strip=True),
            'o_gk_pens_att_gk': tr.find('td', {"data-stat": "pens_att_gk"}).get_text(strip=True),
            'o_gk_pens_allowed': tr.find('td', {"data-stat": "pens_allowed"}).get_text(strip=True),
            'o_gk_pens_saved': tr.find('td', {"data-stat": "pens_saved"}).get_text(strip=True),
            'o_gk_pens_missed': tr.find('td', {"data-stat": "pens_missed_gk"}).get_text(strip=True),
            'o_gk_pens_save_pct': tr.find('td', {"data-stat": "pens_save_pct"}).get_text(strip=True)
        })

    # Shooting data
    for tr in soup.select('div#content > div#all_stats_squads_shooting > div > div#div_stats_squads_shooting_for > table > tbody > tr'):
        shooting_data.append({
            'Season': f'{year}-{year+1}',
            'Club': tr.find('th', {"data-stat": "squad"}).get_text(strip=True),
            # 'goals': tr.find('td', {"data-stat": "goals"}).get_text(strip=True),
            'shots_on_target': tr.find('td', {"data-stat": "shots_on_target"}).get_text(strip=True),
            'shots_on_target_per90': tr.find('td', {"data-stat": "shots_on_target_per90"}).get_text(strip=True)
            # 'pens_made': tr.find('td', {"data-stat": "pens_made"}).get_text(strip=True).replace(',', ''),
            # 'pens_att': tr.find('td', {"data-stat": "pens_att"}).get_text(strip=True)
        })

    time.sleep(4)

league_data_df = pd.DataFrame(league_data).reset_index(drop=True)
league_data_df.to_csv(f'LEAGUE.csv', index=False)

home_away_data_df = pd.DataFrame(home_away_data).reset_index(drop=True)
home_away_data_df.to_csv(f'LEAGUE_HOME_AWAY.csv', index=False)

squad_data_df = pd.DataFrame(squad_data).reset_index(drop=True)
squad_data_df.to_csv(f'SQUAD.csv', index=False)

o_squad_data_df = pd.DataFrame(o_squad_data).reset_index(drop=True)
o_squad_data_df.to_csv(f'O_SQUAD.csv', index=False)

gk_data_df = pd.DataFrame(goalkeeping_data).reset_index(drop=True)
gk_data_df.to_csv(f'GK.csv', index=False)

o_gk_data_df = pd.DataFrame(opponent_goalkeeping_data).reset_index(drop=True)
o_gk_data_df.to_csv(f'O_GK.csv', index=False)

shooting_data_df = pd.DataFrame(shooting_data).reset_index(drop=True)
shooting_data_df.to_csv(f'SHOOTING.csv', index=False)
