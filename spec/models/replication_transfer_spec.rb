# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ReplicationTransfer do
  it "has a valid factory" do
    expect(Fabricate(:replication_transfer)).to be_valid
  end


  context "update" do
    it "requires a replication_id" do
      record = Fabricate(:replication_transfer)
      record.replication_id = nil
      expect(record).to_not be_valid
    end
  end

  context "create" do
    context "from_node != local_node" do
      it "requires a replication_id" do
        expect {
          Fabricate(:replication_transfer, replication_id: nil)
        }.to raise_error ActiveRecord::RecordInvalid
      end
      it "does not alter the replication_id" do
        id = SecureRandom.uuid
        record = Fabricate(:replication_transfer, replication_id: id)
        expect(record.replication_id).to eql(id)
      end
    end

    context "from_node==local_node" do
      let(:record) {
        Fabricate(:replication_transfer,
                  replication_id: nil,
                  from_node: Fabricate(:local_node, namespace: Rails.configuration.local_namespace))
      }

      it "does not require a replication_id" do
        expect { record }.to_not raise_error
      end
      it "sets the replication_id to a uuid" do
        expect(record.replication_id).to match /\A[a-f0-9]{8}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{12}\Z/
      end

    end
  end
  
end

