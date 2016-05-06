echo "# Calculating hunblarity"
docker cp neo4j/hunblarity.cyp neo4j-tumblr:/var/lib/neo4j/import
docker exec -ti neo4j-tumblr /var/lib/neo4j/bin/neo4j-shell -file /var/lib/neo4j/import/hunblarity.cyp
