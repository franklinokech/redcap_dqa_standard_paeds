#!/bin/bash
# run_dqa.sh - Shell wrapper for data clerk launcher

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Run the R script
Rscript run_dqa_launcher.R

# Keep terminal open on error
if [ $? -ne 0 ]; then
    echo ""
    echo "An error occurred. Press Enter to close..."
    read
fi