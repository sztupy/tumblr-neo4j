echo "# Running pageRank iterations"

docker cp neo4j/pageRank.cyp neo4j-tumblr:/var/lib/neo4j/import

for i in `seq 1 50`;
do
  echo "# Iteration $i"

  docker exec -ti neo4j-tumblr /var/lib/neo4j/bin/neo4j-shell -file /var/lib/neo4j/import/pageRank.cyp
done

echo "# DONE"
