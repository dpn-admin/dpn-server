require Rails.root.join("config/environments/development")



Rails.application.configure do

  node = ENV['IMPERSONATE']
  raise ArgumentError, "Define IMPERSONATE, see config/impersonate.yml" unless node

  settings = YAML.load_file(Rails.root.join("config/impersonate.yml")).symbolize_keys[node.to_sym].symbolize_keys!

  config.secret_key_base = settings[:secret_key_base]

  config.action_mailer.default_url_options = {
    host: 'localhost',
    port: settings[:port]
  }

  config.salt = settings[:salt]
  config.local_namespace = settings[:local_namespace]

end