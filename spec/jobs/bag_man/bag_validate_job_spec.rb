# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe BagMan::BagValidateJob, type: :job do
  before(:each) do
    @request = Fabricate(:bag_man_request, last_step_completed: :unpacked )
    allow(@request).to receive(:set_validated!)
    allow(@request).to receive(:cancel!)
    @bag_location = "/tmp/some/fake/location"
  end

  subject { BagMan::BagValidateJob.perform_now(@request, @bag_location) }

  [true,false].each do |validity|
    before(:each) do
      bag = double(:bag)
      allow(bag).to receive(:valid?).and_return(validity)
      allow(DPN::Bagit::Bag).to receive(:new).and_return(bag)
    end

    it "does not enqueue a job" do
      expect {subject}.to_not enqueue_a(anything)
    end

    it "calls request.set_validated! with validity" do
      subject()
      expect(@request).to have_received(:set_validated!)
    end

  end
end
