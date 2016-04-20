# tumblr-neo4j

This app will load the data dump generated from Tumblr using [node-tumblr-map](https://github.com/madbence/node-tumblr-map) to Neo4J.

## Requirements

* Either
  * Ruby 2.2.x
  * Neo4j 3.x
  * Node.js 4.4.x
  * Nginx 1.9.x
* Or
  * Docker (including Docker Toolbox on Windows and Mac OSX)
* The resulting log file from step 1 of running [node-tumblr-map](https://github.com/madbence/node-tumblr-map)

## Install and usage

If you are not using docker:

1. Run `app.js` from [node-tumblr-map](https://github.com/madbence/node-tumblr-map) and save the standard output to a file called `dump.log`
2. Run `ruby/convert.rb` on `dump.log`
3. Move the  generated `csv` files to `<neo4j_dir>/import`
4. Run `neo4j/load.cyp` to import the data
5. Call `neo4j/pageRank.cyp` a few times, until the iteration doesn't change the values massively.

If you are using docker you can use some scripts inside the `docker` directory to run the steps mentioned above automatically:

1. Copy `docker/oauth.sh.sample` over to `docker/oauth.sh`, and modify it with the appropriate Tumblr OAuth details, then run `docker/generate_dump.sh` to generate `dump.log`.

   > To obtain these values register a new OAuth application on Tumblr at
   >   https://www.tumblr.com/oauth/apps
   > You can use fake values for the URLs. Once done click the 'Explore API' button,
   > click "Show keys" and use the values from there

2. Run `docker/install.sh` to initialize neo4j and import the data

3. Call `docker/page_rank.sh` to run the pageRank algorithm 50 times

4. Call `docker/finalize.sh` to finalize the data, and switch over neo4j to read-only mode

You can also call `docker/clean.sh` to clear up the installation, and delete all generated files

## License

MIT License, see LICENSE for more details
