# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

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

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true


  # Load a salt in what is probably not a good place for it.
  config.salt = ENV['DPN_SALT'] || "development_salt"

  # Set the cipher key, iv used to *crypt the auth_tokens other nodes
  # identify us by.
  config.cipher_key = ENV['DPN_CIPHER_KEY'] || "foMXggnM3xLHatbSP0ZXW6ThZXOXqp8ImyaJQ/0Jlqo=\n"
  config.cipher_iv = ENV['DPN_CIPHER_IV'] || "L213BeYaK4QDG8krUaCYnA==\n"

  # Configure the local node's namespace
  config.local_namespace = ENV['DPN_NAMESPACE'] || "hathi"

  # Set the local node's api_root
  config.local_api_root = ENV['DPN_API_ROOT'] || "http://127.0.0.1"

  # Set the staging directory root.
  config.staging_dir = ENV['DPN_STAGING_DIR'] || Rails.root.join("dpnrepo", "staging")

  # Set the preservation root
  # The directory "pairtree_root" will be created in this folder
  config.repo_dir = ENV['DPN_REPO_DIR'] || Rails.root.join("dpnrepo", "preservation")

  # The location of the private key used to pull files from other nodes
  config.transfer_private_key = ENV['DPN_TRANSFER_PRIVATE_KEY'] || "/l/home/dpnadm/.ssh/hathi.key"
end
