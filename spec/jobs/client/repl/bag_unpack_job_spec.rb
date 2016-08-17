# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe Client::Repl::BagUnpackJob, type: :job do
  before(:each) do
    @request = Fabricate(:bag_man_request, last_step_completed: :retrieved)
    allow(@request).to receive(:set_unpacked!)
    @bag_location = "/tmp/some/fake/location"

    @unpacked_location = "/tmp/some/fake/location/unpacked"
    bag = double(:bag)
    allow(bag).to receive(:location).and_return(@unpacked_location)

    serialized_bag = double(:serialized_bag)
    allow(serialized_bag).to receive(:"unserialize!").and_return(bag)

    allow(DPN::Bagit::SerializedBag).to receive(:new).and_return(serialized_bag)
  end

  after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  subject { Client::Repl::BagUnpackJob.perform_now(@request, @bag_location) }

  [".tar"].each do |file_type|
    context "extension=#{file_type}" do
      before(:each) { allow(File).to receive(:extname).and_return(file_type) }

      context "File.directory? == true" do
        before(:each) { allow(File).to receive(:directory?).and_return(true) }

        it "does not enqueue a job" do
          expect {subject}.to_not enqueue_a(anything)
        end

        it "calls request.set_unpacked! with the bag location" do
          subject()
          expect(@request).to have_received(:set_unpacked!).with(@bag_location)

        end
      end

      context "File.directory? == false" do
        before(:each) { allow(File).to receive(:directory?).and_return(false) }

        it "does not enqueue a job" do
          expect {subject}.to_not enqueue_a(anything)
        end

        it "calls request.set_unpacked! with the unpacked location" do
          subject()
          expect(@request).to have_received(:set_unpacked!).with(@unpacked_location)
        end
      end


    end
  end
end
