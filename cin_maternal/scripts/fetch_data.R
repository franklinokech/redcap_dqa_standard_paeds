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
library(rio)
library(purrr)

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

# Load environment variables
dotenv::load_dot_env(here::here(".env"))

# Source common utilities
source(here::here("common", "utils.R"))

# Define paths
RAW_DATA_DIR <- here::here("cin_maternal", "data", "raw")
RAW_DATA_FILE <- file.path(RAW_DATA_DIR, "maternal_data.csv")

# REDCap configuration
REDCAP_API_TOKEN <- Sys.getenv("REDCAP_CIN_MATERNAL_API_TOKEN")
REDCAP_URL <- Sys.getenv("REDCAP_URL")
START_DATE <- Sys.getenv("DATA_START_DATE", "2025-09-08")

# ------------------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------------------

#' Create raw data directory if it doesn't exist
ensure_raw_data_dir <- function() {
  if (!dir.exists(RAW_DATA_DIR)) {
    dir.create(RAW_DATA_DIR, recursive = TRUE, showWarnings = FALSE)
    message("Created directory: ", RAW_DATA_DIR)
  }
}

#' Validate environment variables
validate_env_vars <- function() {
  required_vars <- c("REDCAP_CIN_MATERNAL_API_TOKEN", "REDCAP_URL")
  missing_vars <- character()
  
  for (var in required_vars) {
    if (Sys.getenv(var) == "") {
      missing_vars <- c(missing_vars, var)
    }
  }
  
  if (length(missing_vars) > 0) {
    stop("Missing required environment variables: ", 
         paste(missing_vars, collapse = ", "),
         "\nPlease check your .env file")
  }
  
  message("✓ Environment variables validated")
}

#' Fetch data with retry logic
fetch_with_retry <- function(api_token, redcap_url, max_retries = 3) {
  attempt <- 1
  last_error <- NULL
  
  while (attempt <= max_retries) {
    tryCatch({
      message("Fetching data from REDCap (attempt ", attempt, "/", max_retries, ")...")
      
      data <- fetch_redcap_data(
        api_token = api_token,
        redcap_url = redcap_url,
        export_data_access_groups = TRUE,
        datetime_range_begin = as.POSIXct(START_DATE)
      )
      
      message("✓ Data fetched successfully")
      return(data)
      
    }, error = function(e) {
      last_error <- e
      message("✗ Attempt ", attempt, " failed: ", e$message)
      if (attempt < max_retries) {
        wait_time <- 2 ^ attempt  # Exponential backoff
        message("  Waiting ", wait_time, " seconds before retry...")
        Sys.sleep(wait_time)
      }
      attempt <- attempt + 1
    })
  }
  
  stop("Failed to fetch data after ", max_retries, " attempts. Last error: ", 
       last_error$message)
}

#' Save data and return summary
save_data <- function(data, file_path) {
  ensure_raw_data_dir()
  
  rio::export(data, file_path)
  
  message("\nData saved to: ", file_path)
  message("  - Rows: ", nrow(data))
  message("  - Columns: ", ncol(data))
  
  # Data quality checks
  if (nrow(data) == 0) {
    warning("No rows were fetched! Check your REDCap query parameters.")
  }
  
  if (ncol(data) == 0) {
    warning("No columns were fetched! Check your REDCap API access.")
  }
  
  return(invisible(data))
}

#' Generate fetch summary
generate_summary <- function(data) {
  cat("\n", strrep("=", 60), "\n", sep = "")
  cat("FETCH SUMMARY\n")
  cat(strrep("=", 60), "\n", sep = "")
  cat("Total records:    ", nrow(data), "\n")
  cat("Total fields:     ", ncol(data), "\n")
  cat("Start date:       ", START_DATE, "\n")
  cat("REDCap URL:       ", REDCAP_URL, "\n")
  
  # Check for repeating instruments
  if ("redcap_repeat_instrument" %in% names(data)) {
    instruments <- unique(data$redcap_repeat_instrument)
    instruments <- instruments[!is.na(instruments) & instruments != ""]
    
    if (length(instruments) > 0) {
      cat("\nRepeating instruments found (", length(instruments), "):\n", sep = "")
      for (inst in instruments) {
        inst_count <- sum(data$redcap_repeat_instrument == inst, na.rm = TRUE)
        cat("  - ", inst, ": ", inst_count, " instances\n", sep = "")
      }
    } else {
      cat("\nNo repeating instruments found\n")
    }
  }
  
  cat(strrep("=", 60), "\n", sep = "")
}

# ------------------------------------------------------------------------------
# Main execution
# ------------------------------------------------------------------------------

main <- function() {
  message(strrep("=", 60))
  message("CIN Maternal - Data Fetch Process")
  message("Started at: ", Sys.time())
  message(strrep("=", 60), "\n")
  
  # Validate environment
  validate_env_vars()
  
  # Fetch data with retry logic
  maternal_data <- fetch_with_retry(
    api_token = REDCAP_API_TOKEN,
    redcap_url = REDCAP_URL
  )
  
  # Save data
  save_data(maternal_data, RAW_DATA_FILE)
  
  # Generate summary
  generate_summary(maternal_data)
  
  message("\n✓ Fetch process completed successfully")
  message("Finished at: ", Sys.time())
}

# ------------------------------------------------------------------------------
# Run main function if script is executed directly
# ------------------------------------------------------------------------------

if (interactive() || sys.nframe() == 0L) {
  main()
}