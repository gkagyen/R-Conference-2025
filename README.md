# Ghana R Conference 2025

<!-- badges: start -->

![R Version](https://img.shields.io/badge/R-4.3.0-blue.svg)

![License](https://img.shields.io/badge/license-MIT-green.svg)

![Made with R](https://img.shields.io/badge/Made%20with-R-1f425f.svg)

<!-- badges: end -->

## Machine Learning in Environmental Monitoring: An R Perspective

This repository contains the materials and source code for my presentation at the **Ghana R User Community Conference**, under the theme:

> *“Harnessing R for Sustainable Development: Innovations, Collaborations, and Health Impacts”*

## 📌 Overview

This presentation introduces how **Machine Learning** can be used in **Environmental Monitoring** using R. The focus is on practical applications such as:

-   Forecasting rainfall using historical weather patterns (temperature and humidity)
-   Using `tidymodels` for reproducible ML workflows
-   Leveraging open-source R tools for data science and sustainability

## 📁 Repository Structure

| Folder/File | Description |
|---------------------------|---------------------------------------------|
| `scripts/` | Contains all R scripts used in the live demo and data prep |
| `data/` | Example environmental dataset (synthetic) |
| `Conference Presentation.pdf` | Presentation slides (PowerPoint) |
| `R Conference schedule.pdf` | Conference program schedule |
| `README.md` | Project documentation (this file) |

## 🚀 How to Use

### Prerequisites

Make sure you have R (≥ 4.1.0) and the following packages installed:

\`\`\`r install.packages(c("tidymodels", "ggplot2", "lubridate", "dplyr", "readr"))

### Running the Live Demo Code

1.  Open the project folder in RStudio.

2.  Navigate to the script in `R/predict_rainfall_demo.R` (or equivalent).

3.  Run the script to:

    -   Load simulated weather data (monthly temperature, humidity, and rainfall)

    -   Train a random forest model using `tidymodels`

    -   Predict rainfall

    -   Visualize predictions

## 💡 Live Demo Highlight

The demo illustrates how **machine learning** (Random Forest) can be applied to **forecast future rainfall** based on previous months' temperature and humidity. This type of analysis is useful for:

-   Climate adaptation

-   Agricultural planning

-   Water resource management

## 👨🏽‍🔬 About the Author

**George Kyei Agyen**\
PhD Researcher in Coastal Engineering\
University of Cape Coast, Ghana

-   🔬 *Research Focus*: Wave dynamics, coastal erosion, sediment transport

-   🤖 *Interests*: Machine Learning, R programming, environmental data analysis

## 📫 Contact

Reach out via [LinkedIn](www.linkedin.com/in/gk-agyen59) or email me at `gkagyen@live.com`.
