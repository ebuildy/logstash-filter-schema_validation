#!/bin/bash

set -e

echo "Starting build process in: `pwd`"
source ./ci/bin/setup.sh

echo "Running default build scripts in: `pwd`/ci/bin/build.sh"
bundle install
bundle exec rake vendor
bundle exec rspec spec
