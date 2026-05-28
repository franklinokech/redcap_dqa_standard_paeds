#!/bin/bash
# =============================================================================
# Run DQA in development mode (with code mounting)
# =============================================================================

echo ""
echo "════════════════════════════════════════════════════════════"
echo "         CIN MATERNAL - DQA DEV CONTAINER"
echo "════════════════════════════════════════════════════════════"
echo ""

# Build or rebuild
docker-compose -f docker-compose.dev.yml build

echo ""
echo "🚀 Running DQA pipeline in dev mode..."
echo ""

# Run the container
docker-compose -f docker-compose.dev.yml up --abort-on-container-exit

echo ""
echo "✅ Done!"
