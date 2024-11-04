# Analysing the 2024 U.S. Presidential Election: Spotlight on North Carolina's Role as a Battleground State

## Overview
This repository is conducted by R, including all necessary code, data, model and analysis used to predict the outcome of 2024 US Presidential Election.

This repository will make use of predictive modeling to create a model that aim to predict the results of the 2024 United States presidential election. The model's goal is to forecast the outcome of a poll that closes on November 5, 2024. We think this will represent the outcome of the election that day, and the election's outcome may be presumed to be around the mean of these polls.

According to our model, Donald Trump has a 6.6% chance of winning this election. We choose North Carolina as the most crucial battleground state based on our projection.

## File Structure

The repo is structured as:

-   `data/00-simulated_data` contains the simulated dataset.
-   `data/01-raw_data` contains raw data downloaded from https://projects.fivethirtyeight.com/polls/president-general/2024/national/ and https://www.kaggle.com/datasets/joebeachcapital/dow-jones-and-s-and-p500-indices-daily-update/data (not uploaded due to licensing concerns, but can be downloaded using scripts/02-download_data.R by user)
-   `data/02-analysis_data` contains the cleaned dataset that was constructed.
-   `models` contains the rds file for the models. And the prediction result. 
-   `other` contains details about LLM chat interactions, and sketches.
-   `paper` includes the paper's PDF and the files used to create it, such as the Quarto manuscript and reference bibliography file. 
-   `scripts` contains the R scripts used to simulate, download, clean, test data. Also contain analysis data, data modeling, and prediction.

## Statement on LLM usage

Some of the code was written with the help of the ChatGPT-4o model, which also helped with language paraphrase, it have also provided suggestion on the title. Other/llm_usage/usage.txt contains the entire chat history.

## Acknowledgments
We appreciate your time in reviewing this paper and would be grateful for any feedback or suggestions you may have.
