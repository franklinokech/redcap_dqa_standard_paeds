# ==============================================================================
# Project: CIN Maternal
# Script: query_data.R
# Description: Run DQA queries against DuckDB and generate issue reports
# ==============================================================================

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------
library(duckdb)
library(DBI)
library(glue)
library(dplyr)

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

#' Get project root directory (works in both interactive and shell mode)
get_project_root <- function() {
  # Try to find .git directory or .Rproj file
  current_dir <- getwd()
  
  # Walk up until we find a marker file
  while (!file.exists(file.path(current_dir, ".git")) &&
         !file.exists(file.path(current_dir, ".Rproj.user")) &&
         !file.exists(file.path(current_dir, "cin_maternal"))) {
    new_dir <- dirname(current_dir)
    if (new_dir == current_dir) {
      # Reached root, use working directory
      return(getwd())
    }
    current_dir <- new_dir
  }
  return(current_dir)
}

#' Get configuration from environment variables or defaults
get_config <- function() {
  project_root <- get_project_root()
  
  list(
    start_date = Sys.getenv("DQA_START_DATE", "2025-09-08"),
    end_date = Sys.getenv("DQA_END_DATE", "2026-05-27"),
    db_path = Sys.getenv("DUCKDB_PATH", 
      file.path(project_root, "cin_maternal", "data", "processed", "maternal.duckdb")),
    output_dir = Sys.getenv("DQA_OUTPUT_DIR",
      file.path(project_root, "cin_maternal", "data", "output")),
    project_name = Sys.getenv("PROJECT_NAME", "cin_maternal"),
    sql_file = Sys.getenv("DQA_SQL_FILE",
      file.path(project_root, "cin_maternal", "scripts", "sql", "dqa_queries.sql"))
  )
}

#' Log a message with timestamp
log_message <- function(msg, type = "info") {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  icon <- switch(type,
    info = "ℹ",
    success = "✓",
    error = "✗",
    warning = "⚠"
  )
  cat(sprintf("[%s] %s %s\n", timestamp, icon, msg))
}

#' Ensure output directory exists
ensure_output_dir <- function(dir) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    log_message(paste("Created output directory:", dir), "info")
  }
}

#' Generate summary statistics from issues
generate_summary <- function(df_issues) {
  if (is.null(df_issues) || nrow(df_issues) == 0) {
    return(data.frame(
      variable = character(),
      issue = character(),
      count = integer(),
      stringsAsFactors = FALSE
    ))
  }
  
  summary <- df_issues |>
    group_by(variable, issue) |>
    summarise(count = n(), .groups = "drop") |>
    arrange(desc(count))
  
  return(summary)
}

# ------------------------------------------------------------------------------
# Query Functions
# ------------------------------------------------------------------------------

#' Connect to DuckDB database
connect_to_duckdb <- function(db_path) {
  log_message(paste("Connecting to DuckDB:", db_path), "info")
  
  con <- dbConnect(duckdb::duckdb(), dbdir = db_path)
  
  # Configure DuckDB for performance
  dbExecute(con, "PRAGMA memory_limit='4GB'")
  dbExecute(con, "PRAGMA threads=2")
  
  log_message("Connected successfully", "success")
  return(con)
}

#' Execute DQA query
execute_dqa_query <- function(con, sql_file, start_date, end_date) {
  log_message("Executing DQA query...", "info")
  log_message(paste("Date range:", start_date, "to", end_date), "info")
  
  # Check if SQL file exists
  if (!file.exists(sql_file)) {
    stop("SQL file not found: ", sql_file)
  }
  
  # Read SQL file
  sql_query <- readChar(sql_file, file.info(sql_file)$size)
  
  # Replace placeholders with actual dates
  sql_query <- glue::glue(sql_query)
  
  start_time <- Sys.time()
  df_issues <- dbGetQuery(con, sql_query)
  end_time <- Sys.time()
  duration <- difftime(end_time, start_time, units = "secs")
  
  log_message(paste("Query completed in", round(duration, 2), "seconds"), "success")
  log_message(paste("Rows returned:", nrow(df_issues)), "info")
  
  return(df_issues)
}

