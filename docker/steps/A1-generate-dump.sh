cp "$DIR/files/generate_dump_internal.sh" output

docker run -it --rm --name generate-tumblr-dump \
  -e CONSUMER_KEY="$CONSUMER_KEY" \
  -e CONSUMER_SECRET="$CONSUMER_SECRET" \
  -e TOKEN="$TOKEN" \
  -e TOKEN_SECRET="$TOKEN_SECRET" \
  -v "$PWD/output":/usr/src/app -w /usr/src/app \
  $NODE_DOCKER_IMAGE bash generate_dump_internal.sh
