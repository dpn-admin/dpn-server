require 'rails_helper'

shared_examples "a BagUnpackJob" do
  it "enqueues a BagFixityJob"
  it "passes the request to BagFixityJob"
  it "passes the bag_location to BagFixityJob"
  it "enqueues a BagValidateJob"
  it "passes the request to BagValidateJob"
  it "passes the bag_location to BagValidateJob"

  it "sets request.status to :unpacked" do
    BagUnpackJob.perform_now(@request, @file_to_unpack)
    expect(@request.reload.status.to_sym).to eql(:unpacked)
  end
end

describe BagUnpackJob, type: :job do
  before(:each) do
    @request = Fabricate(:bag_manager_request, status: :downloaded)
    @bag_location = "/tmp/some/staging/area/#{@request.id}/#{File.basename @request.source_location}"
  end

  after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  context "mocked SerializedBag" do
    before(:each) do
      bag = double("bag")
      allow(bag).to receive(:location) { @bag_location }
      allow_any_instance_of(DPN::Bagit::SerializedBag).to receive(:unserialize!).and_return(bag)
    end

    context "is a directory" do
      before(:each) do
        allow(File).to receive(:directory?).and_return(true)
        @file_to_unpack = @bag_location
      end

      # it "does not unpack a directory" do
      #   expect_any_instance_of(DPN::Bagit::SerializedBag).to_not receive(:unserialize!)
      #   BagUnpackJob.perform_now(@request, @file_to_unpack)
      # end




    end

    context "is not a directory" do
      before(:each) do
        allow(File).to receive(:directory?).and_return(FalseClass)
        @file_to_unpack = @bag_location + ".tar"
      end

      context "Extension is .tar" do
        before(:each) do
          allow(File).to receive(:extname).and_return(".tar")
        end

        # it "unpacks the serialized bag"


      end

    end
  end
end
