from inspect import trace
import requests
import pandas as pd
from bs4 import BeautifulSoup
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

for year in range(2010, 2023):
    for month in range(1, 13):
        for division in range(1, 4):
            print(
                f'Getting data for division {division}, year {year}-{month}-01')

            url = f'https://www.transfermarkt.com/premier-league/marktwerteverein/wettbewerb/GB{division}/plus/?stichtag={year}-{month}-01'

            soup = BeautifulSoup(requests.get(
                url, headers=headers).content, 'html.parser')

            for tr in soup.select('.items > tbody > tr:has(td:nth-child(6))'):
                data.append({
                    'Year': year,
                    'Date': f'{year}-{month}-01',
                    'Division': "Premier League" if division == 1 else 'Championship',
                    'Club': tr.select_one('td:nth-child(3)').get_text(strip=True),
                    'Value(mEuro)': currencyStringCleanup(tr.select_one('td:nth-child(5)').get_text(strip=True)),
                    'Current value(mEuro)': currencyStringCleanup(tr.select_one('td:nth-child(6)').get_text(strip=True)),
                    'Variation(%)': tr.select_one('td:nth-child(7)').get_text(strip=True).replace(" %", "")
                })

            time.sleep(1)
df = pd.DataFrame(data).reset_index(drop=True)
df.to_csv(f'data.csv', index=False)
