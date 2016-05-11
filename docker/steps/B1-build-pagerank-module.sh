echo '# building pagerank module'

cd "$DIR/../java"

mkdir -p "$DIR/../output/plugins"

docker rm -f neo4j-modules

docker run -it --name neo4j-modules \
  -v "$PWD":/usr/src/mymaven \
  -w /usr/src/mymaven \
  $MAVEN_DOCKER_IMAGE mvn clean package

docker stop neo4j-tumblr || true

docker cp neo4j-modules:/usr/src/mymaven/target/pagerank.jar ../output/plugins

cd "$DIR/.."
