# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe BagMan::BagUnpackJob, type: :job do
  before(:each) do
    @request = Fabricate(:bag_man_request, status: :downloaded, fixity: "dafdsafsfa")
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

  subject { BagMan::BagUnpackJob.perform_now(@request, @bag_location) }

  [".tar"].each do |file_type|
    context "extension=#{file_type}" do
      before(:each) { allow(File).to receive(:extname).and_return(file_type) }

      [true,false].each do |is_a_directory|
        context "File.directory? == #{is_a_directory}" do
          before(:each) { allow(File).to receive(:directory?).and_return(is_a_directory) }

          %w(BagValidateJob BagFixityJob).each do |spawned_job|
            let(:spawned_job_class) { "BagMan::#{spawned_job}".constantize }
            it "enqueues a #{spawned_job}" do
              expect {subject}.to enqueue_a(spawned_job_class)
            end

            it "passes the request to the #{spawned_job}" do
              expect(spawned_job_class).to receive(:perform_later).with(@request, anything)
              subject
            end

            it "passes the bag_location to the #{spawned_job}" do
              expect(spawned_job_class).to receive(:perform_later).with(anything(), is_a_directory ? @bag_location : @unpacked_location)
              subject
            end
          end

          it "sets request.status to unpacked" do
            subject
            expect(@request.reload.status).to eql("unpacked")
          end
        end
      end
    end
  end



end
