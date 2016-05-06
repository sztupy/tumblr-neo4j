#!/usr/bin/env bash

set -e

cd /root
git clone https://github.com/sztupy/node-tumblr-map.git

cd node-tumblr-map
npm i
node_modules/.bin/babel-node app > /usr/src/app/dump.log
