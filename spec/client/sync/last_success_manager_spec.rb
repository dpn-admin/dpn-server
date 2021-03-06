# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Client::Sync::LastSuccessManager do


  context "when no RunTime exists" do
    it "creates the RunTime if it does not exist" do
      name = Faker::Internet.password(10)
      Client::Sync::LastSuccessManager.new(name).manage do
        # no op
      end
      expect(RunTime.find_by_name(name)).to be_valid
    end
  end


  context "when a RunTime exists" do
    before(:each) do
      @old_time = 10.years.ago.change(usec: 0)
      @run_time = Fabricate(:run_time, name: "test", last_success: @old_time)
    end

    let(:last_success_manager) { Client::Sync::LastSuccessManager.new("test") }

    it "updates when no exceptions encountered" do
      last_success_manager.manage { true }
      expect(@run_time.reload.last_success).to be > 5.seconds.ago
    end

    it "does not update when exception encountered" do
      begin
        last_success_manager.manage { raise RuntimeError }
      rescue RuntimeError
      end
      expect(@run_time.reload.last_success).to eql(@old_time)
    end
  end


end