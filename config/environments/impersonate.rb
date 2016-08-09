require Rails.root.join("config/environments/development")



Rails.application.configure do

  config.active_job.queue_adapter = :inline

  node = ENV['IMPERSONATE']
  raise ArgumentError, "Define IMPERSONATE=node, see config/impersonate.yml" unless node

  config_path = Rails.root.join("config/impersonate.yml.local")
  unless File.exists?(config_path)
    config_path = Rails.root.join("config/impersonate.yml")
  end

  settings = YAML.load_file(config_path)[node].symbolize_keys!

  config.secret_key_base = settings[:secret_key_base]

  config.action_mailer.default_url_options = {
    host: 'localhost',
    port: settings[:port]
  }

  config.salt = settings[:salt]
  config.local_namespace = settings[:local_namespace]

end