# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

# You should define these:
#let(:model)
#let(:public_hash)
#let(:model_hash)


shared_examples "an adapter" do |hidden_params|
  hidden_params ||= {}
  describe ".from_model" do
    it "can be created from a model" do
      expect{
        described_class.from_model(model)
      }.to_not raise_error
    end
  end

  describe ".from_public" do
    it "can be created from a model" do
      expect{
        described_class.from_public(public_hash)
      }.to_not raise_error
    end
    it "handles missing data" do
      expect{
        described_class.from_public({})
      }.to_not raise_error
    end
  end

  context "starting with .from_public" do
    let(:adapter) { described_class.from_public(public_hash.merge({unrelated: :unchanged}).merge(hidden_params)) }
    include_examples "adapter output", {unrelated: :unchanged}
  end


  context "starting with .from_model" do
    let(:adapter) { described_class.from_model(model) }
    include_examples "adapter output", {}
  end
end


shared_examples "adapter output" do |params_extra|
  describe "#to_model_hash" do
    it "creates the proper hash" do
      expect(adapter.to_model_hash).to fuzzy_nested_match(model_hash)
    end
    it "removes extra fields" do
      expect(adapter.to_model_hash.keys.sort).to match_array(model_hash.keys.sort)
    end
  end

  describe "#to_public_hash" do
    it "creates the proper hash" do
      expect(adapter.to_public_hash).to fuzzy_nested_match(public_hash)
    end
    it "removes extra fields" do
      expect(adapter.to_public_hash.keys.sort).to match_array(public_hash.keys.sort)
    end
  end

  describe "#to_params_hash" do
    it "creates the proper hash" do
      expect(adapter.to_params_hash).to fuzzy_nested_match(model_hash.merge(params_extra))
    end
  end
end

