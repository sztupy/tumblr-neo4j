echo "# Generating CSV files"

docker run -ti --rm --name convert-dump \
  -v "$PWD":/usr/src/myapp -w /usr/src/myapp $RUBY_DOCKER_IMAGE \
  ruby ruby/convert.rb output/dump.log
