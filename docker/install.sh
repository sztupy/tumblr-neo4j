#!/usr/bin/env bash
set -e

if [[ $# -eq 0 ]] ; then
    echo 'Please specify which steps to run'
    echo 'Steps:'
    echo '   A: Use the tumblr API to download post dump'
    echo '   B: Initialize neo4j in RW mode with all modules'
    echo '   C: Convert the post dump to CSV'
    echo '   D: Import the CSV into Neo4j'
    echo '   E: Do calculations on the imported data'
    echo '   F: Finalize the database and make it read only. Also starts the browser'
    echo '   G: Backups the blog details which can be saved for statistic purposes'
    echo
    echo 'Note that step A doesn''t finish on it''s own, and has to be cancelled manually'
    echo
    echo 'Examples:'
    echo "  To run the main steps:"
    echo "    $0 BCDEF"
    echo "  To only generate the dump:"
    echo "    $0 A"
    exit 0
fi

OPTIONS=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/files/oauth.sh"
source "$DIR/files/globals.sh"
cd "$DIR/.."
mkdir -p output

if [[ $OPTIONS == *"A"* ]]; then
 source "$DIR/steps/A1-generate-dump.sh"
fi

if [[ $OPTIONS == *"B"* ]]; then
  source "$DIR/steps/B1-build-pagerank-module.sh"
  source "$DIR/steps/B2-start-neo4j.sh"
fi

if [[ $OPTIONS == *"C"* ]]; then
  source "$DIR/steps/C1-convert-dump-to-csv.sh"
fi

if [[ $OPTIONS == *"D"* ]]; then
  source "$DIR/steps/D1-import-data-to-neo4j.sh"
fi

if [[ $OPTIONS == *"E"* ]]; then
  source "$DIR/steps/E1-calculate-pagerank.sh"
  source "$DIR/steps/E2-calculate-hunblarity.sh"
fi

if [[ $OPTIONS == *"F"* ]]; then
  source "$DIR/steps/F1-make-neo4j-read-only.sh"
fi

if [[ $OPTIONS == *"G"* ]]; then
  source "$DIR/steps/G1-backup-blog-data.sh"
fi

echo "# DONE"
