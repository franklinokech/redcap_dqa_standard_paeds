#!/bin/bash
# Simple script to open results folder
xdg-open /app/cin_neon/data/output 2>/dev/null || echo "Results saved in: /app/cin_neon/data/output"
