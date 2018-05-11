#!/bin/bash

set -e

if [ "$LOGSTASH_BRANCH" ]; then
    echo "Building plugin using Logstash source"
    BASE_DIR=`pwd`
    echo "Downloading branch: $LOGSTASH_BRANCH"
    wget --quiet https://github.com/elastic/logstash/archive/$LOGSTASH_BRANCH.zip
    unzip -q $LOGSTASH_BRANCH.zip -d __logstash
    mv __logstash/*/ $LOGSTASH_PATH
    rm -rf __logstash $LOGSTASH_BRANCH.zip
    cd $LOGSTASH_PATH
    echo "Building plugins with Logstash version:"
    cat versions.yml
    echo "---"
    # We need to build the jars for that specific version
    echo "Running gradle assemble in: `pwd`"
    ./gradlew assemble
    cd $BASE_DIR
    export LOGSTASH_SOURCE=1
else
    echo "Building plugin using released gems on rubygems"
fi
