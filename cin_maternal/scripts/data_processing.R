# ==============================================================================
# Project: CIN Maternal
# Script: data_processing.R
# Purpose: Minimal processing of raw maternal REDCap data for DQA.
#          Splits repeating-instrument rows from non-repeating (root) rows and
#          writes one CSV per instrument. Heavy lifting is handled downstream
#          by DuckDB.
# ==============================================================================

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------
library(here)
library(rio)
library(janitor)
library(dplyr)
library(purrr)
library(tools)

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

# Path configuration
RAW_DATA_PATH <- here::here("cin_maternal", "data", "raw", "maternal_data.csv")
PROCESSED_DIR <- here::here("cin_maternal", "data", "processed")
REPEATING_DIR <- file.path(PROCESSED_DIR, "repeating")

# Processing options
REMOVE_EMPTY_ROWS <- TRUE
REMOVE_EMPTY_COLS <- TRUE
REPORT_PROGRESS <- TRUE

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

#' Log a section header to the console
#' @param title Section title
#' @param char Character to use for line
#' @param width Width of the line
log_section <- function(title, char = "─", width = 60) {
  line <- strrep(char, max(0, width - nchar(title) - 2))
  message("\n", title, " ", line)
}

#' Log a key-value pair
#' @param key Key/label
#' @param value Value
#' @param indent Spaces to indent
log_kv <- function(key, value, indent = 2) {
  spaces <- strrep(" ", indent)
  message(sprintf("%s%-20s: %s", spaces, key, value))
}

#' Log a success message
#' @param message Success message
log_success <- function(message) {
  message("  ✓ ", message)
}

#' Log an info message
#' @param message Info message
log_info <- function(message) {
  message("  ℹ ", message)
}

#' Check if values indicate repeating rows (VECTORIZED)
#' @param x Vector of values to check
#' @return Logical vector
is_repeating_row <- function(x) {
  # Vectorized operation: check each element
  !is.na(x) & nchar(trimws(x)) > 0
}

#' Ensure directory exists, create if needed
#' @param path Directory path
#' @return Path (invisibly)
ensure_directory <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
    log_info(paste("Created directory:", path))
  }
  return(invisible(path))
}

#' Get file size in human-readable format
#' @param file_path Path to file
#' @return Human-readable file size
get_file_size <- function(file_path) {
  if (!file.exists(file_path)) return("N/A")
  size_bytes <- file.info(file_path)$size
  if (size_bytes < 1024) return(paste0(size_bytes, " B"))
  if (size_bytes < 1024^2) return(paste0(round(size_bytes / 1024, 1), " KB"))
  if (size_bytes < 1024^3) return(paste0(round(size_bytes / 1024^2, 1), " MB"))
  return(paste0(round(size_bytes / 1024^3, 1), " GB"))
}

#' Validate input file exists
#' @param file_path Path to validate
#' @return TRUE if valid, stops otherwise
validate_input_file <- function(file_path) {
  if (!file.exists(file_path)) {
    stop("Input file not found: ", file_path)
  }
  if (file.info(file_path)$size == 0) {
    stop("Input file is empty: ", file_path)
  }
  log_success(paste("Input file found:", basename(file_path)))
  return(TRUE)
}

#' Generate processing summary
#' @param original_data Original cleaned data
#' @param non_repeating_data Non-repeating data
#' @param repeating_instruments List of repeating instruments
generate_summary <- function(original_data, non_repeating_data, repeating_instruments) {
  cat("\n", strrep("=", 60), "\n", sep = "")
  cat("PROCESSING SUMMARY\n")
  cat(strrep("=", 60), "\n", sep = "")
  
  log_kv("Original rows", nrow(original_data))
  log_kv("Original cols", ncol(original_data))
  log_kv("Non-repeating rows", nrow(non_repeating_data))
  log_kv("Non-repeating cols", ncol(non_repeating_data))
  log_kv("Repeating instruments", length(repeating_instruments))
  
  if (length(repeating_instruments) > 0) {
    total_repeating_rows <- sum(purrr::map_int(repeating_instruments, ~ nrow(.x)))
    log_kv("Repeating rows total", total_repeating_rows)
  }
  
  cat(strrep("=", 60), "\n", sep = "")
}

