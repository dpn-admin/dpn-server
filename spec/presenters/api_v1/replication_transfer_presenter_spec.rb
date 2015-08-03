# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ApiV1::ReplicationTransferPresenter do
  describe "sanity" do
    it "has a valid factory" do
      expect(Fabricate(:replication_transfer)).to be_valid
    end

    it "can be built" do
      repl = Fabricate(:replication_transfer)
      expect {
        presenter = ApiV1::ReplicationTransferPresenter.new(repl)
        expect(presenter).to_not be_nil
      }.to_not raise_error
    end
  end

  describe "#to_hash" do
    before(:each) do
      repl = Fabricate(:replication_transfer)
      @presenter = ApiV1::ReplicationTransferPresenter.new(repl)
    end

    before(:all) do
      @uuid_pattern = /\A[a-f0-9]{8}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{12}\Z/
    end

    it "returns a replication_id" do
      id = @presenter.to_hash[:replication_id]
      expect(id).to be_a(String)
      expect(id).to_not eql("")
    end

    it "returns a from_node" do
      node = @presenter.to_hash[:from_node]
      expect(node).to be_a(String)
      expect(node).to_not eql("")
    end

    it "returns a to_node" do
      node = @presenter.to_hash[:to_node]
      expect(node).to be_a(String)
      expect(node).to_not eql("")
    end

    it "returns a uuid" do
      expect(@presenter.to_hash[:uuid]).to match(@uuid_pattern)
    end

    it "returns a fixity_algorithm" do
      fixity_algorithm = @presenter.to_hash[:fixity_algorithm]
      expect(fixity_algorithm).to be_a(String)
      expect(fixity_algorithm).to_not eql("")
    end

    it "returns a fixity_nonce" do
      fixity_nonce = @presenter.to_hash[:fixity_nonce]
      if fixity_nonce != nil
        expect(fixity_nonce).to be_a(String)
        expect(fixity_nonce).to_not eql("")
      end
    end

    it "returns a fixity_value" do
      fixity_value = @presenter.to_hash[:fixity_value]
      if fixity_value != nil
        expect(fixity_value).to be_a(String)
        expect(fixity_value).to_not eql("")
      end
    end

    it "returns a fixity_accept" do
      fixity_accept = @presenter.to_hash[:fixity_accept]
      expect([true, false, nil]).to include(fixity_accept)
    end

    it "returns a bag_valid" do
      bag_valid = @presenter.to_hash[:bag_valid]
      expect([true, false, nil]).to include(bag_valid)
    end

    it "returns a protocol" do
      protocol = @presenter.to_hash[:protocol]
      expect(protocol).to be_a(String)
      expect(protocol).to_not eql("")
    end

    it "returns a link" do
      link = @presenter.to_hash[:link]
      expect(link).to be_a(String)
      expect(link).to_not eql("")
    end

    it "returns a status" do
      status = @presenter.to_hash[:status]
      expect(status).to be_a(String)
      expect(status).to_not eql("")
    end

    describe "timestamps" do
      it "returns created_at" do
        created_at = @presenter.to_hash[:created_at]
        through_datetime = DateTime.strptime(created_at, Time::DATE_FORMATS[:dpn]).strftime(Time::DATE_FORMATS[:dpn])
        expect(created_at).to eql(through_datetime)
      end

      it "returns updated_at" do
        updated_at = @presenter.to_hash[:updated_at]
        through_datetime = DateTime.strptime(updated_at, Time::DATE_FORMATS[:dpn]).strftime(Time::DATE_FORMATS[:dpn])
        expect(updated_at).to eql(through_datetime)
      end

      it "returns times in UTC" do
        time = Time.current.utc
        repl = Fabricate(:replication_transfer, created_at: time, updated_at: time)
        hash = ApiV1::ReplicationTransferPresenter.new(repl).to_hash
        expect(hash[:created_at]).to eql(time.to_formatted_s(:dpn))
        expect(hash[:updated_at]).to eql(time.to_formatted_s(:dpn))
      end
    end


  end
end













