# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:bag_without_digests, class_name: :bag) do
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
  type "DataBag"
  created_at 1.month.ago
  updated_at 1.month.ago
  transient :updated_at
  after_save do |record, transients|
    if transients[:updated_at]
      record.updated_at = transients[:updated_at]
      record.save!
    end
  end
end


Fabricator(:bag, from: :bag_without_digests) do
  after_create { |bag| bag.message_digests = Fabricate.times(2, :message_digest, bag: bag) }
end
