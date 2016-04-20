#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/globals.sh"

cd "$DIR/.."

echo "# Generating CSV files"

docker run -ti --rm --name convert-dump \
  -v "$PWD":/usr/src/myapp -w /usr/src/myapp $RUBY_DOCKER_IMAGE \
  ruby ruby/convert.rb output/dump.log

echo "# Loading up neo4j"

docker stop neo4j-tumblr || /usr/bin/env true
docker rm -f neo4j-tumblr || /usr/bin/env true

docker run --detach --name neo4j-tumblr \
   --publish 7474:7474 \
   --volume "$DIR/../output/data":/data \
   $NEO4J_DOCKER_IMAGE

echo "# Waiting for neo4j to start"

while ! docker logs neo4j-tumblr | grep -m1 'Started.'; do
    docker logs neo4j-tumblr | tail -1
    sleep 1
done

echo "# Importing data to neo4j"

docker cp output/tumblrs.csv neo4j-tumblr:/var/lib/neo4j/import
docker cp output/relations.csv neo4j-tumblr:/var/lib/neo4j/import
docker cp output/original.csv neo4j-tumblr:/var/lib/neo4j/import
docker cp neo4j/load.cyp neo4j-tumblr:/var/lib/neo4j/import

docker exec -ti neo4j-tumblr /var/lib/neo4j/bin/neo4j-shell -file /var/lib/neo4j/import/load.cyp

echo "# You can access neo4j at http://$(docker-machine ip || echo '127.0.0.1'):7474"

echo "# DONE"
