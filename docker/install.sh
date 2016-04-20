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

docker stop neo4j-tumblr || true
docker rm -f neo4j-tumblr || true

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

echo "# Starting up nginx"

docker stop nginx-tumblr || true
docker rm -f nginx-tumblr || true

docker run -d --name nginx-tumblr \
  -v $PWD/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $PWD/nginx/html:/usr/share/nginx/html:ro \
  -p 80:80 \
  --link neo4j-tumblr:neo4j-tumblr \
  $NGINX_DOCER_NAME

echo "# You can access the site at http://$(docker-machine ip || echo '127.0.0.1')"

echo "# DONE"
