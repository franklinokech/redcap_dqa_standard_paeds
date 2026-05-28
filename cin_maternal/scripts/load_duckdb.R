# ==============================================================================
# Project: CIN Maternal
# Script:  load_duckdb.R
# Purpose: Load processed maternal CSVs into DuckDB.
#          One table per CSV; all columns stored as VARCHAR (typing deferred
#          to downstream DuckDB queries).
# ==============================================================================

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------
library(here)
library(duckdb)
library(DBI)
library(purrr)

# ------------------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------------------
DUCKDB_PATH   <- here("cin_maternal", "data", "processed", "maternal.duckdb")
NON_REPEATING <- here("cin_maternal", "data", "processed", "non_repeating.csv")
REPEATING_DIR <- here("cin_maternal", "data", "processed", "repeating")

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

#' Log a section header
log_section <- function(title) {
  message("\n── ", title, " ", strrep("─", max(0, 60 - nchar(title))))
}

#' Wrap a table name in double-quotes for safe DuckDB injection
dq <- function(x) paste0('"', gsub('"', '""', x), '"')

#' Load a CSV into DuckDB and return the row count
load_csv_table <- function(con, table_name, csv_path) {
  DBI::dbExecute(con, sprintf(
    "CREATE OR REPLACE TABLE %s AS
     SELECT * FROM read_csv_auto(%s, all_varchar = true, header = true)",
    dq(table_name),
    DBI::dbQuoteString(con, csv_path)
  ))

  DBI::dbGetQuery(con, sprintf("SELECT COUNT(*) AS n FROM %s", dq(table_name)))$n
}

# ------------------------------------------------------------------------------
# Main — wrapped in a function so on.exit() defers correctly
# ------------------------------------------------------------------------------
run <- function() {

  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = DUCKDB_PATH)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  # ----------------------------------------------------------------------------
  # Non-repeating (root) table
  # ----------------------------------------------------------------------------
  log_section("Loading non-repeating data")

  n <- load_csv_table(con, "maternal_core", NON_REPEATING)
  message(sprintf("  maternal_core: %s rows", n))

  # ----------------------------------------------------------------------------
  # Repeating instrument tables
  # ----------------------------------------------------------------------------
  log_section("Loading repeating instruments")

  repeating_files <- list.files(REPEATING_DIR, pattern = "\\.csv$", full.names = TRUE)

  if (length(repeating_files) == 0) {
    message("  No repeating instrument CSVs found in: ", REPEATING_DIR)
  } else {
    purrr::walk(repeating_files, function(path) {
      name <- tools::file_path_sans_ext(basename(path))
      n    <- load_csv_table(con, name, path)
      message(sprintf("  %-45s %s rows", name, n))
    })
  }

  # ----------------------------------------------------------------------------
  # Summary
  # ----------------------------------------------------------------------------
  log_section("Tables loaded")

  tables <- DBI::dbListTables(con)

  purrr::walk(sort(tables), function(tbl) {
    n <- DBI::dbGetQuery(con, sprintf("SELECT COUNT(*) AS n FROM %s", dq(tbl)))$n
    message(sprintf("  %-45s %s rows", tbl, n))
  })

  message("\n  Total tables: ", length(tables))

  log_section("Complete")
  message("  DuckDB: ", DUCKDB_PATH)
}

run()