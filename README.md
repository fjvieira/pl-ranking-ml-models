# Premier League - Machine learning models for predicting rank

This repository hosts the study I made for the final project of Data Science
and Analytics MBA course.

**Institution**: USP/ESALQ

**Author**: Fernando José Vieira

**Orientation**: Thiago gentil Ramires

## Objetives
From the free data available in internet, create ML models (linear and logistic regression) and analyze
the viability of using them to predict season level results.

## Structure

There are two directories in this repo:
- Scrapping: scripts used to extract data;
- Premier-League-R: R Studio project with datasets generated from the scraped data
and scripts related to data analytics and ML models.

### Web scrapping

To extract / consolidate data from the selected data sources it was
written some Python / sh scripts.
All scripts are separated into subfolders. Use them to extract related data from:
- capology.com: team payrools;
- fbref.com: general data of Premier League seasons;
- football-data.co.uk: basic data of Premier League seasons;
- sofascore.com: team's season score;
- transfermarkt.com: club expenditure, market purchase value and value change over time.

### R project
The project has two subfolfers:
- RAW_DATA: extracted / consolidated data (from the scraping process);
- RDATA: consolidated datasets.

The scripts into root folder were numerated in the order necessary to consolidate, analyze
and create ML models from available data. 

## License
This work is the intellectual property of Fernando José Vieira.
It is licensing under GNU General Public License v3.0 (GPL-3.0).
