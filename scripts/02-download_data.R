#### Preamble ####
# Purpose: Downloads and saves the presidential general election data from https://projects.fivethirtyeight.com/polls/president-general/2024/national/
# - Downloads and saves the Doe Jones data form https://www.kaggle.com/api/v1/datasets/download/joebeachcapital/dow-jones-and-s-and-p500-indices-daily-update
# Author: Haobo Ren
# Date: 19 October 2024
# Contact: haobo.ren@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `curl` package must be installed and loaded
# Any other information needed? Make sure you are in the `starter_folder` rproj


#### Workspace setup ####
library(curl)

#### Download data ####
url <- "https://projects.fivethirtyeight.com/polls/data/president_polls.csv"
download.file(url, destfile = "data/01-raw_data/raw_data.csv")

url_DJI = "https://www.kaggle.com/api/v1/datasets/download/joebeachcapital/dow-jones-and-s-and-p500-indices-daily-update"
curl_download(url_DJI, "data/01-raw_data/archive.zip")
# This is a zip file, data needs to be manually unzipped.
# From kaggle, however the original data was retrived from FRED(https://fred.stlouisfed.org/series/DJIA)

# date data is retrieved: 01 November 2024