
from inspect import trace
import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
import time
import json

base_url = 'https://www.capology.com/uk/premier-league/payrolls/'

headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.0.0 Safari/537.36'}

# Declaring data objects
data = []

for year in range(2013, 2022):
    print('Getting data for year {}..'.format(year))

    soup = BeautifulSoup(requests.get(
        base_url + f'{year}-{year+1}', headers=headers).content, 'html.parser')

    js_String = soup.findAll('script')[15].get_text(strip=True)

    result = re.search(
        r"[\s]*var\sdata\s\=\s([\n\r\s\'\"\[\{a-z\:\<\=\/\-0-9\>\.A-Z\,\_\(\)€\]£$\}]*)\/\/", js_String).group(1)
    result = re.sub(r"\"weekly.*\"\, 0\)\,", '', result)
    result = re.sub(
        r"accounting\.formatMoney\(\"([0-9]*)\".*\)", r"\1", result)
    result = re.sub(r"\,[\s]*([\}\]])", r"\1", result)
    result = re.sub(r"<a.*>(.*)<\/a>", r"\1", result)
    result = re.sub(r"\{", r'{\n"season":' + f'"{year}-{year+1}",', result)

    data = data + json.loads(result)

    time.sleep(2)


data_df = pd.DataFrame(data).reset_index(drop=True)
data_df.to_csv(f'capology_PAYROLL.csv', index=False)