# ------------------------------------------------------------------------------
# Core Processing Functions
# ------------------------------------------------------------------------------

#' Load and standardize raw data
#' @param file_path Path to raw CSV
#' @return Cleaned data frame
load_and_clean_data <- function(file_path) {
  log_section("Loading data")
  
  validate_input_file(file_path)
  
  # Load raw data
  raw_data <- rio::import(
    file_path,
    na = character(0),      # Keep all strings; treat nothing as NA on load
    guess_type = FALSE
  )
  
  log_kv("Loaded rows", nrow(raw_data))
  log_kv("Loaded cols", ncol(raw_data))
  
  # Clean names and remove empty
  clean_data <- raw_data |>
    janitor::clean_names()
  
  if (REMOVE_EMPTY_ROWS) {
    rows_before <- nrow(clean_data)
    clean_data <- janitor::remove_empty(clean_data, which = "rows")
    rows_removed <- rows_before - nrow(clean_data)
    if (rows_removed > 0) log_info(paste("Removed", rows_removed, "empty rows"))
  }
  
  if (REMOVE_EMPTY_COLS) {
    cols_before <- ncol(clean_data)
    clean_data <- janitor::remove_empty(clean_data, which = "cols")
    cols_removed <- cols_before - ncol(clean_data)
    if (cols_removed > 0) log_info(paste("Removed", cols_removed, "empty columns"))
  }
  
  log_kv("Final rows", nrow(clean_data))
  log_kv("Final cols", ncol(clean_data))
  log_success("Data loaded and cleaned")
  
  return(clean_data)
}

#' Extract non-repeating (root) data
#' @param clean_data Cleaned data frame
#' @return Non-repeating data frame
extract_non_repeating_data <- function(clean_data) {
  log_section("Extracting non-repeating data")
  
  # Check if redcap_repeat_instrument column exists
  if (!"redcap_repeat_instrument" %in% names(clean_data)) {
    log_info("No repeating instrument column found - all data treated as non-repeating")
    return(clean_data)
  }
  
  # Filter non-repeating rows (using vectorized function)
  non_repeating <- clean_data |>
    dplyr::filter(!is_repeating_row(redcap_repeat_instrument)) |>
    dplyr::select(-dplyr::any_of(c("redcap_repeat_instrument", "redcap_repeat_instance")))
  
  if (REMOVE_EMPTY_COLS) {
    cols_before <- ncol(non_repeating)
    non_repeating <- janitor::remove_empty(non_repeating, which = "cols")
    cols_removed <- cols_before - ncol(non_repeating)
    if (cols_removed > 0) log_info(paste("Removed", cols_removed, "empty columns from non-repeating data"))
  }
  
  log_kv("Non-repeating rows", nrow(non_repeating))
  log_kv("Non-repeating cols", ncol(non_repeating))
  log_success("Non-repeating data extracted")
  
  return(non_repeating)
}

#' Extract repeating instrument data
#' @param clean_data Cleaned data frame
#' @return List of data frames, one per repeating instrument
extract_repeating_data <- function(clean_data) {
  log_section("Extracting repeating instruments")
  
  # Check if redcap_repeat_instrument column exists
  if (!"redcap_repeat_instrument" %in% names(clean_data)) {
    log_info("No repeating instrument column found - no repeating data to extract")
    return(list())
  }
  
  # Filter repeating rows (using vectorized function)
  repeating_rows <- clean_data |>
    dplyr::filter(is_repeating_row(redcap_repeat_instrument))
  
  if (nrow(repeating_rows) == 0) {
    log_info("No repeating rows found")
    return(list())
  }
  
  log_kv("Repeating rows found", nrow(repeating_rows))
  
  # Group by instrument
  grouped <- repeating_rows |>
    dplyr::group_by(redcap_repeat_instrument)
  
  instrument_names <- dplyr::group_keys(grouped) |>
    dplyr::pull(redcap_repeat_instrument)
  
  instrument_list <- dplyr::group_split(grouped)
  names(instrument_list) <- instrument_names
  
  log_kv("Instruments found", length(instrument_names))
  
  if (REPORT_PROGRESS && length(instrument_names) > 0) {
    for (name in instrument_names) {
      rows <- nrow(instrument_list[[name]])
      cols <- ncol(instrument_list[[name]])
      log_kv(paste0("  - ", name), paste0(rows, " rows, ", cols, " cols"))
    }
  }
  
  log_success("Repeating instruments extracted")
  return(instrument_list)
}

