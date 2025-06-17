#################################################################
# THESE ARE SYNTHETIC WEATHER DATA CREATED FOR A LIVE CODE DEMO #
# THE DATA IS CREATED TO MIMIC REAL WEATHER DATA IN GHANA       #
#################################################################

# Load required libraries
library(tidyverse)
library(lubridate)

# Set seed for reproducibility
set.seed(1992)

# Create a sequence of monthly dates from Jan 2019 to Dec 2024
dates <- seq(ym("2019-01"), ym("2024-12"), by = "month")
n_months <- length(dates)

# Generate rainfall using gamma distribution for realistic skewness
rainfall <- case_when(
  months %in% c(4:7, 9:10) ~ rgamma(n_months, shape = 2, scale = 60) + runif(n_months, 20, 80),
  months %in% c(12, 1, 2) ~ rgamma(n_months, shape = 1, scale = 5) + runif(n_months, 0, 10),
  TRUE ~ rgamma(n_months, shape = 1.5, scale = 20) + runif(n_months, 5, 30)
)
rainfall <- pmax(0, rainfall * ifelse(months %in% 4:7, 1.2, 1)) # Boost major rainy season (Apr-Jul)
rainfall <- pmax(0, rainfall + rnorm(n_months, (years - 2019) * 0.1, 5)) # Add yearly trend and noise

# Generate humidity with sinusoidal pattern, correlated with rainfall
humidity_base <- 75 + 10 * (sin(2 * pi * (months - 3) / 12) + 0.3 * sin(2 * pi * (months - 8) / 12))
humidity <- pmax(60, pmin(95, humidity_base + rnorm(n_months, (years - 2019) * 0.1, 3))) # Bound 60-95%, with yearly trend

# Generate temperature, inversely correlated with rainfall
temp_base <- 28 - 2 * (sin(2 * pi * (months - 3) / 12) + 0.3 * sin(2 * pi * (months - 8) / 12))
temperature <- pmax(24, pmin(32, temp_base + rnorm(n_months, (years - 2019) * 0.05, 0.5))) # Bound 24-32°C, with yearly trend

# Create the dataset
ghana_weather <- tibble(
  Date = dates,
  Rainfall = round(rainfall, 2), # Rainfall in mm
  Humidity = round(humidity, 2), # Humidity in %
  Temperature = round(temperature, 2) # Temperature in °C
)

# Add ~8% missing values
add_missing <- function(x) {
  n_missing <- round(length(x) * 0.08)
  x[sample(1:length(x), n_missing)] <- NA
  return(x)
}
ghana_weather <- ghana_weather %>%
  mutate(
    Rainfall = add_missing(Rainfall),
    Humidity = add_missing(Humidity),
    Temperature = add_missing(Temperature)
  )

# Save the dataset to CSV
write_csv(ghana_weather, "data/ghana_weather_monthly.csv")

# Preview the first few rows
print(head(ghana_weather))

# Visualize the data
ghana_weather %>%
  pivot_longer(c(Rainfall, Humidity, Temperature), names_to = "Variable", values_to = "Value") %>%
  ggplot(aes(x = Date, y = Value, colour = Variable)) +
  geom_line(show.legend = FALSE, linewidth = 0.6) +
  facet_wrap(~ Variable, scales = "free_y", ncol = 3) +
  labs(title = "Synthetic Ghana Weather Data (2019–2024)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
