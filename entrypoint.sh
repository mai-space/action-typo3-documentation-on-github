#!/bin/bash
set -e

echo "#################################################"
echo "> Starting ${GITHUB_WORKFLOW}:${GITHUB_ACTION}"

# Available env
echo "DOCUPATH: ${DOCUPATH}"

# Get the absolute path of the current directory
current_dir=$(dirname "$(readlink -f "$0")")

# Start Docker container
docker run --rm -t -d \
  --name docs \
  --volume "$current_dir/:/PROJECT:ro" \
  --volume "$current_dir/Documentation-GENERATED-temp:/RESULT" \
  ghcr.io/t3docs/render-documentation:latest \
  makehtml

# Build documentation inside the Docker container
docker exec -it docs makehtml

# Trigger gh-pages deployment
publish_dir="Documentation-GENERATED-temp/Result/project/0.0.0"

echo "Deploying to gh-pages..."
curl -X POST "https://api.github.com/repos/$GITHUB_REPOSITORY/pages/builds" -H "Authorization: Bearer $GITHUB_TOKEN"

# Stop Docker container
docker stop docs
docker rm docs

echo "#################################################"
echo "Completed ${GITHUB_WORKFLOW}:${GITHUB_ACTION}"