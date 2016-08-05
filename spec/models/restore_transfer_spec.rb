# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe RestoreTransfer do
  it "has a valid factory" do
    expect(Fabricate(:restore_transfer)).to be_valid
  end

  it "has a factory that honors updated_at" do
    time = 1.year.ago
    record = Fabricate(:restore_transfer, updated_at: 1.year.ago)
    expect(record.updated_at.change(usec: 0)).to eql time.change(usec: 0)
  end

  describe "::find_fields" do
    it "returns its find fields" do
      expect(RestoreTransfer.find_fields).to eql(Set.new([:restore_id]))
    end
  end
  
  it "updates updated_at" do
    instance = Fabricate(:restore_transfer)
    old_time = instance.updated_at
    instance.status = :cancelled
    instance.save
    expect(instance.updated_at).to be > old_time
  end

  context "update" do
    it "requires a restore_id" do
      record = Fabricate(:restore_transfer)
      record.restore_id = nil
      expect(record).to_not be_valid
    end
  end

  context "create" do
    context "from_node != local_node" do
      it "requires a restore_id" do
        expect {
          Fabricate(:restore_transfer, restore_id: nil)
        }.to raise_error ActiveRecord::RecordInvalid
      end
      it "does not alter the restore_id" do
        id = SecureRandom.uuid
        record = Fabricate(:restore_transfer, restore_id: id)
        expect(record.restore_id).to eql(id)
      end
    end

    context "to_node==local_node" do
      let(:record) {
        Fabricate(:restore_transfer,
          restore_id: nil,
          to_node: Fabricate(:local_node, namespace: Rails.configuration.local_namespace))
      }

      it "does not require a restore_id" do
        expect { record }.to_not raise_error
      end
      it "sets the restore_id to a uuid" do
        expect(record.restore_id).to match /\A[a-f0-9]{8}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{12}\Z/
      end

    end
  end
end