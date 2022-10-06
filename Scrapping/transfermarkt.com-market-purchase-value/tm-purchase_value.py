
from inspect import trace
from datetime import datetime
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


data = []

url = 'https://www.transfermarkt.com/premier-league/einkaufswert/wettbewerb/GB1'

soup = BeautifulSoup(requests.get(url, headers=headers).content, 'html.parser')

for tr in soup.select('.items > tbody > tr:has(td)'):
    position = tr.select_one('td:nth-child(1)').get_text(strip=True)
    club = tr.select_one('td:nth-child(2)').get_text(strip=True)
    total_market_value = tr.select_one('td:nth-child(3)').get_text(strip=True)
    purchase_value = tr.select_one('td:nth-child(4)').get_text(strip=True)
    difference = tr.select_one('td:nth-child(5)').get_text(strip=True)

    data.append({
        'Position': position,
        'Club': club,
        'Total market value(mEuro)': currencyStringCleanup(total_market_value),
        'Purchase value(mEuro)': currencyStringCleanup(purchase_value),
        'Difference': currencyStringCleanup(difference)
    })
df = pd.DataFrame(data).reset_index(drop=True)
df.to_csv(datetime.today().strftime('%Y-%m-%d') + '.csv', index=False)
