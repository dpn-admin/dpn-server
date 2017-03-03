# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.  Also, these settings will be supplemented by
  # config/dpn.yml when it is loaded by config/initializers/dpn.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = {
    host: 'localhost',
    port: 3000
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # From https://github.com/winebarrel/activerecord-mysql-reconnect
  config.active_record.enable_retry = true
  #config.active_record.retry_databases = :employees
  # e.g. [:employees]
  #      ['employees', 'localhost:test', '192.168.1.1:users']
  #      ['192.168.%:emp\_all']
  #      ['emp%']
  # retry_databases -> nil: retry all databases (default)
  config.active_record.execution_tries = 3 # times
  # execution_tries -> 0: retry indefinitely
  config.active_record.execution_retry_wait = 1.0 # sec
  config.active_record.retry_mode = :rw # options: `:r`, `:rw`, `:force`

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all
  # assets, yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Load a salt in what is probably not a good place for it.
  config.salt = Rails.application.secrets.salt

  # Set the cipher key used to *crypt the auth_tokens other nodes
  # identify us by.
  config.cipher_key = Rails.application.secrets.cipher_key
  config.cipher_iv = Rails.application.secrets.cipher_iv

  # The location of the private key used to pull files from other nodes
  config.transfer_private_key = Rails.application.secrets.transfer_private_key
end
