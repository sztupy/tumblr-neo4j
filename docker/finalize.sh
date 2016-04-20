#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/globals.sh"

cd "$DIR/.."

echo "# Calculating hunblarity"
docker cp neo4j/hunblarity.cyp neo4j-tumblr:/var/lib/neo4j/import
docker exec -ti neo4j-tumblr /var/lib/neo4j/bin/neo4j-shell -file /var/lib/neo4j/import/hunblarity.cyp

echo "# Stopping neo4j"
docker stop neo4j-tumblr || true
docker rm neo4j-tumblr || true

echo "# Dumping default configuration"
rm -rf "$DIR/../output/conf"
docker run --rm \
    --volume="$DIR/../output/conf":/conf \
    neo4j/neo4j:milestone dump-config

echo "# Modifying config"

sed -i.bak "s/#dbms.read_only=false/dbms.read_only=true/" "$DIR/../output/conf/neo4j.conf"
sed -i.bak "s/#dbms.security.auth_enabled=false/dbms.security.auth_enabled=false/" "$DIR/../output/conf/neo4j.conf"
sed -i.bak "s/#dbms.connector.http.address=0.0.0.0:7474/dbms.connector.http.address=0.0.0.0:7474/" "$DIR/../output/conf/neo4j.conf"

echo "# Restarting neo4j"

docker run --detach --name neo4j-tumblr \
   --publish 7474:7474 \
   --volume "$DIR/../output/data":/data \
   --volume="$DIR/../output/conf":/conf \
   $NEO4J_DOCKER_IMAGE

echo "# Restarting nginx"

docker stop nginx-tumblr || true
docker rm -f nginx-tumblr || true

docker run -d --name nginx-tumblr \
  -v $PWD/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $PWD/nginx/html:/usr/share/nginx/html:ro \
  -p 80:80 \
  --link neo4j-tumblr:neo4j-tumblr \
  $NGINX_DOCER_NAME

echo "# DONE"
