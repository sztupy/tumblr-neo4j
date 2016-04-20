#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/oauth.sh"
source "$DIR/globals.sh"

mkdir -p output
cp "$DIR/generate_dump_internal.sh" output

docker run -it --rm --name generate-tumblr-dump \
  -e CONSUMER_KEY="$CONSUMER_KEY" \
  -e CONSUMER_SECRET="$CONSUMER_SECRET" \
  -e TOKEN="$TOKEN" \
  -e TOKEN_SECRET="$TOKEN_SECRET" \
  -v "$PWD/output":/usr/src/app -w /usr/src/app \
  $NODE_DOCKER_IMAGE bash generate_dump_internal.sh
