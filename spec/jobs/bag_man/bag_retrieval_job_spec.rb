# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe BagMan::BagRetrievalJob, type: :job do
  before(:each) do
    @request = Fabricate(:bag_man_request, last_step_completed: :created)
    allow(@request).to receive(:"set_retrieved!")
    @staging_dir = "/tmp/some/staging/area"
    @expected_dest_dir = File.join @staging_dir, @request.id.to_s
    @expected_dest_file = File.join @expected_dest_dir, File.basename(@request.source_location)
  end

  subject {
    BagMan::BagRetrievalJob.perform_now(@request, @staging_dir)
  }

  after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  context "stubbed Rsync to return success" do
    before(:each) do
      allow(Rsync).to receive(:run) { Rsync::Result.new(0, 0)}
    end

    it "runs rsync to copy from source to dest" do
      subject()
      expect(Rsync).to have_received(:run).once.with(@request.source_location, @expected_dest_dir, anything)
    end

    it "does not enqueue a job" do
      expect {subject}.to_not enqueue_a(anything)
    end

    it "calls request.set_retrieved!" do
      subject()
      expect(@request).to have_received(:set_retrieved!).with(no_args)
    end
  end


end
