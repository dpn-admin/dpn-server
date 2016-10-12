# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  config.active_job.queue_adapter = :test

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static file server for tests with Cache-Control for performance.
  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = {
      host: 'localhost',
      port: 3000
  }

  # Randomize the order test cases are executed.
  config.active_support.test_order = :random

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

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

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.salt = "development_salt"
  config.cipher_key = "foMXggnM3xLHatbSP0ZXW6ThZXOXqp8ImyaJQ/0Jlqo=\n"
  config.cipher_iv = "L213BeYaK4QDG8krUaCYnA==\n"
  config.transfer_private_key = "/tmp/dpnxfr_private_key_test"
end
