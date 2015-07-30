set :stage, :production

set :deploy_to, '/htapps/babel/dpn'
set :log_level, :debug
set :keep_releases, 3
set :rbenv_custom_path, '/l/local/rbenv'
set :rbenv_ruby, '2.2.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

set :linked_files, %w{.rbenv-vars}


server 'yuengling.umdl.umich.edu',
       user: 'dpnadm',
       roles: %w{app db web},
       ssh_options: {
           keys: ['~/.ssh/id_rsa-dpncap'],
           port: 22,
           auth_methods: ['publickey']
       }
