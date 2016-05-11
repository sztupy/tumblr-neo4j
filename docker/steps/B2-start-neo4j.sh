echo "# Loading up neo4j"

docker stop neo4j-tumblr || true
docker rm -f neo4j-tumblr || true

docker run --detach --name neo4j-tumblr \
   --publish 7474:7474 \
   --volume "$DIR/../output/data":/data \
   --volume "$DIR/../output/plugins":/plugins \
   $NEO4J_DOCKER_IMAGE

echo "# Waiting for neo4j to start"

while ! docker logs neo4j-tumblr | grep -m1 'Started.'; do
    docker logs neo4j-tumblr | tail -1
    sleep 1
done
