#!/bin/bash

path=$(basename $(pwd))
[[ $path != 'dpn-server' ]] && echo 'Must run from "dpn-server" path' && exit

rm -f Gemfile.local
bundle install --quiet
bundle exec rake config
git checkout -- db/schema.rb
