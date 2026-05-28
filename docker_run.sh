#!/bin/bash
# =============================================================================
# Run DQA in Docker container and open results
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "         CIN MATERNAL - DQA DOCKER CONTAINER"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠ .env file not found!${NC}"
    echo "Creating from .env.example..."
    cp .env.example .env
    echo -e "${RED}✗ Please edit .env file with your REDCap credentials first!${NC}"
    echo "  Edit: nano .env"
    read -p "Press Enter to exit..."
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}✗ Docker is not running. Please start Docker first.${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

# Build or rebuild
echo "📦 Building Docker image (first time may take a few minutes)..."
docker-compose build

echo ""
echo "🚀 Running DQA pipeline..."
echo ""

# Run the container
docker-compose up --abort-on-container-exit

# Check exit status
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ DQA Complete!${NC}"
    echo ""
    
    # Open results folder
    if [ -d "cin_maternal/data/output" ]; then
        echo "📂 Opening results folder..."
        
        # Check if there are results files
        result_count=$(ls -1 cin_maternal/data/output/dqa_*.csv 2>/dev/null | wc -l)
        
        if [ "$result_count" -gt 0 ]; then
            echo ""
            echo "Results files created:"
            ls -la cin_maternal/data/output/dqa_*.csv 2>/dev/null | awk '{print "  📄 " $9 " (" $5 " bytes)"}'
            echo ""
        fi
        
        # Open the folder in file manager
        xdg-open cin_maternal/data/output 2>/dev/null || \
        nautilus cin_maternal/data/output 2>/dev/null || \
        echo "Results saved in: cin_maternal/data/output/"
    fi
else
    echo ""
    echo -e "${RED}❌ DQA Failed. Check logs above.${NC}"
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Results are saved in: cin_maternal/data/output/"
echo "  You can access this folder anytime from your file manager"
echo "════════════════════════════════════════════════════════════"
echo ""

read -p "Press Enter to close this window..."
