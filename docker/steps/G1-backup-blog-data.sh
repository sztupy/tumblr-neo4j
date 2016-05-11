echo "# Exporting data"

docker cp neo4j/export.cyp neo4j-tumblr:/var/lib/neo4j/import
docker exec -ti neo4j-tumblr /var/lib/neo4j/bin/neo4j-shell -file /var/lib/neo4j/import/export.cyp > output/backup.txt

echo "# Converting to CSV"

export BACKUP_DATE=$(date "+%Y%m%d_%H%M%S")

docker run -ti --rm --name convert-dump \
  -v "$PWD":/usr/src/myapp -w /usr/src/myapp $RUBY_DOCKER_IMAGE \
  ruby ruby/convert_backup_to_csv.rb output/backup.txt > output/backup_$BACKUP_DATE.csv
