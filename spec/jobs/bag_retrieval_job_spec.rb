require 'rails_helper'

describe BagRetrievalJob, type: :job do
  before(:each) do
    @request = Fabricate(:bag_manager_request)
    @staging_dir = "/tmp/some/staging/area"
    @expected_dest_dir = File.join @staging_dir, @request.id.to_s
    @expected_dest_file = File.join @expected_dest_dir, File.basename(@request.source_location)
  end

  after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  context "stubbed Rsync to return success" do
    before(:each) do
      allow(Rsync).to receive(:run) { Rsync::Result.new(0, 0)}
    end

    it "runs rsync to copy from source to dest" do
      expect(Rsync).to receive(:run).once.with(@request.source_location, @expected_dest_dir, anything)
      BagRetrievalJob.perform_now(@request, @staging_dir)
    end

    it "enqueues a BagUnpack job" do
      expect {
        BagRetrievalJob.perform_now(@request, @staging_dir)
      }.to enqueue_a(BagUnpackJob)
    end

    it "passes the request to a BagUnpack job" do
      expect(BagUnpackJob).to receive(:perform_later).with(@request, anything)
      BagRetrievalJob.perform_now(@request, @staging_dir)
    end

    it "passes the destination to a BagUnpack job" do
      expect(BagUnpackJob).to receive(:perform_later).with(anything(), @expected_dest_file)
      BagRetrievalJob.perform_now(@request, @staging_dir)
    end

    it "sets request.status to :downloaded" do
      BagRetrievalJob.perform_now(@request, @staging_dir)
      expect(@request.reload.status).to eql(:downloaded.to_s)
    end

  end




end
