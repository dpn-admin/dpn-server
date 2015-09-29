# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

shared_examples "adapter output" do
  describe "#to_model_hash" do
    it "creates the proper hash" do
      expected = model.as_json
      expected.delete("id")
      expect(adapter.to_model_hash.stringify_keys).to eql(expected)
    end
    it "removes extra fields" do
      expected = model.attributes
      expected.delete("id")
      expect(adapter.to_model_hash.stringify_keys.keys.sort).to match_array(expected.keys.sort)
    end
  end

  describe "#to_public_hash" do
    it "creates the proper hash" do
      expect(adapter.to_public_hash).to eql(public_hash)
    end
    it "removes extra fields" do
      expect(adapter.to_public_hash.keys.sort).to match_array(public_hash.keys.sort)
    end
  end

  describe "#to_params_hash" do
    it "creates the proper hash" do
      expected = model.as_json
      expected.delete("id")
      expect(adapter.to_params_hash.stringify_keys).to include(expected)
    end
  end
end

describe ApiV1::RestoreTransferAdapter do

  let!(:model) {
    Fabricate(:restore_transfer,
      restore_id: "f107347c-81ea-4c6f-a508-a90d4b797497",
      from_node: Fabricate(:node, namespace: "fake_from_node"),
      to_node: Fabricate(:node, namespace: "fake_to_node"),
      bag: Fabricate(:data_bag, uuid: "9c0d880f-058c-4240-a71f-7048be13f448"),
      protocol: Fabricate(:protocol, name: "fake_transfer_protocol"),
      link: "user@herp.derp.org:/blah",
      status: :prepared,
      created_at: "2015-02-25T15:27:40Z",
      updated_at: "2015-02-25T15:27:40Z"
    )
  }
  let!(:public_hash) {
    {
      restore_id: "f107347c-81ea-4c6f-a508-a90d4b797497",
      from_node: "fake_from_node",
      to_node: "fake_to_node",
      uuid: "9c0d880f-058c-4240-a71f-7048be13f448",
      protocol: "fake_transfer_protocol",
      link: "user@herp.derp.org:/blah",
      status: "prepared",
      created_at: "2015-02-25T15:27:40Z",
      updated_at: "2015-02-25T15:27:40Z"
    }
  }

  describe ".from_model" do
    it "can be created from a model" do
      expect{
        ApiV1::RestoreTransferAdapter.from_model(model)
      }.to_not raise_error
    end
  end

  describe ".from_public" do
    it "can be created from a model" do
      expect{
        ApiV1::RestoreTransferAdapter.from_public(public_hash)
      }.to_not raise_error
    end
  end


  context "starting with .from_public" do
    let(:adapter) { ApiV1::RestoreTransferAdapter.from_public(public_hash.merge({unrelated: :unchanged})) }
    include_examples "adapter output"
    it "includes extra fields" do
      expect(adapter.to_params_hash).to have_key(:unrelated)
      expect(adapter.to_params_hash[:unrelated]).to eql(:unchanged)
    end
  end


  context "starting with .from_model" do
    let(:adapter) { ApiV1::RestoreTransferAdapter.from_model(model) }
    include_examples "adapter output"
  end
end

