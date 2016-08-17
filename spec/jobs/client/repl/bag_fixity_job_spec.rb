# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Client::Repl::BagFixityJob, type: :job do
  before(:each) do
    @request = Fabricate(:bag_man_request, last_step_completed: :validated)
    allow(@request).to receive(:set_fixityd!)
    @bag_location = "/tmp/some/fake/location"
    @fixity = "fafasdfsdfasdgdsasdfasdfasdf"
    bag = double(:serialized_bag)
    allow(bag).to receive(:fixity).with(any_args).and_return(@fixity)
    allow(DPN::Bagit::Bag).to receive(:new).and_return(bag)
  end

  subject { Client::Repl::BagFixityJob.perform_now(@request, @bag_location) }

  after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  it "creates a serialized bag from the bag_location" do
    subject
    expect(DPN::Bagit::Bag).to have_received(:new).with(@bag_location)
  end

  it "does not enqueue a job" do
    expect {subject}.to_not enqueue_a(anything)
  end


  it "calls set_fixityd! with the fixity" do
    subject()
    expect(@request).to have_received(:set_fixityd!).with(@fixity)
  end

end
