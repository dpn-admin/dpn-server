# Minimal configuration for building a DPN-Server test instance.
# This version pulls Release v2.0.0_rc2
#
# There are a few customizations for running it in your environment
# - Run parameters
# -  docker run -it --net=host --name test <tag name> /bin/bash
# -  --net=host makes the instance visible on your local network
# -  any service locked down to localhost will need to be modified to allow the host IP
# -  you'll get a bash prompt to make changes in your local environment
# -  type exit to close the shell
#
# -  if you want to preserve changes do a commit
# -  docker ps -l
# -  docker commit <CONTAINER ID> dpcolar/dpn-server:v2
#
FROM ruby:2.3.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs nano
ENV Release_dir dpn-server-2.0.0-rc3
## Set your Build Tag
#RUN git clone -b develop https://05e801de9e189473e41e37cb738106c37d7a157d:x-oauth-basic@github.com/dpn-admin/dpn-server.git /dpn-server
RUN curl https://codeload.github.com/dpn-admin/dpn-server/tar.gz/v2.0.0-rc3 \
    | tar -zvxf -
WORKDIR  $Release_dir
## Gemfile.local should be in your CWD
COPY Gemfile.local /$Release_dir/Gemfile.local 
RUN gem install bundler
RUN bundle install --path .bundle
RUN bundle exec rake config
RUN bundle exec rake db:setup
#RUN bundle exec rspec
ADD . /$Release_dir
EXPOSE 80
EXPOSE 443
