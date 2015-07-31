require 'rails_helper'

describe BagMan::BagRetrievalJob, type: :job do
  before(:each) do
    @request = Fabricate(:bag_man_request, status: :requested, cancelled: false)
    @staging_dir = "/tmp/some/staging/area"
    @expected_dest_dir = File.join @staging_dir, @request.id.to_s
    @expected_dest_file = File.join @expected_dest_dir, File.basename(@request.source_location)
  end

  subject { BagRetrievalJob.perform_now(@request, @staging_dir) }

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

    it "does not enqueue a BagUnpackJob" do
      expect {subject}.to_not enqueue_a(BagUnpackJob)
    end

    it "enqueues a BagFixityJob" do
      expect {subject}.to enqueue_a(BagFixityJob)
    end

    it "passes the request to a BagFixityjob" do
      expect(BagFixityJob).to receive(:perform_later).with(@request, anything)
      subject()
    end

    it "passes the destination to a BagFixityJob" do
      expect(BagFixityJob).to receive(:perform_later).with(anything(), @expected_dest_file)
      subject
    end

    it "sets request.status to :downloaded" do
      subject()
      expect(@request.reload.status).to eql(:downloaded.to_s)
    end
  end


end
