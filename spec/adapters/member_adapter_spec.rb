# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe MemberAdapter do
  uuid = SecureRandom.uuid
  name = Faker::Company.name
  email = Faker::Internet.email
  created_at = "2015-02-25T15:27:40Z"
  updated_at = "2015-02-25T15:27:40Z"
  before(:each) do
    @model = Fabricate(:member,
      member_id: uuid,
      name: name,
      email: email,
      created_at: time_from_string(created_at),
      updated_at: time_from_string(updated_at)
    )
    @public_hash = {
      member_id: uuid,
      name: name,
      email: email,
      created_at: created_at,
      updated_at: updated_at
    }
    @model_hash = {
      member_id: uuid,
      name: name,
      email: email,
      created_at: time_from_string(created_at),
      updated_at: time_from_string(updated_at)
    }
  end

  let(:model) { @model }
  let(:public_hash) { @public_hash }
  let(:model_hash) { @model_hash }

  it_behaves_like "an adapter"
end