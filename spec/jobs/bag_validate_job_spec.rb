require 'rails_helper'

describe BagValidateJob, type: :job do
  before(:each) do
    @request = Fabricate(:bag_manager_request, status: :unpacked, fixity: "dafdsafsfa")
    @bag_location = "/tmp/some/fake/location"
  end

  subject { BagValidateJob.perform_now(@request, @bag_location) }

  [true,false].each do |what_valid_returns|
    context "bag.valid? == #{what_valid_returns}" do
      before(:each) do
        bag = double(:bag)
        allow(bag).to receive(:valid?).and_return(what_valid_returns)
        allow(Bag).to receive(:new).and_return(bag)
      end

      it "sets the validity on the request" do
        subject
        expect(@request.reload.validity).to eql(what_valid_returns)
      end
    end
  end

end