#' Save issues to CSV files
save_issues_to_csv <- function(df_issues, output_dir) {
  ensure_output_dir(output_dir)
  
  # Main issues file
  issues_file <- file.path(output_dir, paste0("dqa_issues_", format(Sys.Date(), "%Y%m%d"), ".csv"))
  write.csv(df_issues, issues_file, row.names = FALSE)
  log_message(paste("Issues saved to:", issues_file), "success")
  
  output_files <- list(issues = issues_file)
  
  # Generate and save summary if there are issues
  if (nrow(df_issues) > 0) {
    summary <- generate_summary(df_issues)
    summary_file <- file.path(output_dir, paste0("dqa_summary_", format(Sys.Date(), "%Y%m%d"), ".csv"))
    write.csv(summary, summary_file, row.names = FALSE)
    log_message(paste("Summary saved to:", summary_file), "success")
    output_files$summary <- summary_file
  } else {
    log_message("No issues found!", "success")
  }
  
  return(output_files)
}

#' Print summary to console
print_console_summary <- function(df_issues) {
  cat("\n", strrep("=", 60), "\n", sep = "")
  cat("DQA RESULTS SUMMARY\n")
  cat(strrep("=", 60), "\n", sep = "")
  
  if (nrow(df_issues) == 0) {
    cat("✓ No data quality issues found!\n")
  } else {
    cat("Total issues found:", nrow(df_issues), "\n")
    cat("Unique variables with issues:", length(unique(df_issues$variable)), "\n\n")
    
    # Top 10 issues by variable
    cat("Top 10 variables with most issues:\n")
    top_vars <- df_issues |>
      group_by(variable) |>
      summarise(count = n(), .groups = "drop") |>
      arrange(desc(count)) |>
      head(10)
    
    for (i in seq_len(nrow(top_vars))) {
      cat(sprintf("  %2d. %-35s: %6d issues\n", 
        i, top_vars$variable[i], top_vars$count[i]))
    }
  }
  
  cat(strrep("=", 60), "\n", sep = "")
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------

#' Run DQA queries and generate reports
run_dqa_queries <- function() {
  # Record start time
  start_time <- Sys.time()
  
  # Get configuration
  config <- get_config()
  
  cat(strrep("=", 60), "\n")
  cat("CIN MATERNAL - DQA QUERY PIPELINE\n")
  cat("Started at:", format(start_time), "\n")
  cat("Project:", config$project_name, "\n")
  cat("Working directory:", getwd(), "\n")
  cat(strrep("=", 60), "\n\n")
  
  # Validate database exists
  if (!file.exists(config$db_path)) {
    stop("DuckDB database not found: ", config$db_path, 
         "\nPlease run load_duckdb.R first")
  }
  
  # Validate SQL file exists
  if (!file.exists(config$sql_file)) {
    stop("SQL file not found: ", config$sql_file)
  }
  
  # Connect to database
  con <- connect_to_duckdb(config$db_path)
  on.exit({
    dbDisconnect(con, shutdown = TRUE)
    log_message("Database connection closed", "info")
  }, add = TRUE)
  
  # Execute query
  df_issues <- execute_dqa_query(con, config$sql_file, config$start_date, config$end_date)
  
  # Print console summary
  print_console_summary(df_issues)
  
  # Save results
  output_files <- save_issues_to_csv(df_issues, config$output_dir)
  
  # Record end time
  end_time <- Sys.time()
  duration <- difftime(end_time, start_time, units = "secs")
  
  cat("\n", strrep("=", 60), "\n", sep = "")
  cat("✓ DQA pipeline completed successfully\n")
  cat("  Duration:", round(duration, 2), "seconds\n")
  cat("  Output directory:", config$output_dir, "\n")
  cat("Finished at:", format(end_time), "\n")
  cat(strrep("=", 60), "\n", sep = "")
  
  # Return results invisibly
  return(invisible(list(
    issues = df_issues,
    output_files = output_files,
    duration = duration,
    config = config
  )))
}

# ------------------------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------------------------

# Run if script is executed directly
if (interactive() || sys.nframe() == 0L) {
  run_dqa_queries()
}