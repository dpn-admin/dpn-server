# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe BagMan::BagFixityJob, type: :job do
  before(:each) do
    @request = Fabricate(:bag_man_request, status: :downloaded)
    @bag_location = "/tmp/some/fake/location"
    @fixity = "fafasdfsdfasdgdsasdfasdfasdf"
    serialized_bag = double(:serialized_bag)
    allow(serialized_bag).to receive(:fixity).with(any_args).and_return(@fixity)
    allow(DPN::Bagit::SerializedBag).to receive(:new).and_return(serialized_bag)
  end

  subject { BagMan::BagFixityJob.perform_now(@request, @bag_location) }

  after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  it "creates a serialized bag from the bag_location" do
    subject
    expect(DPN::Bagit::SerializedBag).to have_received(:new).with(@bag_location)
  end

  it "does not enqueue a job" do
    expect {subject}.to_not enqueue_a(anything)
  end
  
  it "sets the fixity" do
    subject
    expect(@request.reload.fixity).to eql(@fixity)
  end

  it "does not change the status" do
    subject
    expect(@request.reload.status).to eql("downloaded")
  end

end
