# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe NodeAdapter do
  name = "fake_name"
  namespace = "fake_namespace"
  ssh_pubkey = Faker::Internet.password(20)
  api_root = Faker::Internet.url
  storage_region_name = "fake_storage_region"
  storage_type_name = "fake_storage_type"
  created_at = "2015-02-25T15:27:40Z"
  updated_at = created_at
  replicate_from_namespace = "repl_from_namespace"
  replicate_to_namespace = "repl_to_namespace"
  restore_from_namespace = "restore_from_namespace"
  restore_to_namespace = "restore_to_namespace"
  protocol_a = "acp"
  protocol_b = "bcp"
  fixity_alg_name = "fake_fixity_alg"
  auth_cred = "blargcred"
  auth_token = "blargtoken"

  before(:each) do

    @model = Fabricate(:node,
      name: name,
      namespace: namespace,
      ssh_pubkey: ssh_pubkey,
      api_root: api_root,
      storage_region: Fabricate(:storage_region, name: storage_region_name),
      storage_type: Fabricate(:storage_type, name: storage_type_name),
      private_auth_token: auth_token,
      auth_credential: auth_cred,
      created_at: time_from_string(created_at),
      updated_at: time_from_string(updated_at)
    )

    @model.replicate_from_nodes = [Fabricate(:node, namespace: replicate_from_namespace)]
    @model.replicate_to_nodes = [Fabricate(:node, namespace: replicate_to_namespace)]
    @model.restore_from_nodes = [Fabricate(:node, namespace: restore_from_namespace)]
    @model.restore_to_nodes = [Fabricate(:node, namespace: restore_to_namespace)]
    @model.protocols = [Fabricate(:protocol, name: protocol_a), Fabricate(:protocol, name: protocol_b)]
    @model.fixity_algs = [Fabricate(:fixity_alg, name: fixity_alg_name)]
    @model.save!

    @public_hash = {
      name: name,
      namespace: namespace,
      api_root: api_root,
      ssh_pubkey: ssh_pubkey,
      storage: {
        region: storage_region_name,
        type: storage_type_name
      },
      created_at: created_at,
      updated_at: updated_at,
      replicate_from: [replicate_from_namespace],
      replicate_to: [replicate_to_namespace],
      restore_from: [restore_from_namespace],
      restore_to: [restore_to_namespace],
      protocols: [protocol_a, protocol_b],
      fixity_algorithms: [fixity_alg_name]
    }

    @model_hash = {
      name: name,
      namespace: namespace,
      api_root: api_root,
      ssh_pubkey: ssh_pubkey,
      storage_region_id: @model.storage_region_id,
      storage_type_id: @model.storage_type_id,
      created_at: time_from_string(created_at),
      updated_at: time_from_string(updated_at),
      replicate_from_nodes: @model.replicate_from_nodes,
      replicate_to_nodes: @model.replicate_to_nodes,
      restore_from_nodes: @model.restore_from_nodes,
      restore_to_nodes: @model.restore_to_nodes,
      protocols: @model.protocols,
      fixity_algs: @model.fixity_algs,
      private_auth_token: auth_token,
      auth_credential: auth_cred
    }

  end

  let(:model) { @model }
  let(:public_hash) { @public_hash }
  let(:model_hash) { @model_hash }
  it_behaves_like "an adapter", {private_auth_token: auth_token, auth_credential: auth_cred}
  #
  # describe "it behaves like an adapter" do
  #   describe ".from_model" do
  #     it "can be created from a model" do
  #       expect{
  #         described_class.from_model(model)
  #       }.to_not raise_error
  #     end
  #   end
  #
  #   describe ".from_public" do
  #     it "can be created from a model" do
  #       expect{
  #         described_class.from_public(public_hash)
  #       }.to_not raise_error
  #     end
  #     it "handles missing data" do
  #       expect{
  #         described_class.from_public({})
  #       }.to_not raise_error
  #     end
  #   end
  #
  #   context "starting with .from_public" do
  #     related = {private_auth_token: auth_token, auth_credential: auth_cred}
  #     let(:adapter) { described_class.from_public(public_hash.merge({unrelated: :unchanged}).merge(related)) }
  #     include_examples "adapter output", {unrelated: :unchanged}
  #   end
  # end
  #
  # # it_behaves_like "an adapter"
  #
  # shared_examples "an adapter" do
  #
  #
  #   context "starting with .from_public" do
  #     let(:adapter) { described_class.from_public(public_hash.merge({unrelated: :unchanged})) }
  #     include_examples "adapter output", {unrelated: :unchanged}
  #   end
  #
  #
  #   context "starting with .from_model" do
  #     let(:adapter) { described_class.from_model(model) }
  #     include_examples "adapter output", {}
  #   end
  # end
  #
  #
  # shared_examples "adapter output" do |params_extra|
  #   describe "#to_model_hash" do
  #     it "creates the proper hash" do
  #       expect(adapter.to_model_hash).to fuzzy_nested_match(model_hash)
  #     end
  #     it "removes extra fields" do
  #       expect(adapter.to_model_hash.keys.sort).to match_array(model_hash.keys.sort)
  #     end
  #   end
  #
  #   describe "#to_public_hash" do
  #     it "creates the proper hash" do
  #       expect(adapter.to_public_hash).to fuzzy_nested_match(public_hash)
  #     end
  #     it "removes extra fields" do
  #       expect(adapter.to_public_hash.keys.sort).to match_array(public_hash.keys.sort)
  #     end
  #   end
  #
  #   describe "#to_params_hash" do
  #     it "creates the proper hash" do
  #       expect(adapter.to_params_hash).to fuzzy_nested_match(model_hash.merge(params_extra))
  #     end
  #   end
  #end

end