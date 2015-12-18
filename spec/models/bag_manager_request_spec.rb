# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe BagManRequest, type: :model do
  before(:each) { Fabricate(:local_node, namespace: Rails.configuration.local_namespace)}
  it "has a valid factory" do
    expect(Fabricate(:bag_man_request)).to be_valid
  end

  it "is invalid without a source_location" do
    expect {
      Fabricate(:bag_man_request, source_location: nil)
    }.to raise_error(ActiveRecord::ActiveRecordError)
  end

  it "returns the source location" do
    request = Fabricate(:bag_man_request)
    staging_dir = "/herpderp"
    expected = File.join staging_dir, request.id.to_s, File.basename(request.source_location)
    expect(request.staging_location(staging_dir)).to eql(expected)
  end

  describe "#update" do
    let!(:bag_man_request) { Fabricate(:bag_man_request, cancelled: false) }

    context "when cancelled" do
      it "cancels the replication" do
        bag_man_request.cancelled = true
        bag_man_request.save!
        expect(bag_man_request.replication_transfer.reload.status).to eql("cancelled")
      end
    end

    context "when rejected" do
      it "sets the replication to rejected" do
        bag_man_request.status = :rejected
        bag_man_request.save!
        expect(bag_man_request.replication_transfer.reload.status).to eql("rejected")
      end
    end

    context "when unpacked" do
      context "with fixity and validity" do
        context "with validity==true" do
        end
        context "with validity==false" do
          it "sets the replication to cancelled" do
            bag_man_request.fixity = "some_fixity"
            bag_man_request.validity = false
            bag_man_request.status = :unpacked
            bag_man_request.save!
            expect(bag_man_request.replication_transfer.reload.status).to eql("cancelled")
          end
        end
      end

      context "with fixity only" do
        it "does not alter the replication status" do
          bag_man_request.fixity = "some_fixity"
          bag_man_request.validity = nil
          bag_man_request.status = :unpacked
          bag_man_request.save!
          expect(bag_man_request.replication_transfer).to eql(bag_man_request.replication_transfer.reload)
        end
      end
      context "with validity only" do
        it "does not alter the replication status" do
          bag_man_request.fixity = nil
          bag_man_request.validity = true
          bag_man_request.status = :unpacked
          bag_man_request.save!
          expect(bag_man_request.replication_transfer).to eql(bag_man_request.replication_transfer.reload)
        end
      end
    end
    it "sets the replication.fixity_value to the bag_mgr fixity" do
      bag_man_request.fixity = "some_fixity"
      bag_man_request.save!
      expect(bag_man_request.replication_transfer.reload.fixity_value).to eql("some_fixity")
    end
    it "sets the replication.bag_valid to the bag_mgr validity" do
      bag_man_request.validity = true
      bag_man_request.save!
      expect(bag_man_request.replication_transfer.reload.bag_valid).to be true
    end

  end



  # Todo: put a lot more validations on the states that can
  # be held here.
end
