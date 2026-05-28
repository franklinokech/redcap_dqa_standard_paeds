#!/usr/bin/env Rscript
# =============================================================================
# run_dqa.R - Complete DQA pipeline: Fetch → Process → Load → Query
# =============================================================================

options(stringsAsFactors = FALSE)

# Load required libraries
library(here)
library(dotenv)

# Set working directory to project root
project_root <- "/app"
if (!dir.exists(project_root)) {
  project_root <- here::here()
}
setwd(project_root)

# Load environment variables if .env exists
env_file <- file.path(project_root, ".env")
if (file.exists(env_file)) {
  dotenv::load_dot_env(env_file)
  cat("✅ Loaded .env from:", env_file, "\n")
} else {
  cat("⚠️  No .env file found at:", env_file, "\n")
  cat("   Using environment variables from docker-compose\n")
}

cat("\n")
cat("════════════════════════════════════════════════════════════\n")
cat("         CIN MATERNAL - COMPLETE DQA PIPELINE\n")
cat("════════════════════════════════════════════════════════════\n")
cat("\n")
cat("Data source:", Sys.getenv("DATA_SOURCE", "not set"), "\n")
cat("Start date:", Sys.getenv("DQA_START_DATE", "2025-09-08"), "\n")
cat("End date:", Sys.getenv("DQA_END_DATE", "2026-05-27"), "\n")
cat("\n")

# =============================================================================
# STEP 1: Fetch data from REDCap
# =============================================================================
cat("📡 STEP 1: Fetching data from REDCap\n")
cat("────────────────────────────────────────────────────────────\n")

data_source <- Sys.getenv("DATA_SOURCE", "local")

if (data_source == "redcap") {
  source("/app/cin_maternal/scripts/fetch_data.R")
  main()
  cat("\n")
} else {
  cat("ℹ️  DATA_SOURCE = 'local' - Skipping REDCap fetch\n")
  cat("   Using existing data from /app/cin_maternal/data/raw/\n\n")
}

# =============================================================================
# STEP 2: Process data (split repeating instruments)
# =============================================================================
cat("🔄 STEP 2: Processing data\n")
cat("────────────────────────────────────────────────────────────\n")

source("/app/cin_maternal/scripts/data_processing.R")
run_processing_pipeline()
cat("\n")

# =============================================================================
# STEP 3: Load data into DuckDB
# =============================================================================
cat("💾 STEP 3: Loading data into DuckDB\n")
cat("────────────────────────────────────────────────────────────\n")

source("/app/cin_maternal/scripts/load_duckdb.R")
run_loading_pipeline()
cat("\n")

# =============================================================================
# STEP 4: Run DQA queries
# =============================================================================
cat("📊 STEP 4: Running DQA queries\n")
cat("────────────────────────────────────────────────────────────\n")

source("/app/cin_maternal/scripts/query_data.R")
result <- run_dqa_queries()
cat("\n")

# =============================================================================
# Summary
# =============================================================================
output_dir <- "/app/cin_maternal/data/output"

cat("\n")
cat("════════════════════════════════════════════════════════════\n")
cat("✅ COMPLETE DQA PIPELINE FINISHED!\n")
cat("\n")
cat("📁 Results saved to: ", output_dir, "\n")
cat("\n")

if (dir.exists(output_dir)) {
  files <- list.files(output_dir, pattern = "\\.csv$")
  for (f in files) {
    file_size <- file.info(file.path(output_dir, f))$size
    cat("   📄 ", f, " (", format(file_size, big.mark = ","), " bytes)\n", sep = "")
  }
}

cat("\n")
cat("════════════════════════════════════════════════════════════\n")

# Instead of system(paste("xdg-open", ...))
system("/app/cin_maternal/scripts/open_results.sh", wait = FALSE)