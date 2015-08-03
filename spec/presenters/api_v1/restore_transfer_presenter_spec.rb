# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ApiV1::RestoreTransferPresenter do
  describe "sanity" do
    it "has a valid factory" do
      expect(Fabricate(:restore_transfer)).to be_valid
    end

    it "can be built" do
      restore = Fabricate(:restore_transfer)
      expect {
        presenter = ApiV1::RestoreTransferPresenter.new(restore)
        expect(presenter).to_not be_nil
      }.to_not raise_error
    end
  end

  describe "#to_hash" do
    before(:each) do
      restore = Fabricate(:restore_transfer)
      @presenter = ApiV1::RestoreTransferPresenter.new(restore)
    end

    before(:all) do
      @uuid_pattern = /\A[a-f0-9]{8}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{12}\Z/
    end

    it "returns a restore_id" do
      id = @presenter.to_hash[:restore_id]
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













