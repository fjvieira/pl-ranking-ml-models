
from inspect import trace
import requests
import pandas as pd
import re
import time


def currencyStringCleanup(value):
    if(value == '-'):
        return '0'
    if 'bn' in value:
        return str(float(re.sub(r'€(-?\d*\.?\d*)bn', r'\1', value)) * 1000)
    value2 = re.sub(r'€(-?\d*\.?\d*)m', r'\1', value)
    return re.sub(r'€(-?)(\d+)Th\.', r'\g<1>0.\2', value2)


headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.0.0 Safari/537.36'}

data = []

# https://api.sofascore.com/api/v1/unique-tournament/17/seasons
# Scores avaliable from 2016 to present

season_ids = {'2021': 37036, '2020': 29415, '2019': 23776, '2018': 17359, '2017': 13380, '2016': 11733}

for year, seasonId in season_ids.items():
    print('Getting data for year {}..'.format(year))
    
    #Get the list of teams for a season
    season_response = requests.get(
        f'https://api.sofascore.com/api/v1/unique-tournament/17/season/{seasonId}/standings/total')

    # For each team, get the statistics
    for team in season_response.json()["standings"][0]["rows"]:
        team_id = team["team"]["id"]

        team_response = requests.get(
            f'https://api.sofascore.com/api/v1/team/{team_id}/unique-tournament/17/season/{seasonId}/statistics/overall').json()

        data.append({
            'Year': year,
            'Season': f'{year}-{int(year)+1}',
            'Club': team["team"]["name"],
            'goalsScored': team_response["statistics"]["goalsScored"],
            'goalsConceded': team_response["statistics"]["goalsConceded"],
            'ownGoals': team_response["statistics"]["ownGoals"],
            'assists': team_response["statistics"]["assists"],
            'shots': team_response["statistics"]["shots"],
            'penaltyGoals': team_response["statistics"]["penaltyGoals"],
            'penaltiesTaken': team_response["statistics"]["penaltiesTaken"],
            'freeKickGoals': team_response["statistics"]["freeKickGoals"],
            'freeKickShots': team_response["statistics"]["freeKickShots"],
            'goalsFromInsideTheBox': team_response["statistics"]["goalsFromInsideTheBox"],
            'goalsFromOutsideTheBox': team_response["statistics"]["goalsFromOutsideTheBox"],
            'shotsFromInsideTheBox': team_response["statistics"]["shotsFromInsideTheBox"],
            'shotsFromOutsideTheBox': team_response["statistics"]["shotsFromOutsideTheBox"],
            'headedGoals': team_response["statistics"]["headedGoals"],
            'leftFootGoals': team_response["statistics"]["leftFootGoals"],
            'rightFootGoals': team_response["statistics"]["rightFootGoals"],
            'bigChances': team_response["statistics"]["bigChances"],
            'bigChancesCreated': team_response["statistics"]["bigChancesCreated"],
            'bigChancesMissed': team_response["statistics"]["bigChancesMissed"],
            'shotsOnTarget': team_response["statistics"]["shotsOnTarget"],
            'shotsOffTarget': team_response["statistics"]["shotsOffTarget"],
            'blockedScoringAttempt': team_response["statistics"]["blockedScoringAttempt"],
            'successfulDribbles': team_response["statistics"]["successfulDribbles"],
            'dribbleAttempts': team_response["statistics"]["dribbleAttempts"],
            'corners': team_response["statistics"]["corners"],
            'hitWoodwork': team_response["statistics"]["hitWoodwork"],
            'fastBreaks': team_response["statistics"]["fastBreaks"],
            'fastBreakGoals': team_response["statistics"]["fastBreakGoals"],
            'fastBreakShots': team_response["statistics"]["fastBreakShots"],
            'averageBallPossession': team_response["statistics"]["averageBallPossession"],
            'totalPasses': team_response["statistics"]["totalPasses"],
            'accuratePasses': team_response["statistics"]["accuratePasses"],
            'accuratePassesPercentage': team_response["statistics"]["accuratePassesPercentage"],
            'totalOwnHalfPasses': team_response["statistics"]["totalOwnHalfPasses"],
            'accurateOwnHalfPasses': team_response["statistics"]["accurateOwnHalfPasses"],
            'accurateOwnHalfPassesPercentage': team_response["statistics"]["accurateOwnHalfPassesPercentage"],
            'totalOppositionHalfPasses': team_response["statistics"]["totalOppositionHalfPasses"],
            'accurateOppositionHalfPasses': team_response["statistics"]["accurateOppositionHalfPasses"],
            'accurateOppositionHalfPassesPercentage': team_response["statistics"]["accurateOppositionHalfPassesPercentage"],
            'totalLongBalls': team_response["statistics"]["totalLongBalls"],
            'accurateLongBalls': team_response["statistics"]["accurateLongBalls"],
            'accurateLongBallsPercentage': team_response["statistics"]["accurateLongBallsPercentage"],
            'totalCrosses': team_response["statistics"]["totalCrosses"],
            'accurateCrosses': team_response["statistics"]["accurateCrosses"],
            'accurateCrossesPercentage': team_response["statistics"]["accurateCrossesPercentage"],
            'cleanSheets': team_response["statistics"]["cleanSheets"],
            'tackles': team_response["statistics"]["tackles"],
            'interceptions': team_response["statistics"]["interceptions"],
            'saves': team_response["statistics"]["saves"],
            'errorsLeadingToGoal': team_response["statistics"]["errorsLeadingToGoal"],
            'errorsLeadingToShot': team_response["statistics"]["errorsLeadingToShot"],
            'penaltiesCommited': team_response["statistics"]["penaltiesCommited"],
            'penaltyGoalsConceded': team_response["statistics"]["penaltyGoalsConceded"],
            'clearances': team_response["statistics"]["clearances"],
            'clearancesOffLine': team_response["statistics"]["clearancesOffLine"],
            'lastManTackles': team_response["statistics"]["lastManTackles"],
            'totalDuels': team_response["statistics"]["totalDuels"],
            'duelsWon': team_response["statistics"]["duelsWon"],
            'duelsWonPercentage': team_response["statistics"]["duelsWonPercentage"],
            'totalGroundDuels': team_response["statistics"]["totalGroundDuels"],
            'groundDuelsWon': team_response["statistics"]["groundDuelsWon"],
            'groundDuelsWonPercentage': team_response["statistics"]["groundDuelsWonPercentage"],
            'totalAerialDuels': team_response["statistics"]["totalAerialDuels"],
            'aerialDuelsWon': team_response["statistics"]["aerialDuelsWon"],
            'aerialDuelsWonPercentage': team_response["statistics"]["aerialDuelsWonPercentage"],
            'possessionLost': team_response["statistics"]["possessionLost"],
            'offsides': team_response["statistics"]["offsides"],
            'fouls': team_response["statistics"]["fouls"],
            'yellowCards': team_response["statistics"]["yellowCards"],
            'yellowRedCards': team_response["statistics"]["yellowRedCards"],
            'redCards': team_response["statistics"]["redCards"],
            'avgRating': team_response["statistics"]["avgRating"],
            'accurateFinalThirdPassesAgainst': team_response["statistics"]["accurateFinalThirdPassesAgainst"],
            'accurateOppositionHalfPassesAgainst': team_response["statistics"]["accurateOppositionHalfPassesAgainst"],
            'accurateOwnHalfPassesAgainst': team_response["statistics"]["accurateOwnHalfPassesAgainst"],
            'accuratePassesAgainst': team_response["statistics"]["accuratePassesAgainst"],
            'bigChancesAgainst': team_response["statistics"]["bigChancesAgainst"],
            'bigChancesCreatedAgainst': team_response["statistics"]["bigChancesCreatedAgainst"],
            'bigChancesMissedAgainst': team_response["statistics"]["bigChancesMissedAgainst"],
            'clearancesAgainst': team_response["statistics"]["clearancesAgainst"],
            'cornersAgainst': team_response["statistics"]["cornersAgainst"],
            'crossesSuccessfulAgainst': team_response["statistics"]["crossesSuccessfulAgainst"],
            'crossesTotalAgainst': team_response["statistics"]["crossesTotalAgainst"],
            'dribbleAttemptsTotalAgainst': team_response["statistics"]["dribbleAttemptsTotalAgainst"],
            'dribbleAttemptsWonAgainst': team_response["statistics"]["dribbleAttemptsWonAgainst"],
            'errorsLeadingToGoalAgainst': team_response["statistics"]["errorsLeadingToGoalAgainst"],
            'errorsLeadingToShotAgainst': team_response["statistics"]["errorsLeadingToShotAgainst"],
            'hitWoodworkAgainst': team_response["statistics"]["hitWoodworkAgainst"],
            'interceptionsAgainst': team_response["statistics"]["interceptionsAgainst"],
            'keyPassesAgainst': team_response["statistics"]["keyPassesAgainst"],
            'longBallsSuccessfulAgainst': team_response["statistics"]["longBallsSuccessfulAgainst"],
            'longBallsTotalAgainst': team_response["statistics"]["longBallsTotalAgainst"],
            'offsidesAgainst': team_response["statistics"]["offsidesAgainst"],
            'redCardsAgainst': team_response["statistics"]["redCardsAgainst"],
            'shotsAgainst': team_response["statistics"]["shotsAgainst"],
            'shotsBlockedAgainst': team_response["statistics"]["shotsBlockedAgainst"],
            'shotsFromInsideTheBoxAgainst': team_response["statistics"]["shotsFromInsideTheBoxAgainst"],
            'shotsFromOutsideTheBoxAgainst': team_response["statistics"]["shotsFromOutsideTheBoxAgainst"],
            'shotsOffTargetAgainst': team_response["statistics"]["shotsOffTargetAgainst"],
            'shotsOnTargetAgainst': team_response["statistics"]["shotsOnTargetAgainst"],
            'blockedScoringAttemptAgainst': team_response["statistics"]["blockedScoringAttemptAgainst"],
            'tacklesAgainst': team_response["statistics"]["tacklesAgainst"],
            'totalFinalThirdPassesAgainst': team_response["statistics"]["totalFinalThirdPassesAgainst"],
            'oppositionHalfPassesTotalAgainst': team_response["statistics"]["oppositionHalfPassesTotalAgainst"],
            'ownHalfPassesTotalAgainst': team_response["statistics"]["ownHalfPassesTotalAgainst"],
            'totalPassesAgainst': team_response["statistics"]["totalPassesAgainst"],
            'yellowCardsAgainst': team_response["statistics"]["yellowCardsAgainst"],
            'id': team_response["statistics"]["id"],
            'matches': team_response["statistics"]["matches"],
            'awardedMatches': team_response["statistics"]["awardedMatches"]
        })

    time.sleep(1)

df = pd.DataFrame(data).reset_index(drop=True)
df.to_csv(f'data.csv', index=False)
