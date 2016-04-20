#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "# Cleaning up docker images"
echo "## Cleaning up Neo4j images"
docker stop neo4j-tumblr || /usr/bin/env true
docker rm -f neo4j-tumblr || /usr/bin/env true

echo "## Cleaning up ruby images"
docker rm -f convert-dump || /usr/bin/env true

echo "## Cleaning up node images"
docker rm -f generate-tumblr-dump || /usr/bin/env true

echo "# Cleaning up output directory"

rm -rf "$DIR/../output"

echo "# DONE"
