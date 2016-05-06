# tumblr-neo4j

This app will load the data dump generated from Tumblr using
[node-tumblr-map](https://github.com/sztupy/node-tumblr-map) to Neo4J.

## Requirements

* Docker 1.8+ (including Docker Toolbox on Windows and Mac OSX)
* The resulting log file from step 1 of running
  [node-tumblr-map](https://github.com/sztupy/node-tumblr-map)

## Install and usage

You can use the `docker/install.sh` script to run the build steps that are
required. As some steps might take a while to run, you can also use the script
to only run, or re-run part of the build process.

1. Copy `docker/files/oauth.sh.sample` over to `docker/files/oauth.sh`, and
   modify it with the appropriate Tumblr OAuth details, then run
   `docker/install.sh A` to generate `dump.log`.

   > To obtain these values register a new OAuth application on Tumblr at
   >   https://www.tumblr.com/oauth/apps
   > You can use fake values for the URLs. Once done click the 'Explore API'
   > button, click "Show keys" and use the values from there

   Note that this step might not exit once it has finished downloading the dump,
   and you have to exit it manually. The download process might take up to a day
   to finish!

2. Run `docker/install.sh BCDEF` to run the rest of the importing steps. They
   don't require Tumblr access anymore, but some steps might still take a while
   to complete.

You can also call `docker/clean.sh` to clear up the installation, and delete all
generated files

## Non docker usage

You can also install the necessary packages (neo4j, maven, node.js, ruby, etc.)
to your machine without docker, and run the commands locally. You can check what
commands need to be run inside the `docker/steps` directory.

## License

MIT License, see LICENSE for more details
