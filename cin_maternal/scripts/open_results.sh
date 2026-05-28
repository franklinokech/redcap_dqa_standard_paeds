#!/bin/bash
# Simple script to open results folder
xdg-open /app/cin_maternal/data/output 2>/dev/null || echo "Results saved in: /app/cin_maternal/data/output"
