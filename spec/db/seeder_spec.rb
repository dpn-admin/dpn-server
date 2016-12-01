# frozen_string_literal: true
require "rails_helper"

describe Db::Seeder do
  class TestLogger
    attr_reader :info_messages, :warn_messages, :error_messages
    def initialize
      @info_messages = []
      @warn_messages = []
      @error_messages = []
    end

    def info(msg)
      @info_messages << msg
    end

    def warn(msg)
      @warn_messages << msg
    end

    def error(msg)
      @error_messages << msg
    end
  end

  let(:logger) { TestLogger.new }
  let(:seeder) { described_class.new(logger) }

  describe "#report" do
    let(:name) { "ClassName" }
    let(:obj) { { a: 1, b: 2 } }
    let(:success_message) { "Created #{name}: #{obj}" }
    let(:skip_message) { "Skipped existing #{name}: #{obj}" }
    let(:fail_message) { "Could not create #{name}: #{obj}" }
    it "reports success when no errors" do
      seeder.report(name, obj) { true }
      expect(logger.info_messages).to eql([success_message])
      expect(logger.warn_messages).to be_empty
      expect(logger.error_messages).to be_empty
    end
    it "reports skip when ActiveRecord::RecordNotUnique" do
      seeder.report(name, obj) { raise ActiveRecord::RecordNotUnique.new(double.as_null_object) }
      expect(logger.info_messages).to eql([skip_message])
      expect(logger.warn_messages).to be_empty
      expect(logger.error_messages).to be_empty
    end
    it "reports failure when ActiveRecord::RecordInvalid" do
      invalid_record = Fabricate.build(:member, member_id: "5")
      invalid_record.validate # force population of validation errors hash
      seeder.report(name, obj) do
        raise ActiveRecord::RecordInvalid.new(invalid_record)
      end
      expect(logger.info_messages).to be_empty
      expect(logger.warn_messages).to be_empty
      expect(logger.error_messages).to eql([fail_message])
    end
    it "reports failure when ActiveRecord::UnknownAttributeError" do
      seeder.report(name, obj) do
        raise ActiveRecord::UnknownAttributeError.new(
          double.as_null_object,
          double.as_null_object
        )
      end
      expect(logger.info_messages).to be_empty
      expect(logger.warn_messages).to be_empty
      expect(logger.error_messages).to eql([fail_message])
    end
  end

  # @param klass [Class] The class of the records we're creating
  # @param entries [Array<Hash>] let(:entries) { the entries }
  # @param type [Symbol] let(:type) Plural of the type, e.g. :nodes
  # @param fabricator_name [Symbol] let(:fabricator_name) Fabricator name
  # @param display_field [Symbol] let(:display_field) The fields used when displaying object
  #   in the log.
  shared_examples "a seedable class" do |klass|
    it "creates #{klass} records" do
      seeder.create(type, entries)
      stored_records_as_arrays = klass.pluck(*entries.first.keys) # We do this because pluck auto-flattens
        .map{|val_or_vals| [val_or_vals].flatten }                # when you only pluck one field.
      expect(stored_records_as_arrays).to include(*entries.map(&:values))
    end
    it "skips existing #{klass} records" do
      Fabricate(fabricator_name, entries.first)
      seeder.create(type, entries)
      expect(logger.info_messages)
        .to include("Skipped existing #{klass}: #{entries.first[display_field]}")
    end
  end

  describe "create fixity_algs" do
    it_behaves_like "a seedable class", FixityAlg do
      let(:entries) { [{name: "sha1000"}, {name: "sha9001"}]}
      let(:type) { :fixity_algs }
      let(:fabricator_name) { :fixity_alg }
      let(:display_field) { :name }
    end
  end

  describe "create protocols" do
    it_behaves_like "a seedable class", Protocol do
      let(:entries) { [{name: "p1"}, {name: "p2"}]}
      let(:type) { :protocols }
      let(:fabricator_name) { :protocol }
      let(:display_field) { :name }
    end
  end

  describe "create storage_regions" do
    it_behaves_like "a seedable class", StorageRegion do
      let(:entries) { [{name: "r1"}, {name: "r2"}]}
      let(:type) { :storage_regions }
      let(:fabricator_name) { :storage_region }
      let(:display_field) { :name }
    end
  end

  describe "create storage_types" do
    it_behaves_like "a seedable class", StorageType do
      let(:entries) { [{name: "t1"}, {name: "t2"}]}
      let(:type) { :storage_types }
      let(:fabricator_name) { :storage_type }
      let(:display_field) { :name }
    end
  end

  describe "create members" do
    it_behaves_like "a seedable class", Member do
      let(:entries) do
        2.times.map do
          { member_id: SecureRandom.uuid, name: Faker::Company.name, email: Faker::Internet.email }
        end
      end
      let(:type) { :members }
      let(:fabricator_name) { :member }
      let(:display_field) { :name }
    end
  end

  describe "create nodes" do
    let(:entry) do
      {
        namespace: Faker::Lorem.word,
        name: Faker::Company.name,
        storage_region: Fabricate(:storage_region).name,
        storage_type: Fabricate(:storage_type).name,
        fixity_algs: [Fabricate(:fixity_alg).name],
        protocols: [Fabricate(:protocol).name],
        api_root: Faker::Internet.url,
        private_auth_token: Faker::Crypto.sha256,
        auth_credential: Faker::Crypto.sha256
      }
    end

    let(:skip_message) { "Skipped existing Node: #{entry[:namespace]}" }

    it "creates Node records" do
      seeder.create(:nodes, [entry])
      created_node = Node.find_by_namespace(entry[:namespace])
      expect(created_node.name).to eql(entry[:name])
      expect(created_node.storage_region.name).to eql(entry[:storage_region])
      expect(created_node.storage_type.name).to eql(entry[:storage_type])
      expect(created_node.fixity_algs.pluck(:name)).to contain_exactly(*entry[:fixity_algs])
      expect(created_node.protocols.pluck(:name)).to contain_exactly(*entry[:protocols])
      expect(created_node.api_root).to eql(entry[:api_root])
      expect(created_node.private_auth_token)
        .to eql(Node.send(:generate_hash, entry[:private_auth_token]))
      expect(created_node.auth_credential).to eql(entry[:auth_credential])
    end
    it "skips existing Node records" do
      Fabricate(:node, namespace: entry[:namespace])
      seeder.create(:nodes, [entry])
      expect(logger.info_messages).to eql([skip_message])
    end
  end

  describe "#create_all_node_agreements" do
    let(:nodes) { Fabricate.times(2, :node) }
    let(:entries) do
      namespaces = nodes.map(&:namespace)
      namespaces.map do |node_namespace|
        {
          namespace: node_namespace,
          replicate_to_nodes: namespaces,
          replicate_from_nodes: namespaces,
          restore_to_nodes: namespaces,
          restore_from_nodes: namespaces
        }
      end
    end

    [:replicate_to_nodes, :replicate_from_nodes,
     :restore_to_nodes, :restore_from_nodes].each do |agreement_type|
      it "creates #{agreement_type} records" do
        seeder.create_all_node_agreements(entries)
        nodes.each do |node|
          expect(node.public_send(agreement_type)).to contain_exactly(*nodes)
        end
      end
    end
  end
end
