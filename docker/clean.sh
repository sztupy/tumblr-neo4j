#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "# Cleaning up docker images"
echo "## Cleaning up Java images"
docker rm -f neo4j-modules || true

echo "## Cleaning up Neo4j images"
docker stop neo4j-tumblr || true
docker rm -f neo4j-tumblr || true

echo "## Cleaning up ruby images"
docker rm -f convert-dump || true

echo "## Cleaning up node images"
docker rm -f generate-tumblr-dump || true

echo "## Cleaning up NGINX"
docker stop nginx-tumblr || true
docker rm -f nginx-tumblr || true

echo "# Cleaning up output directory"

rm -rf "$DIR/../output"
rm -rf "$DIR/../java/target"

echo "# DONE"
