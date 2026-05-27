# ==============================================================================
# Project: CIN Maternal
# Script: process_data.R
# Description: Minimal processing of raw maternal data for DQA
#              Separates repeating from non-repeating instrument data
#              Heavy lifting handled downstream by DuckDB
# Author:
# Date:
# ==============================================================================

# Load required libraries
library(here)
library(rio)
library(janitor)
library(dplyr)

# ------------------------------------------------------------------------------
# Load raw data
# ------------------------------------------------------------------------------
maternal_data <- rio::import(
  here::here("cin_maternal", "data", "raw", "maternal_data.csv"),
  na = character(0),
  guess_type = FALSE
)

# ------------------------------------------------------------------------------
# Standardise column names
# ------------------------------------------------------------------------------
maternal_data_clean <- maternal_data |>
  janitor::clean_names() |>
  janitor::remove_empty(which = "rows") |>
  janitor::remove_empty(which = "cols")

# ------------------------------------------------------------------------------
# Check what repeating instruments exist
# ------------------------------------------------------------------------------
repeating_instruments <- maternal_data_clean |>
  dplyr::filter(nchar(redcap_repeat_instrument) > 0) |>
  dplyr::distinct(redcap_repeat_instrument) |>
  dplyr::pull(redcap_repeat_instrument)

message("Repeating instruments found: ", length(repeating_instruments))
message(paste(" -", repeating_instruments, collapse = "\n"))

# ------------------------------------------------------------------------------
# Split: non-repeating (root) data
# ------------------------------------------------------------------------------
non_repeating_data <- maternal_data_clean |>
  dplyr::filter(
    is.na(redcap_repeat_instrument) | nchar(redcap_repeat_instrument) == 0
  ) |>
  # Drop repeating instrument columns, not relevant here
  dplyr::select(-redcap_repeat_instrument, -redcap_repeat_instance) |>
  # Drop columns that are now entirely empty after split
  janitor::remove_empty(which = "cols")

# ------------------------------------------------------------------------------
# Split: repeating instrument data (one file per instrument)
# ------------------------------------------------------------------------------
repeating_data_list <- maternal_data_clean |>
  dplyr::filter(nchar(redcap_repeat_instrument) > 0) |>
  dplyr::group_by(redcap_repeat_instrument) |>
  dplyr::group_split()

# Name each element in the list by instrument name
names(repeating_data_list) <- repeating_instruments

# ------------------------------------------------------------------------------
# Save non-repeating data
# ------------------------------------------------------------------------------
rio::export(
  non_repeating_data,
  here::here("cin_maternal", "data", "processed", "non_repeating.csv")
)

message("Non-repeating data saved.")
message(" Rows: ", nrow(non_repeating_data))
message(" Columns: ", ncol(non_repeating_data))

# ------------------------------------------------------------------------------
# Save each repeating instrument as its own CSV
# ------------------------------------------------------------------------------
repeating_dir <- here::here("cin_maternal", "data", "processed", "repeating")
dir.create(repeating_dir, showWarnings = FALSE, recursive = TRUE)

purrr::walk2(
  repeating_data_list,
  names(repeating_data_list),
  ~ {
    # Drop columns entirely empty for this instrument after split
    instrument_data <- janitor::remove_empty(.x, which = "cols")

    rio::export(
      instrument_data,
      file.path(repeating_dir, paste0(.y, ".csv"))
    )

    message("Saved repeating instrument: ", .y)
    message(" Rows: ", nrow(instrument_data))
    message(" Columns: ", ncol(instrument_data))
  }
)

message("\nProcessing complete.")
