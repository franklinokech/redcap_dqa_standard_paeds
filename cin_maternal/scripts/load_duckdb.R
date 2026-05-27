# ==============================================================================
# Project: CIN Maternal
# Script: load_duckdb.R
# Description: Load processed maternal data into DuckDB
# Author:
# Date:
# ==============================================================================

library(here)
library(duckdb)
library(DBI)

# ------------------------------------------------------------------------------
# Connect to DuckDB (persistent database)
# ------------------------------------------------------------------------------
con <- DBI::dbConnect(
  duckdb::duckdb(),
  dbdir = here::here("cin_maternal", "data", "processed", "maternal.duckdb")
)

# ------------------------------------------------------------------------------
# Load non-repeating data as maternal_core
# ------------------------------------------------------------------------------
DBI::dbExecute(con, "
  CREATE OR REPLACE TABLE maternal_core AS
  SELECT * FROM read_csv_auto('cin_maternal/data/processed/non_repeating.csv',
    all_varchar = true,
    header = true
  )
")

message("Loaded table: maternal_core")

# ------------------------------------------------------------------------------
# Load repeating instruments
# ------------------------------------------------------------------------------
repeating_files <- list.files(
  here::here("cin_maternal", "data", "processed", "repeating"),
  pattern = "\\.csv$",
  full.names = TRUE
)

for (f in repeating_files) {
  table_name <- tools::file_path_sans_ext(basename(f))

  DBI::dbExecute(con, sprintf("
    CREATE OR REPLACE TABLE %s AS
    SELECT * FROM read_csv_auto('%s',
      all_varchar = true,
      header = true
    )
  ", table_name, f))

  message("Loaded table: ", table_name)
}

# ------------------------------------------------------------------------------
# Confirm tables loaded
# ------------------------------------------------------------------------------
tables <- DBI::dbListTables(con)
message("\nTables in DuckDB:")
message(paste(" -", tables, collapse = "\n"))

# ------------------------------------------------------------------------------
# Disconnect
# ------------------------------------------------------------------------------
DBI::dbDisconnect(con, shutdown = TRUE)

message("\nDuckDB ready at: cin_maternal/data/processed/maternal.duckdb")
