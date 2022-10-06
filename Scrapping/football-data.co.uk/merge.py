import pandas as pd
import glob
import os

path = r'./'

data_files = glob.glob(os.path.join(path , "m2*.csv"))

df = pd.concat((pd.read_csv(f) for f in data_files), join='inner', ignore_index=True)


df.to_csv('data.csv', index=False)