#' Save non-repeating data to CSV
#' @param data Non-repeating data frame
#' @param output_dir Output directory
#' @return Output file path
save_non_repeating_data <- function(data, output_dir) {
  log_section("Saving non-repeating data")
  
  ensure_directory(output_dir)
  
  output_file <- file.path(output_dir, "non_repeating.csv")
  rio::export(data, output_file)
  
  file_size <- get_file_size(output_file)
  log_kv("Rows saved", nrow(data))
  log_kv("Cols saved", ncol(data))
  log_kv("File size", file_size)
  log_kv("Output path", output_file)
  log_success("Non-repeating data saved")
  
  return(output_file)
}

#' Save repeating instrument data to CSV files
#' @param instrument_list List of repeating instrument data frames
#' @param output_dir Output directory for repeating files
#' @return Vector of output file paths
save_repeating_data <- function(instrument_list, output_dir) {
  log_section("Saving repeating instruments")
  
  if (length(instrument_list) == 0) {
    log_info("No repeating instruments to save")
    return(character(0))
  }
  
  ensure_directory(output_dir)
  
  output_files <- character()
  
  purrr::iwalk(instrument_list, function(df, name) {
    # Remove empty columns for this instrument
    df_clean <- if (REMOVE_EMPTY_COLS) {
      janitor::remove_empty(df, which = "cols")
    } else {
      df
    }
    
    output_file <- file.path(output_dir, paste0(name, ".csv"))
    rio::export(df_clean, output_file)
    output_files <<- c(output_files, output_file)
    
    file_size <- get_file_size(output_file)
    log_kv(name, paste0(nrow(df_clean), " rows × ", ncol(df_clean), " cols → ", file_size))
  })
  
  log_success(paste(length(instrument_list), "repeating instruments saved"))
  
  return(output_files)
}

#' Run the complete data processing pipeline
#' @param input_path Path to raw CSV file (optional)
#' @param output_dir Output directory (optional)
#' @return List with processing results
run_processing_pipeline <- function(
  input_path = RAW_DATA_PATH,
  output_dir = PROCESSED_DIR
) {
  # Record start time
  start_time <- Sys.time()
  
  message(strrep("=", 60))
  message("CIN MATERNAL - DATA PROCESSING PIPELINE")
  message("Started at: ", start_time)
  message(strrep("=", 60))
  
  # Validate input
  validate_input_file(input_path)
  
  # Step 1: Load and clean
  clean_data <- load_and_clean_data(input_path)
  
  # Step 2: Extract non-repeating
  non_repeating_data <- extract_non_repeating_data(clean_data)
  
  # Step 3: Extract repeating
  repeating_instruments <- extract_repeating_data(clean_data)
  
  # Step 4: Save outputs
  non_repeating_file <- save_non_repeating_data(non_repeating_data, output_dir)
  repeating_files <- save_repeating_data(repeating_instruments, REPEATING_DIR)
  
  # Step 5: Generate summary
  generate_summary(clean_data, non_repeating_data, repeating_instruments)
  
  # Record end time
  end_time <- Sys.time()
  duration <- difftime(end_time, start_time, units = "secs")
  
  message("\n✓ Processing completed successfully")
  message("  Duration: ", round(duration, 2), " seconds")
  message("  Output: ", output_dir)
  message("Finished at: ", end_time)
  message(strrep("=", 60))
  
  # Return results invisibly
  return(invisible(list(
    clean_data = clean_data,
    non_repeating = non_repeating_data,
    repeating_instruments = repeating_instruments,
    output_files = c(non_repeating_file, repeating_files),
    duration = duration
  )))
}

# ------------------------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------------------------

#' Main function - called when script is run directly
main <- function() {
  result <- run_processing_pipeline()
  return(result)
}

# Run main if script is executed directly
if (interactive() || sys.nframe() == 0L) {
  main()
}