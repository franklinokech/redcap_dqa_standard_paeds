# =============================================================================
# CIN Maternal DQA - Dockerfile
# =============================================================================

# Use official R image with tidyverse
FROM rocker/tidyverse:4.4.0

# Set environment variables
ENV RENV_VERSION 1.0.7
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV RENV_PATHS_CACHE /renv/cache

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libv8-dev \
    cmake \
    xz-utils \
    libbz2-dev \
    liblzma-dev \
    libzstd-dev \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

# Set working directory
WORKDIR /app

# Copy renv files first (for better caching)
COPY renv.lock .
COPY renv/ ./renv/

# Restore R packages using renv
RUN R -e "renv::restore()"

# Install DuckDB ICU extension (fix for date/time issues)
RUN R -e "library(DBI); library(duckdb); con <- dbConnect(duckdb()); dbExecute(con, 'INSTALL icu'); dbExecute(con, 'LOAD icu'); dbDisconnect(con, shutdown=TRUE)"

# Copy project files
COPY . .

# Create necessary directories
RUN mkdir -p /app/cin_maternal/data/raw \
    /app/cin_maternal/data/processed \
    /app/cin_maternal/data/processed/repeating \
    /app/cin_maternal/data/output \
    /app/cin_maternal/logs

# Make scripts executable
RUN chmod +x /app/cin_maternal/scripts/*.R 2>/dev/null || true
RUN chmod +x /app/*.sh 2>/dev/null || true

# Default command
CMD ["Rscript", "/app/cin_maternal/scripts/run_dqa.R"]