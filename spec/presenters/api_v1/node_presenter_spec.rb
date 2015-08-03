# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ApiV1::NodePresenter do
  describe "sanity" do
    it "has a valid factory" do
      expect(Fabricate(:node)).to be_valid
    end

    it "can be built" do
      node = Fabricate(:node)
      expect {
        presenter = ApiV1::NodePresenter.new(node)
        expect(presenter).to_not be_nil
      }.to_not raise_error
    end
  end

  describe "#to_hash" do
    before(:each) do
      node = Fabricate(:node)
      @presenter = ApiV1::NodePresenter.new(node)
    end

    it "returns a name" do
      name = @presenter.to_hash[:name]
      expect(name).to be_a(String)
      expect(name).to_not eql("")
    end

    it "returns a namespace" do
      namespace = @presenter.to_hash[:namespace]
      expect(namespace).to be_a(String)
      expect(namespace).to_not eql("")
    end

    it "returns an api_root" do
      api_root = @presenter.to_hash[:api_root]
      if api_root != nil
        expect(api_root).to be_a(String)
        expect(api_root).to_not eql("")
      end
    end

    it "returns an ssh_pubkey" do
      ssh_pubkey = @presenter.to_hash[:ssh_pubkey]
      if ssh_pubkey != nil
        expect(ssh_pubkey).to be_a(String)
        expect(ssh_pubkey).to_not eql("")
      end
    end

    it "returns replicate_from" do
      replicate_from = @presenter.to_hash[:replicate_from]
      expect(replicate_from).to be_an(Array)
      replicate_from.each do |node|
        expect(node).to be_a(String)
        expect(node).to_not eql("")
      end
    end

    it "returns replicate_to" do
      replicate_to = @presenter.to_hash[:replicate_to]
      expect(replicate_to).to be_an(Array)
      replicate_to.each do |node|
        expect(node).to be_a(String)
        expect(node).to_not eql("")
      end
    end

    it "returns restore_from" do
      restore_from = @presenter.to_hash[:restore_from]
      expect(restore_from).to be_an(Array)
      restore_from.each do |node|
        expect(node).to be_a(String)
        expect(node).to_not eql("")
      end
    end

    it "returns restore_to" do
      restore_to = @presenter.to_hash[:restore_to]
      expect(restore_to).to be_an(Array)
      restore_to.each do |node|
        expect(node).to be_a(String)
        expect(node).to_not eql("")
      end
    end

    it "returns protocols" do
      protocols = @presenter.to_hash[:protocols]
      expect(protocols).to be_an(Array)
      protocols.each do |node|
        expect(node).to be_a(String)
        expect(node).to_not eql("")
      end
    end

    it "returns fixity_algorithms" do
      fixity_algorithms = @presenter.to_hash[:fixity_algorithms]
      expect(fixity_algorithms).to be_an(Array)
      fixity_algorithms.each do |node|
        expect(node).to be_a(String)
        expect(node).to_not eql("")
      end
    end

    it "returns storage" do
      storage = @presenter.to_hash[:storage]
      expect(storage).to be_a(Hash)
      expect(storage.size).to eql(2)
      expect(storage.has_key?(:region)).to be true
      expect(storage.has_key?(:type)).to be true
      expect(storage[:region]).to be_a(String)
      expect(storage[:type]).to be_a(String)
      expect(storage[:region]).to_not eql("")
      expect(storage[:type]).to_not eql("")
    end

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
      node = Fabricate(:node, created_at: time, updated_at: time)
      hash = ApiV1::NodePresenter.new(node).to_hash
      expect(hash[:created_at]).to eql(time.to_formatted_s(:dpn))
      expect(hash[:updated_at]).to eql(time.to_formatted_s(:dpn))
    end

  end
end













