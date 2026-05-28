#!/bin/bash
# =============================================================================
# Clean Docker containers, images, and volumes
# =============================================================================

echo "🧹 Cleaning Docker containers..."

# Stop and remove containers
docker-compose down -v 2>/dev/null
docker-compose -f docker-compose.dev.yml down -v 2>/dev/null

# Remove dangling images
docker image prune -f

echo "✅ Cleanup complete!"
