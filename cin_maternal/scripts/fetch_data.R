# ==============================================================================
# Project: CIN Maternal
# Script: fetch_data.R
# Description: Fetches raw data from REDCap for the CIN Maternal project
# Author:
# Date:
# ==============================================================================

# Load required libraries
library(dotenv)
library(here)

# Load environment variables
dotenv::load_dot_env(here::here(".env"))

# Source common utilities
source(here::here("common", "utils.R"))

# Fetch data from REDCap
maternal_data <- fetch_redcap_data(
  api_token = Sys.getenv("REDCAP_CIN_MATERNAL_API_TOKEN"),
  redcap_url = Sys.getenv("REDCAP_URL"),
  export_data_access_groups = TRUE
)

# Save data to CSV
rio::export(
  maternal_data,
  file = here::here("cin_maternal","data", "raw", "maternal_data.csv")
)

message("Maternal data fetched and saved successfully.")
message("Rows fetched: ", nrow(maternal_data))
message("Columns fetched: ", ncol(maternal_data))
