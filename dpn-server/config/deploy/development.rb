set :stage, :development

set :deploy_to, '/l/local/dpn'
set :log_level, :debug
set :keep_releases, 2
set :rbenv_custom_path, '/usr/local/rbenv'
set :rbenv_ruby, '2.2.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

# sdr
server '192.168.33.11',
       user: 'dpnadm',
       roles: %w{app db web},
       ssh_options: {
           keys: ['~/.ssh/id_rsa-dpncap'],
           port: 22,
           auth_methods: ['publickey']
       }

# tdr
server '192.168.33.12',
       user: 'dpnadm',
       roles: %w{app db web},
       ssh_options: {
           keys: ['~/.ssh/id_rsa-dpncap'],
           port: 22,
           auth_methods: ['publickey']
       }

# chron
server '192.168.33.13',
       user: 'dpnadm',
       roles: %w{app db web},
       ssh_options: {
           keys: ['~/.ssh/id_rsa-dpncap'],
           port: 22,
           auth_methods: ['publickey']
       }