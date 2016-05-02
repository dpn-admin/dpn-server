# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Digest do
  it "has a valid factory" do
    expect(Fabricate(:message_digest)).to be_valid
  end

  [:bag, :node, :fixity_alg, :value].each do |field|
    it "is invalid without a #{field}" do
      expect(Fabricate.build(:message_digest, field => nil)).to_not be_valid
    end

    it "disallows changing #{field}" do
      record = Fabricate(:message_digest)
      other_record = Fabricate(:message_digest)
      expect(record.update(field => other_record.send(field))).to be false
    end
  end

  it "is invalid without created_at" do
    expect(Fabricate.build(:message_digest, created_at: nil)).to_not be_valid
  end

  it "disallows changing created_at" do
    record = Fabricate(:message_digest)
    expect(record.update(created_at: 2.seconds.from_now)).to be false
  end

  it "is unique by fixity_alg-bag pairs" do
    r = Fabricate(:message_digest)
    expect(Fabricate.build(:message_digest, fixity_alg: r.fixity_alg, bag: r.bag )).to_not be_valid
  end

end