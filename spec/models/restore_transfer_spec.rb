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
  
  it "allows you to restore to yourself" do
    node = Fabricate(:node)
    bag = Fabricate(:data_bag, admin_node: node)
    bag.replicating_nodes << node
    expect(Fabricate(:restore_transfer, bag: bag, from_node: node, to_node: node)).to be_valid
  end

  [
    :restore_id,
    :bag,
    :from_node,
    :to_node,
    :protocol,
    :accepted,
    :finished,
    :cancelled
  ].each do |field|
    it "is invalid without a #{field}" do
      expect(Fabricate.build(:restore_transfer, field => nil)).to_not be_valid
    end
  end

  [
    :restore_id,
    :bag,
    :from_node,
    :to_node,
    :protocol
  ].each do |field|
    it "cannot change #{field}" do
      old = Fabricate(:restore_transfer)
      new = Fabricate(:restore_transfer)
      expect(old.update(field => new.public_send(field))).to be false
    end
  end

  [
    :link,
    :cancel_reason,
    :cancel_reason_detail
  ].each do |field|
    it "#{field} is optional" do
      expect(Fabricate.build(:restore_transfer, field => nil)).to be_valid
    end
  end

  describe "#created_at" do
    it "is read-only" do
      time = 2.hours.ago.change(usec: 0)
      record = Fabricate(:restore_transfer, created_at: time)
      record.update(created_at: Time.now)
      expect(record.reload.created_at).to eql(time)
    end
  end

  describe "restore_id" do
    it "must be a uuid" do
      expect(Fabricate.build(:restore_transfer, restore_id: SecureRandom.uuid)).to be_valid
      expect(Fabricate.build(:restore_transfer, restore_id: "23452333")).to_not be_valid
    end
  end

  describe "accepted" do
    it "cannot true->false" do
      expect(Fabricate(:restore_transfer, accepted: true)
        .update(accepted: false)).to be false
    end
    it "can false->true" do
      expect(Fabricate(:restore_transfer, accepted: false)
        .update(accepted: true)).to be true
    end
  end

  describe "finished" do
    it "cannot true->false" do
      expect(Fabricate(:restore_transfer, finished: true)
        .update(finished: false)).to be false
    end
    it "can false->true" do
      expect(Fabricate(:restore_transfer, finished: false)
        .update(finished: true)).to be true
    end
    it "cannot change a finished record" do
      expect(Fabricate(:restore_transfer, finished: true)
        .update(link: "some_link")).to be false
    end
    it "cannot cancel a finished record" do
      expect {
        Fabricate(:restore_transfer, finished: true).cancel!('other', 'detail')
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe "link" do
    it "can nil->value" do
      record = Fabricate(:restore_transfer, link: nil)
      expect(record.update(link: "some_link")).to be true
    end
    it "cannot value->other_value" do
      record = Fabricate(:restore_transfer, link: "some_link")
      expect(record.update(link: "some_other_link")).to be false
    end
  end

  describe "#cancel!" do
    let(:transfer) { Fabricate(:restore_transfer) }
    before(:each) { transfer.cancel!('other', 'test') }
    it "is idempotent" do
      expect {
        transfer.cancel!('other', 'test')
      }.to_not raise_error
    end
    it "sets cancelled" do
      expect(transfer.reload.cancelled).to be true
    end
    it "sets cancel_reason" do
      expect(transfer.cancel_reason).to eql('other')
    end
    it "sets cancel_reason_detail" do
      expect(transfer.cancel_reason_detail).to eql('test')
    end
  end

  describe "cancelled" do
    it "cannot true->false" do
      expect(Fabricate(:restore_transfer, cancelled: true)
        .update(cancelled: false)).to be false
    end
    it "can false->true" do
      expect(Fabricate(:restore_transfer, cancelled: false)
        .update(cancelled: true)).to be true
    end
  end

  describe "cancel_reason" do
    it "is read-only" do
      expect(Fabricate(:restore_transfer, cancelled: true, cancel_reason: 'other')
        .update(cancel_reason: 'changed')).to be false
    end
  end

  describe "cancel_reason_detail" do
    it "is read-only" do
      expect(Fabricate(:restore_transfer, cancelled: true, cancel_reason: 'other', cancel_reason_detail: 'fun' )
        .update(cancel_reason_detail: 'more_fun')).to be false
    end
  end

  it_behaves_like "it has temporal scopes for", :updated_at

  describe "scope with_bag" do
    let!(:transfer) { Fabricate(:restore_transfer) }
    let!(:other_transfer) { Fabricate(:restore_transfer) }
    it "includes matching only" do
      expect(RestoreTransfer.with_bag(transfer.bag)).to match_array [transfer]
    end
    it "does not filter given a new record" do
      expect(RestoreTransfer.with_bag(Fabricate.build(:bag)))
        .to contain_exactly(transfer, other_transfer)
    end
  end
  describe "scope with_from_node" do
    let!(:transfer) { Fabricate(:restore_transfer) }
    let!(:other_transfer) { Fabricate(:restore_transfer) }
    it "includes matching only" do
      expect(RestoreTransfer.with_from_node(transfer.from_node)).to match_array [transfer]
    end
    it "does not filter given a new record" do
      expect(RestoreTransfer.with_from_node(Fabricate.build(:node)))
        .to contain_exactly(transfer, other_transfer)
    end
  end
  describe "scope with_to_node" do
    let!(:transfer) { Fabricate(:restore_transfer) }
    let!(:other_transfer) { Fabricate(:restore_transfer) }
    it "includes matching only" do
      expect(RestoreTransfer.with_to_node(transfer.to_node)).to match_array [transfer]
    end
    it "does not filter given a new record" do
      expect(RestoreTransfer.with_to_node(Fabricate.build(:node)))
        .to contain_exactly(transfer, other_transfer)
    end
  end
  describe "scope with_accepted" do
    it_behaves_like "a boolean filter" do
      let(:scope_name) { :with_accepted }
      let(:field_name) { :accepted }
    end
  end
  describe "scope with_finished" do
    it_behaves_like "a boolean filter" do
      let(:scope_name) { :with_finished }
      let(:field_name) { :finished }
    end
  end
  describe "scope with_cancelled" do
    it_behaves_like "a boolean filter" do
      let(:scope_name) { :with_cancelled }
      let(:field_name) { :cancelled }
    end
  end

end