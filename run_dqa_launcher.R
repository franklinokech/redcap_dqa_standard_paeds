#!/usr/bin/env Rscript
# run_dqa_launcher.R - Simple version that opens file manager

setwd("~/Desktop/redcap_dqa")
source("cin_maternal/scripts/query_data.R")

cat("\n")
cat("════════════════════════════════════════════════════════════\n")
cat("         CIN MATERNAL - DATA QUALITY ASSESSMENT\n")
cat("════════════════════════════════════════════════════════════\n")
cat("\n")
cat("📊 Running DQA pipeline...\n")
cat("\n")

# Run DQA
result <- run_dqa_queries()

# Open the output directory in file manager
output_dir <- file.path(getwd(), "cin_maternal", "data", "output")
system(paste("xdg-open", shQuote(output_dir)), wait = FALSE)

cat("\n")
cat("════════════════════════════════════════════════════════════\n")
cat("✅ DQA COMPLETE!\n")
cat("\n")
cat("📂 Results folder opened in file manager\n")
cat("\n")
cat("   Double-click these files to view:\n")
cat("   - dqa_issues_*.csv (main issues report)\n")
cat("   - dqa_summary_*.csv (summary by issue type)\n")
cat("\n")
cat("════════════════════════════════════════════════════════════\n")
cat("\nPress Enter to close this window...\n")
readLines(n = 1)