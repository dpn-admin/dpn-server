#!/bin/bash

git checkout api-v1-mysql-specs && \
bundle install && \
bundle exec rake config && \
RAILS_ENV=test bundle exec rake db:reset && \
git checkout develop-mysql && \
bundle install && \
bundle exec rake config && \
RAILS_ENV=test bundle exec rake db:migrate
