
module Deprecated
class SecretsDotYamlGenerator < Rails::Generators::Base
  CONTENTS = <<-EOF
# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

development:
  secret_key_base: 2ea1fbd4ac4699fd0e31096b51ef545b482d9ad4bd40ca7a07276a6712e45dccb821a88bc2adc09793b0ddc2be19e16068c48286ab659aad7807a8e5c1b32c3a

test:
  secret_key_base: 525e7a0e528c0972699d038ef6a5eb35c493cd6db6db85baf0bf756ba59aeb50a2f5bd38b421d61cc99683df3da779048ec615a5fd72e62c65a86f3f71edcc25

# Do not keep production secrets in the repository,
# instead read values from the environment.
demo:
  secret_key_base: <%= ENV["DPN_SECRET_KEY"] %>

production:
  secret_key_base: <%= ENV["DPN_SECRET_KEY"] %>
  salt: <%= ENV["DPN_SALT"] %>
  cipher_key: <%= ENV["DPN_CIPHER_KEY"] %>
  cipher_iv: <%= ENV["DPN_CIPHER_IV"] %>
  local_namespace: <%= ENV["DPN_NAMESPACE"] %>
  local_api_root: <%= ENV["DPN_API_ROOT"] %>
  staging_dir: <%= ENV["DPN_STAGING_DIR"] %>
  repo_dir: <%= ENV["DPN_REPO_DIR"] %>
  transfer_private_key: <%= ENV["DPN_TRANSFER_PRIVATE_KEY"] %>

EOF

  def create
    create_file "config/secrets.yml", CONTENTS
  end
end
