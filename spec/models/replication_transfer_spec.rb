# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ReplicationTransfer, type: :model do
  it "has a valid factory" do
    expect(Fabricate(:replication_transfer)).to be_valid
  end

  it "has a factory that honors updated_at" do
    time = 1.year.ago
    record = Fabricate(:replication_transfer, updated_at: 1.year.ago)
    expect(record.updated_at.change(usec: 0)).to eql time.change(usec: 0)
  end

  describe "::find_fields" do
    it "returns its find fields" do
      expect(ReplicationTransfer.find_fields).to eql(Set.new([:replication_id]))
    end
  end

  it "allows you to replicate to yourself" do
    node = Fabricate(:node)
    bag = Fabricate(:data_bag, admin_node: node)
    expect(Fabricate(:replication_transfer, bag: bag, from_node: node, to_node: node)).to be_valid
  end


  context "we are the to_node" do
    it "creates a bag_man_request and calls begin!" do
      bmr = Fabricate(:bag_man_request)
      expect(bmr).to receive(:begin!)
      expect(BagManRequest).to receive(:create!).and_return(bmr)
      r = Fabricate(:replication_transfer, to_node: Fabricate(:local_node))
      expect(r.bag_man_request).to be_valid
    end

    it "cancels bag_man_request when cancelled" do
      # ReplicationTransfer#cancel! calls BagManRequest#cancel! and then
      # BagManRequest#cancel! calls back to ReplicationTransfer#cancel! so
      # there should be 2 calls to ReplicationTransfer#cancel!
      # There is no infinite loop because ReplicationTransfer#cancelled
      # is the break point and it is set before calling BagManRequest#cancel!
      r = Fabricate(:replication_transfer, to_node: Fabricate(:local_node))
      expect(r.bag_man_request.cancelled).to be false
      expect(r.bag_man_request).to receive(:cancel!).and_call_original
      expect(r).to receive(:cancel!).twice.and_call_original
      r.cancel!('other', 'detail')
    end
  end


  [
    :replication_id,
    :bag,
    :from_node,
    :to_node,
    :protocol,
    :link,
    :fixity_alg,
    :store_requested,
    :stored,
    :cancelled
  ].each do |field|
    it "is invalid without a #{field}" do
      expect(Fabricate.build(:replication_transfer, field => nil)).to_not be_valid
    end
  end

  [
    :replication_id,
    :bag,
    :from_node,
    :to_node,
    :protocol,
    :link,
    :fixity_alg,
    :fixity_nonce
  ].each do |field|
    it "cannot change #{field}" do
      old = Fabricate(:replication_transfer)
      new = Fabricate(:replication_transfer)
      expect(old.update(field => new.public_send(field))).to be false
    end
  end

  [
    :fixity_nonce,
    :fixity_value,
    :cancel_reason,
    :cancel_reason_detail
  ].each do |field|
    it "#{field} is optional" do
      expect(Fabricate(:replication_transfer, field => nil)).to be_valid
    end
  end


  describe "#created_at" do
    it "is read-only" do
      time = 2.hours.ago.change(usec: 0)
      record = Fabricate(:replication_transfer, created_at: time)
      record.update(created_at: Time.now)
      expect(record.reload.created_at).to eql(time)
    end
  end


  describe "replication_id" do
    it "must be a uuid" do
      expect(Fabricate.build(:replication_transfer, replication_id: SecureRandom.uuid)).to be_valid
      expect(Fabricate.build(:replication_transfer, replication_id: "23452333")).to_not be_valid
    end
  end


  describe "store_requested" do
    it "cannot true->false" do
      expect(Fabricate(:replication_transfer, store_requested: true)
        .update(store_requested: false)).to be false
    end
    it "can false->true" do
      expect(Fabricate(:replication_transfer, store_requested: false)
        .update(store_requested: true)).to be true
    end
  end


  describe "stored" do
    it "cannot true->false" do
      expect(Fabricate(:replication_transfer, stored: true)
        .update(stored: false)).to be false
    end
    it "can false->true" do
      expect(Fabricate(:replication_transfer, stored: false)
        .update(stored: true)).to be true
    end
    it "cannot change a stored record" do
      expect(Fabricate(:replication_transfer, stored: true)
        .update(fixity_value: "1923719230128301805810285012850125")).to be false
    end
    it "cannot cancel a stored record" do
      expect {
        Fabricate(:replication_transfer, stored: true).cancel!('other', 'detail')
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end


  describe "#cancel!" do
    let(:cancel_reason) { 'other' }
    let(:cancel_reason_detail) { 'test' }
    let(:transfer) { Fabricate(:replication_transfer, cancelled: false) }

    before do
      expect(transfer.cancelled).to be false
      transfer.cancel!(cancel_reason, cancel_reason_detail)
      transfer.reload
    end

    context "when already cancelled" do
      it "another call to #cancel! does nothing" do
        expect(transfer.cancelled).to be true
        expect(transfer).to receive(:cancelled).and_call_original
        previous_time = transfer.updated_at
        expect { transfer.cancel!('reason', 'detail') }.to_not raise_error
        transfer.reload
        expect(transfer.updated_at).to eq previous_time
        expect(transfer.cancel_reason).to eq cancel_reason
        expect(transfer.cancel_reason_detail).to eq cancel_reason_detail
      end
    end
    it "sets cancelled" do
      expect(transfer.cancelled).to be true
    end
    it "sets cancel_reason" do
      expect(transfer.cancel_reason).to eq cancel_reason
    end
    it "sets cancel_reason_detail" do
      expect(transfer.cancel_reason_detail).to eq cancel_reason_detail
    end
  end


  describe "cancelled" do
    it "cannot true->false" do
      expect(Fabricate(:replication_transfer, cancelled: true)
        .update(cancelled: false)).to be false
    end
    it "can false->true" do
      expect(Fabricate(:replication_transfer, cancelled: false)
        .update(cancelled: true)).to be true
    end
  end


  describe "cancel_reason" do
    it "is read-only" do
      expect(Fabricate(:replication_transfer, cancelled: true, cancel_reason: 'other')
        .update(cancel_reason: 'changed')).to be false
    end
  end


  describe "cancel_reason_detail" do
    it "is read-only" do
      expect(Fabricate(:replication_transfer, cancelled: true, cancel_reason: 'other', cancel_reason_detail: 'fun' )
        .update(cancel_reason_detail: 'more_fun')).to be false
    end
  end

  it_behaves_like "it has temporal scopes for", :updated_at

  describe "scope with_bag" do
    let!(:transfer) { Fabricate(:replication_transfer) }
    let!(:other_transfer) { Fabricate(:replication_transfer) }
    it "includes matching only" do
      expect(ReplicationTransfer.with_bag(transfer.bag)).to match_array [transfer]
    end
    it "does not filter given a new record" do
      expect(ReplicationTransfer.with_bag(Fabricate.build(:bag)))
        .to contain_exactly(transfer, other_transfer)
    end
  end
  describe "scope with_from_node" do
    let!(:transfer) { Fabricate(:replication_transfer) }
    let!(:other_transfer) { Fabricate(:replication_transfer) }
    it "includes matching only" do
      expect(ReplicationTransfer.with_from_node(transfer.from_node)).to match_array [transfer]
    end
    it "does not filter given a new record" do
      expect(ReplicationTransfer.with_from_node(Fabricate.build(:node)))
        .to contain_exactly(transfer, other_transfer)
    end
  end
  describe "scope with_to_node" do
    let!(:transfer) { Fabricate(:replication_transfer) }
    let!(:other_transfer) { Fabricate(:replication_transfer) }
    it "includes matching only" do
      expect(ReplicationTransfer.with_to_node(transfer.to_node)).to match_array [transfer]
    end
    it "does not filter given a new record" do
      expect(ReplicationTransfer.with_to_node(Fabricate.build(:node)))
        .to contain_exactly(transfer, other_transfer)
    end
  end
  describe "scope with_store_requested" do
    it_behaves_like "a boolean filter" do
      let(:scope_name) { :with_store_requested }
      let(:field_name) { :store_requested }
    end
  end
  describe "scope with_stored" do
    it_behaves_like "a boolean filter" do
      let(:scope_name) { :with_stored }
      let(:field_name) { :stored }
    end
  end
  describe "scope with_cancelled" do
    it_behaves_like "a boolean filter" do
      let(:scope_name) { :with_cancelled }
      let(:field_name) { :cancelled }
    end
  end

end
