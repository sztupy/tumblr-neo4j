#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/globals.sh"

cd "$DIR/.."

echo "# Stopping neo4j"
docker stop neo4j-tumblr || /bin/true
docker rm neo4j-tumblr || /bin/true

echo "# Dumping default configuration"
rm -rf "$DIR/../output/conf"
docker run --rm \
    --volume="$DIR/../output/conf":/conf \
    neo4j/neo4j:milestone dump-config

echo "# Modifying config"

sed -i'' "s/#dbms.read_only=false/dbms.read_only=true/" "$DIR/../output/conf/neo4j.conf"
sed -i'' "s/#dbms.security.auth_enabled=false/dbms.security.auth_enabled=false/" "$DIR/../output/conf/neo4j.conf"
sed -i'' "s/#dbms.connector.http.address=0.0.0.0:7474/dbms.connector.http.address=0.0.0.0:7474/" "$DIR/../output/conf/neo4j.conf"

echo "# Restarting neo4j"

docker run --detach --name neo4j-tumblr \
   --publish 7474:7474 \
   --volume "$DIR/../output/data":/data \
   --volume="$DIR/../output/conf":/conf \
   $NEO4J_DOCKER_IMAGE

echo "# DONE"
