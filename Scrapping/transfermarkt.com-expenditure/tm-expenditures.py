
from inspect import trace
import requests
import pandas as pd
from bs4 import BeautifulSoup
import re


def currencyStringCleanup(value):
    if(value == '-'):
        return '0'
    value2 = re.sub(r'€(-?\d*\.?\d*)m', r'\1', value)
    return re.sub(r'€(-?)(\d+)Th\.', r'\g<1>0.\2', value2)


headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.0.0 Safari/537.36'}

for year in range(2000, 2022):
    year_data = []
    print('Getting data for year {}..'.format(year))

    url = 'https://www.transfermarkt.com/premier-league/einnahmenausgaben/wettbewerb/GB1/plus/1?ids=a&sa=&saison_id=' + \
        str(year)
    url += '&saison_id_bis=' + \
        str(year) + '&nat=&pos=&altersklasse=&w_s=&leihe=&intern=0'

    soup = BeautifulSoup(requests.get(
        url, headers=headers).content, 'html.parser')

    for tr in soup.select('.items > tbody > tr:has(td)'):
        year_data.append({
            'Year': year,
            'Season': f'{year}-{year+1}',
            'Position': tr.select_one('td:nth-child(1)').get_text(strip=True),
            'Club': tr.select_one('td:nth-child(3)').get_text(strip=True),
            'Expenditure(mEuro)': currencyStringCleanup(tr.select_one('td:nth-child(5)').get_text(strip=True)),
            'Arrivals': tr.select_one('td:nth-child(6)').get_text(strip=True),
            'Income(mEuro)': currencyStringCleanup(tr.select_one('td:nth-child(7)').get_text(strip=True)),
            'Departures': tr.select_one('td:nth-child(8)').get_text(strip=True),
            'Balance(mEuro)': currencyStringCleanup(tr.select_one('td:nth-child(9)').get_text(strip=True))
        })

df = pd.DataFrame(year_data).reset_index(drop=True)
df.to_csv(f'data.csv', index=False)
