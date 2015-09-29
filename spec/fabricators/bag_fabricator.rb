# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:bag) do
  uuid { SecureRandom.uuid }
  local_id { Faker::Bitcoin.address }
  size { Faker::Number.number(12) }
  version 1
  version_family do |attributes|
    Fabricate(:version_family, uuid: attributes[:uuid])
  end
  ingest_node { Fabricate(:node) }
  admin_node { Fabricate(:node) }
  member { Fabricate(:member) }
  created_at 1.second.ago
  updated_at 1.second.ago
end
