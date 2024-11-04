# Analysing the 2024 U.S. Presidential Election: Spotlight on North Carolina's Role as a Battleground State

## Overview

This repo is for Analysis on USA Election

## File Structure

The repo is structured as:

-   `data/00-simulated_data` contains the simulated dataset.
-   `data/01-raw_data` contains raw data downloaded from https://projects.fivethirtyeight.com/polls/president-general/2024/national/(not uploaded due to licensing concerns, but can be dowloaded using scripts/02-download_data.R by user)
-   `data/02-analysis_data` contains the cleaned dataset that was constructed.
-   `models` contains the rds file for Harris and Trump.
-   `other` contains details about LLM chat interactions, and sketches.
-   `paper` includes the paper's PDF and the files used to create it, such as the Quarto manuscript and reference bibliography file. 
-   `scripts` contains the R scripts used to simulate, download, clean, test data. Also contain analysis data and data modeling.

## Statement on LLM usage

Some of the code was written with the help of the ChatGPT-4o model, which also helped with language paraphrase. Other/llm_usage/usage.txt contains the entire chat history.

## TODOs:
### Part finished: 
- Script part: change file format parquet to fit with requirement
- Appendix 2(idealized methodology): update according to comment
### Parts waiting: 
- Main Essay
- Appendix 1(Analysis methodology)
- Appendix 3(model selection)
