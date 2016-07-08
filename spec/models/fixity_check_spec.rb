# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe FixityCheck do
  it "has a valid factory" do
    expect(Fabricate(:fixity_check)).to be_valid
  end

  [:fixity_check_id, :bag, :node, :success, :fixity_at, :created_at].each do |field|
    it "is invalid without a #{field}" do
      expect(Fabricate.build(:fixity_check, field => nil)).to_not be_valid
    end

    it "disallows changing #{field}" do
      record = Fabricate(:fixity_check, 
        success: false, 
        fixity_at: 3.minutes.ago, 
        created_at: 1.minute.ago)
      other_record = Fabricate(:fixity_check, 
        success: true,
        fixity_at: 3.seconds.ago,
        created_at: 1.second.ago)
      expect(record.update(field => other_record.send(field))).to be false
    end
  end
  
  describe "fixity_check_id" do
    it "is unique" do
      r = Fabricate(:fixity_check)
      expect(Fabricate.build(:fixity_check, fixity_check_id: r.fixity_check_id)).to_not be_valid
    end
    it "is a uuidv4" do
      expect(Fabricate.build(:fixity_check, fixity_check_id: SecureRandom.uuid)).to be_valid
      expect(Fabricate.build(:fixity_check, fixity_check_id: Faker::Lorem.word)).to_not be_valid
    end
  end

  it "requires fixity_at <= created_at" do
    now = Time.now
    expect(Fabricate.build(:fixity_check, fixity_at: 2.minutes.ago, created_at: 1.minute.ago)).to be_valid
    expect(Fabricate.build(:fixity_check, fixity_at: now, created_at: now)).to be_valid
    expect(Fabricate.build(:fixity_check, fixity_at: 1.minute.ago, created_at: 2.minute.ago)).to_not be_valid
  end
  
end