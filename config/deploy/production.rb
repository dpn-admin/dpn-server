# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

set :stage, :production
set :rails_env, 'production'
set :branch, 'master'
set :deploy_to, ENV['DPN_PROD_DEPLOY_DIR']
set :log_level, :debug
set :keep_releases, 3
set :rbenv_custom_path, '/l/local/rbenv'
set :rbenv_ruby, '2.2.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

set :linked_files, %w{.rbenv-vars}


server ENV['DPN_PROD_SERVER'],
       user: 'dpnadm',
       roles: %w{app db web},
       ssh_options: {
           keys: [ENV['DPN_PROD_DEPLOY_KEY']],
           port: 22,
           auth_methods: ['publickey']
       }
