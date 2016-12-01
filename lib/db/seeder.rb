# frozen_string_literal: true
# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "json"

module Db

  # Create domain objects from seed hashes if they do not already exist.
  # This class does _not_ update objects that already exist.
  #
  # A log entry is created for each seed entry that is created,
  # each skipped entry (if it already exists), and each entry that
  # the seeder failed to create.
  class Seeder

    # @param logger [Logger] logger  Defaults to the Rails.logger
    def initialize(logger = nil)
      @logger = logger || Rails.logger
      @maps = {
        fixity_algs:      [FixityAlg,     proc {|e| e[:name] },       proc {|e| e.slice(:name) }],
        protocols:        [Protocol,      proc {|e| e[:name] },       proc {|e| e.slice(:name) }],
        storage_regions:  [StorageRegion, proc {|e| e[:name] },       proc {|e| e.slice(:name) }],
        storage_types:    [StorageType,   proc {|e| e[:name] },       proc {|e| e.slice(:name) }],
        members:          [Member,        proc {|e| e[:name] },       proc {|e| member_from_entry(e) }],
        nodes:            [Node,          proc {|e| e[:namespace] },  proc {|e| node_from_entry(e) }]
      }
    end

    # Create the objects described by the entries hash, of the given
    # type, if they do not already exist.
    # @overload create(type, entries)
    #   @param type [Symbol] Plural type, corresponding to the class of the
    #     record to be created as well as the field in the seeds file.  Includes
    #     :fixity_algs, :protocols, :storage_regions, :storage_types.
    #   @param entries [Array<String>] The names of the records to be created.
    #
    # @overload create(type, entries)
    #   @param type [Symbol] Must be :members
    #   @param entries [Array<Hash>] Array of entries
    #   @option entries [String] :member_id
    #   @option entries [String] :name
    #   @option entries [String] :email
    #
    # @overload create(type, entries)
    #   @param type [Symbol] Must be :nodes
    #   @param entries [Array<Hash>] Array of entries.
    #   @option entries [String] :namespace
    #   @option entries [String] :name
    #   @option entries [String] :storage_region StorageRegion name
    #   @option entries [String] :storage_type StorageType name
    #   @option entries [Array<String>] :fixity_algs FixityAlg names
    #   @option entries [Array<String>] :protocols Protocol names
    #   @option entries [String] :api_root
    #   @option entries [String] :private_auth_token Unencrypted
    #   @option entries [String] :auth_credential Unencrypted
    def create(type, entries)
      create_from_entries(entries, *maps[type])
    end

    # Create the objects described by the seed hash, if they do not already
    # exist.  For each entry, a short report is generated in this object's
    # logger.
    # @param [Hash] seed_hash  @see Seeder#create for help with the structure of the hash.
    def seed!(seed_hash)
      [:fixity_algs, :protocols, :storage_regions, :storage_types, :members, :nodes].each do |type|
        create(type, seed_hash[type] || [])
      end
      create_all_node_agreements(seed_hash[:nodes] || [])
    end

    # @api private
    # Generate a report of success, skip, or failure
    # based on the presence and type of an exception raised
    # by the passed block.
    # @param [String] display_name The name of the thing being created,
    #   for logging purposes.
    # @param [#to_s] display_obj The object to display, for logging
    #   purposes.
    # @yield [] The block should create the object identified by display_name
    #     and display_obj.  It should raise ActiveRecord::RecordNotUnique for a
    #     duplicate, and one of the ActiveRecord failure exceptions when creation
    #     is not possible.
    def report(display_name, display_obj)
      begin
        yield
        report_success(display_name, display_obj)
      rescue ActiveRecord::RecordNotUnique
        report_skip(display_name, display_obj)
      rescue ActiveRecord::RecordInvalid => e
        if should_skip_invalid?(e.record.errors)
          report_skip(display_name, display_obj)
        else
          report_fail(display_name, display_obj)
        end
      rescue ActiveRecord::UnknownAttributeError
        report_fail(display_name, display_obj)
      end
    end

    # @api private
    # Create agreements between nodes.  Does not create the nodes if they
    # do not exist.
    # @param [Array<Hash>] node_entries The hash elements should each have
    #   the keys :namespace, :replicate_from_nodes, :replicate_to_nodes,
    #   :restore_from_nodes, :restore_to_nodes.
    def create_all_node_agreements(node_entries)
      [:replicate_from_nodes, :replicate_to_nodes,
       :restore_from_nodes, :restore_to_nodes
      ].each do |agreement_type|
        create_node_agreements(node_entries, agreement_type)
      end
    end

    # @api private
    # @param node_entries [Array<Hash>] The hash elements should each have
    #   the keys :namespace, :"#{agreement_type}"
    # @param agreement_type [Symbol] The method name of the agreement type,
    #   e.g. :replicate_to_nodes
    def create_node_agreements(node_entries, agreement_type)
      node_entries.each do |node_entry|
        node, new_nodes, duplicate_nodes = discover_nodes(node_entry, agreement_type)

        duplicate_nodes.each do |existing_node|
          report_skip("#{agreement_type} for #{node_entry[:namespace]}", existing_node.namespace)
        end

        new_nodes.each do |new_node|
          report("#{agreement_type} for #{node_entry[:namespace]}", new_node.namespace) do
            node.public_send(agreement_type) << new_node
          end
        end
      end
    end

    private

    attr_reader :logger, :maps

    def create_from_entries(entries, klass, display_block, convert_block)
      entries.each do |entry|
        report(klass, display_block.call(entry)) do
          klass.create! convert_block.call(entry)
        end
      end
    end

    def discover_nodes(node_entry, agreement_type)
      node = Node.find_by_namespace(node_entry[:namespace])
      seed_nodes = Node.where(namespace: node_entry[agreement_type])
      duplicate_nodes = seed_nodes & node.public_send(agreement_type)
      new_nodes = seed_nodes - duplicate_nodes
      return node, new_nodes, duplicate_nodes
    end

    DUPLICATE_ERROR_MESSAGE = ["has already been taken"].freeze
    def should_skip_invalid?(errors)
      errors.values.delete_if do |e|
        e == DUPLICATE_ERROR_MESSAGE
      end.empty?
    end

    def report_success(display_name, display_obj)
      logger.info("Created #{display_name}: #{display_obj}")
    end

    def report_skip(display_name, display_obj)
      logger.info("Skipped existing #{display_name}: #{display_obj}")
    end

    def report_fail(display_name, display_obj)
      logger.error("Could not create #{display_name}: #{display_obj}")
    end

    def simple_record_from_entry(entry)
      { name: entry }
    end

    def node_from_entry(node_entry)
      {
        namespace: node_entry[:namespace],
        name: node_entry[:name],
        storage_region: StorageRegion.find_by_name(node_entry[:storage_region]),
        storage_type: StorageType.find_by_name(node_entry[:storage_type]),
        fixity_algs: FixityAlg.where(name: node_entry[:fixity_algs]),
        protocols: Protocol.where(name: node_entry[:protocols]),
        api_root: node_entry[:api_root],
        private_auth_token: node_entry[:private_auth_token],
        auth_credential: node_entry[:auth_credential]
      }
    end

    def member_from_entry(member_entry)
      member_entry.slice(:member_id, :name, :email)
    end
  end

end
