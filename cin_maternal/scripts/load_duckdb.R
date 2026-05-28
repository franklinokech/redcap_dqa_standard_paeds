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
library(tools)

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

# Path configuration
DUCKDB_PATH <- here::here("cin_maternal", "data", "processed", "maternal.duckdb")
NON_REPEATING <- here::here("cin_maternal", "data", "processed", "non_repeating.csv")
REPEATING_DIR <- here::here("cin_maternal", "data", "processed", "repeating")

# DuckDB performance settings
MEMORY_LIMIT <- Sys.getenv("DUCKDB_MEMORY_LIMIT", "8GB")
THREADS <- as.integer(Sys.getenv("DUCKDB_THREADS", "4"))

# Load options
ALL_VARCHAR <- TRUE
USE_SAMPLE_FOR_TYPES <- FALSE  # If TRUE, DuckDB will sample to infer types

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
log_success <- function(message) {
  message("  ✓ ", message)
}

#' Log an info message
log_info <- function(message) {
  message("  ℹ ", message)
}

#' Log an error message
log_error <- function(message) {
  message("  ✗ ", message)
}

#' Wrap a table name in double-quotes for safe DuckDB injection
#' @param x Table name
#' @return Quoted table name
dq <- function(x) {
  paste0('"', gsub('"', '""', x), '"')
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

#' Validate input files exist
#' @param non_repeating_path Path to non-repeating CSV
#' @param repeating_dir Directory with repeating CSVs
#' @return TRUE if valid, stops otherwise
validate_input_files <- function(non_repeating_path, repeating_dir) {
  errors <- character()
  
  if (!file.exists(non_repeating_path)) {
    errors <- c(errors, paste("Non-repeating file not found:", non_repeating_path))
  } else if (file.info(non_repeating_path)$size == 0) {
    errors <- c(errors, paste("Non-repeating file is empty:", non_repeating_path))
  } else {
    log_success(paste("Non-repeating file found:", basename(non_repeating_path), 
                      "(", get_file_size(non_repeating_path), ")"))
  }
  
  if (dir.exists(repeating_dir)) {
    repeating_files <- list.files(repeating_dir, pattern = "\\.csv$", full.names = TRUE)
    if (length(repeating_files) > 0) {
      log_info(paste("Found", length(repeating_files), "repeating instrument CSV(s)"))
    } else {
      log_info("No repeating instrument CSV files found")
    }
  } else {
    log_info("Repeating directory does not exist")
  }
  
  if (length(errors) > 0) {
    stop(paste(errors, collapse = "\n"))
  }
  
  return(TRUE)
}

#' Configure DuckDB connection with optimal settings
#' @param con Database connection
configure_duckdb <- function(con) {
  # Set memory limit
  DBI::dbExecute(con, paste0("PRAGMA memory_limit='", MEMORY_LIMIT, "'"))
  log_kv("Memory limit", MEMORY_LIMIT)
  
  # Set threads
  DBI::dbExecute(con, paste0("PRAGMA threads=", THREADS))
  log_kv("Threads", THREADS)
  
  # Enable progress bar for long queries (if available)
  tryCatch({
    DBI::dbExecute(con, "PRAGMA enable_progress_bar=true")
  }, error = function(e) {})
  
  log_success("DuckDB configured")
}

#' Load a CSV into DuckDB and return metadata
#' @param con Database connection
#' @param table_name Name for the table
#' @param csv_path Path to CSV file
#' @return List with metadata (row_count, col_count, load_time)
load_csv_table <- function(con, table_name, csv_path) {
  start_time <- Sys.time()
  
  # Build read_csv_auto options
  read_options <- "all_varchar = true, header = true"
  if (USE_SAMPLE_FOR_TYPES) {
    read_options <- paste0(read_options, ", sample_size = 10000")
  }
  
  # Create table from CSV
  DBI::dbExecute(con, sprintf(
    "CREATE OR REPLACE TABLE %s AS
     SELECT * FROM read_csv_auto(%s, %s)",
    dq(table_name),
    DBI::dbQuoteString(con, csv_path),
    read_options
  ))
  
  # Get row count
  row_count <- DBI::dbGetQuery(con, sprintf("SELECT COUNT(*) AS n FROM %s", dq(table_name)))$n
  
  # Get column count
  col_count <- ncol(DBI::dbGetQuery(con, sprintf("SELECT * FROM %s LIMIT 1", dq(table_name))))
  
  end_time <- Sys.time()
  duration <- difftime(end_time, start_time, units = "secs")
  
  return(list(
    table_name = table_name,
    row_count = row_count,
    col_count = col_count,
    load_time = as.numeric(duration),
    file_path = csv_path
  ))
}

#' Load non-repeating (core) table
#' @param con Database connection
#' @param csv_path Path to non-repeating CSV
#' @return Metadata list
load_core_table <- function(con, csv_path) {
  log_section("Loading core (non-repeating) data")
  
  metadata <- load_csv_table(con, "maternal_core", csv_path)
  
  log_kv("Table name", "maternal_core")
  log_kv("Rows loaded", metadata$row_count)
  log_kv("Columns loaded", metadata$col_count)
  log_kv("Load time", paste0(round(metadata$load_time, 2), " seconds"))
  log_success("Core table loaded")
  
  return(metadata)
}

#' Load all repeating instrument tables
#' @param con Database connection
#' @param repeating_dir Directory with repeating CSVs
#' @return List of metadata for each table
load_repeating_tables <- function(con, repeating_dir) {
  log_section("Loading repeating instruments")
  
  if (!dir.exists(repeating_dir)) {
    log_info("Repeating directory does not exist - no repeating tables to load")
    return(list())
  }
  
  repeating_files <- list.files(repeating_dir, pattern = "\\.csv$", full.names = TRUE)
  
  if (length(repeating_files) == 0) {
    log_info("No repeating instrument CSV files found")
    return(list())
  }
  
  metadata_list <- list()
  
  for (file_path in repeating_files) {
    table_name <- file_path_sans_ext(basename(file_path))
    metadata <- load_csv_table(con, table_name, file_path)
    metadata_list[[table_name]] <- metadata
    
    log_kv(table_name, paste0(metadata$row_count, " rows, ", 
                               metadata$col_count, " cols (", 
                               round(metadata$load_time, 2), "s)"))
  }
  
  log_success(paste(length(metadata_list), "repeating instrument tables loaded"))
  
  return(metadata_list)
}

#' Create indexes for better query performance
#' @param con Database connection
create_indexes <- function(con) {
  log_section("Creating indexes")
  
  # Index on record_id in core table (most common join key)
  tryCatch({
    DBI::dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_core_record_id ON maternal_core(record_id)")
    log_success("Created index: idx_core_record_id")
  }, error = function(e) {
    log_info("Could not create index on maternal_core(record_id): ", e$message)
  })
  
  # Index on datetime_entry for date range queries
  tryCatch({
    DBI::dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_core_datetime ON maternal_core(datetime_entry)")
    log_success("Created index: idx_core_datetime")
  }, error = function(e) {
    log_info("Could not create index on maternal_core(datetime_entry): ", e$message)
  })
  
  log_success("Index creation complete")
}

#' Generate summary of all loaded tables
#' @param con Database connection
#' @param core_metadata Metadata for core table
#' @param repeating_metadata List of metadata for repeating tables
generate_summary <- function(con, core_metadata = NULL, repeating_metadata = list()) {
  log_section("Tables loaded")
  
  all_tables <- DBI::dbListTables(con)
  total_rows <- 0
  
  for (tbl in sort(all_tables)) {
    row_count <- DBI::dbGetQuery(con, sprintf("SELECT COUNT(*) AS n FROM %s", dq(tbl)))$n
    total_rows <- total_rows + row_count
    
    # Determine if this is a core or repeating table
    if (tbl == "maternal_core" && !is.null(core_metadata)) {
      log_kv(tbl, paste0(row_count, " rows (core table)"))
    } else {
      col_count <- ncol(DBI::dbGetQuery(con, sprintf("SELECT * FROM %s LIMIT 1", dq(tbl))))
      log_kv(tbl, paste0(row_count, " rows, ", col_count, " cols"))
    }
  }
  
  cat("\n")
  log_kv("Total tables", length(all_tables))
  log_kv("Total rows across all tables", total_rows)
}

#' Run the complete DuckDB loading pipeline
#' @param duckdb_path Path to DuckDB file (optional)
#' @param non_repeating_path Path to non-repeating CSV (optional)
#' @param repeating_dir Directory with repeating CSVs (optional)
#' @return List with loading results
run_loading_pipeline <- function(
  duckdb_path = DUCKDB_PATH,
  non_repeating_path = NON_REPEATING,
  repeating_dir = REPEATING_DIR
) {
  # Record start time
  start_time <- Sys.time()
  
  message(strrep("=", 60))
  message("CIN MATERNAL - DUCKDB LOADING PIPELINE")
  message("Started at: ", start_time)
  message(strrep("=", 60))
  
  # Validate input files
  validate_input_files(non_repeating_path, repeating_dir)
  
  # Connect to DuckDB
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_path)
  on.exit({
    DBI::dbDisconnect(con, shutdown = TRUE)
    message("\n✓ DuckDB connection closed")
  }, add = TRUE)
  
  # Configure DuckDB
  configure_duckdb(con)
  
  # Load core table
  core_metadata <- load_core_table(con, non_repeating_path)
  
  # Load repeating tables
  repeating_metadata <- load_repeating_tables(con, repeating_dir)
  
  # Create indexes
  create_indexes(con)
  
  # Generate summary
  generate_summary(con, core_metadata, repeating_metadata)
  
  # Record end time
  end_time <- Sys.time()
  duration <- difftime(end_time, start_time, units = "secs")
  
  # Final summary
  message("\n", strrep("=", 60))
  message("✓ Loading completed successfully")
  message("  Duration: ", round(duration, 2), " seconds")
  message("  Database: ", duckdb_path)
  message("  Database size: ", get_file_size(duckdb_path))
  message("Finished at: ", end_time)
  message(strrep("=", 60))
  
  # Return results invisibly
  return(invisible(list(
    duckdb_path = duckdb_path,
    core_metadata = core_metadata,
    repeating_metadata = repeating_metadata,
    duration = duration
  )))
}

# ------------------------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------------------------

#' Main function - called when script is run directly
main <- function() {
  result <- run_loading_pipeline()
  return(result)
}

# Run main if script is executed directly
if (interactive() || sys.nframe() == 0L) {
  main()
}