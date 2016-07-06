# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'securerandom'

Fabricator(:node) do |f|
  f.namespace { Faker::Internet.password(10, 20) }
  name { Faker::Company.name }
  ssh_pubkey { Faker::Internet.password(20) }
  storage_region
  storage_type
  private_auth_token { Faker::Code.isbn }
  api_root { Faker::Internet.url }
  auth_credential { Faker::Code.isbn }
  created_at 1.month.ago
  transient :updated_at
  after_save do |record, transients|
    if transients[:updated_at]
      record.update_columns(updated_at: transients[:updated_at])
      record.save!
    end
  end
end

Fabricator(:local_node, class_name: :node) do |f|
  f.namespace { Rails.configuration.local_namespace }
  name { Faker::Company.name }
  ssh_pubkey { Faker::Internet.password(20) }
  storage_region
  storage_type
  api_root { Faker::Internet.url }
  auth_credential { Faker::Code.isbn }
  private_auth_token { |attrs| "#{attrs[:auth_credential]}" }
  created_at 1.month.ago
  updated_at 1.month.ago
end