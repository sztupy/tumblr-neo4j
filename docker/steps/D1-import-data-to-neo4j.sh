echo "# Importing data to neo4j"

docker cp output/blog.csv neo4j-tumblr:/var/lib/neo4j/import
docker cp output/thread.csv neo4j-tumblr:/var/lib/neo4j/import
docker cp output/comment.csv neo4j-tumblr:/var/lib/neo4j/import
docker cp output/like.csv neo4j-tumblr:/var/lib/neo4j/import
docker cp output/reblog.csv neo4j-tumblr:/var/lib/neo4j/import
docker cp neo4j/load.cyp neo4j-tumblr:/var/lib/neo4j/import

docker exec -ti neo4j-tumblr /var/lib/neo4j/bin/neo4j-shell -file /var/lib/neo4j/import/load.cyp
