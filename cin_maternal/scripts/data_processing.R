# ==============================================================================
# Project: CIN Maternal
# Script:  process_data.R
# Purpose: Minimal processing of raw maternal REDCap data for DQA.
#          Splits repeating-instrument rows from non-repeating (root) rows and
#          writes one CSV per instrument.  Heavy lifting is handled downstream
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

# ------------------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------------------
RAW_DATA_PATH   <- here("cin_maternal", "data", "raw", "maternal_data.csv")
PROCESSED_DIR   <- here("cin_maternal", "data", "processed")
REPEATING_DIR   <- file.path(PROCESSED_DIR, "repeating")

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

#' Log a section header to the console
log_section <- function(title) {
  message("\n── ", title, " ", strrep("─", max(0, 60 - nchar(title))))
}

#' Log a key-value pair
log_kv <- function(key, value) {
  message(sprintf("  %-12s %s", paste0(key, ":"), value))
}

# ------------------------------------------------------------------------------
# 1.  Load & standardise
# ------------------------------------------------------------------------------
log_section("Loading data")

raw <- rio::import(
  RAW_DATA_PATH,
  na         = character(0),   # keep all strings; treat nothing as NA on load
  guess_type = FALSE
)

clean <- raw |>
  janitor::clean_names() |>
  janitor::remove_empty(which = c("rows", "cols"))

log_kv("rows", nrow(clean))
log_kv("cols", ncol(clean))

# ------------------------------------------------------------------------------
# 2.  Identify repeating rows
# ------------------------------------------------------------------------------
is_repeating <- function(x) !is.na(x) & nchar(trimws(x)) > 0

# ------------------------------------------------------------------------------
# 3.  Non-repeating (root) data
# ------------------------------------------------------------------------------
log_section("Non-repeating data")

non_repeating <- clean |>
  dplyr::filter(!is_repeating(redcap_repeat_instrument)) |>
  dplyr::select(-redcap_repeat_instrument, -redcap_repeat_instance) |>
  janitor::remove_empty(which = "cols")

dir.create(PROCESSED_DIR, showWarnings = FALSE, recursive = TRUE)
rio::export(non_repeating, file.path(PROCESSED_DIR, "non_repeating.csv"))

log_kv("rows", nrow(non_repeating))
log_kv("cols", ncol(non_repeating))
log_kv("saved", file.path(PROCESSED_DIR, "non_repeating.csv"))

# ------------------------------------------------------------------------------
# 4.  Repeating instrument data
# ------------------------------------------------------------------------------
log_section("Repeating instruments")

grouped <- clean |>
  dplyr::filter(is_repeating(redcap_repeat_instrument)) |>
  dplyr::group_by(redcap_repeat_instrument)

# group_keys() and group_split() iterate in the same order — names are safe
instrument_names <- dplyr::group_keys(grouped) |>
  dplyr::pull(redcap_repeat_instrument)

instrument_list  <- dplyr::group_split(grouped)
names(instrument_list) <- instrument_names

message("Found ", length(instrument_names), " repeating instrument(s):")
purrr::walk(instrument_names, ~ message("  - ", .x))

# ------------------------------------------------------------------------------
# 5.  Save one CSV per repeating instrument
# ------------------------------------------------------------------------------
log_section("Saving repeating instruments")

dir.create(REPEATING_DIR, showWarnings = FALSE, recursive = TRUE)

purrr::iwalk(instrument_list, function(df, name) {

  out <- janitor::remove_empty(df, which = "cols")

  dest <- file.path(REPEATING_DIR, paste0(name, ".csv"))
  rio::export(out, dest)

  log_kv(name, sprintf("%d rows × %d cols → %s", nrow(out), ncol(out), dest))
})

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
log_section("Complete")