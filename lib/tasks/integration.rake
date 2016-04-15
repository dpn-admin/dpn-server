# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

#
# Tasks to set up your demo node for integration tests with
# other demo nodes.
#

namespace :integration do

  TEST_MEMBER_UUID = "471fe920-bea3-4eb3-aafc-7841f8160479"

  desc "Delete data used in internode testing, but preserve nodes and members"
  task delete_test_data: :environment do
    if Rails.env == "production"
      raise "Deleting data is not allowed in the production environment"
    end
    puts "Deleting all RestoreTransfers, ReplicationTransfers, " +
         "FixityChecks, Bags and VersionFamilies"
    RestoreTransfer.delete_all
    ReplicationTransfer.delete_all
    FixityCheck.delete_all
    Bag.destroy_all
    VersionFamily.destroy_all
  end

  desc "Load fixture bags and replication requests for testing"
  task load_fixtures: :environment do
    if Rails.env == "production"
      raise "You may not load test fixtures in the production environment"
    end

    local_namespace = Rails.application.config.local_namespace
    fixture_dir = "#{Rails.root}/test/fixtures/integration/#{local_namespace}"

    puts "Reloading RestoreTransfers, ReplicationTransfers, " +
         "FixityChecks, Bags and VersionFamilies from #{fixture_dir}"

    versions = load_yaml_file(File.join(fixture_dir, 'version_families.yml'))
    bags = load_yaml_file(File.join(fixture_dir, 'bags.yml'))
    fixities = load_yaml_file(File.join(fixture_dir, 'fixity_checks.yml'))
    replications = load_yaml_file(File.join(fixture_dir, 'replication_transfers.yml'))
    restores = load_yaml_file(File.join(fixture_dir, 'restore_transfers.yml'))

    # Create VersionFamily records
    puts "Creating VersionFamily records"
    versions.values.each do |v|
      VersionFamily.create(uuid: v['uuid'])
    end

    # Create Bag records
    # Use capital T in Test for Postgres
    test_member = get_test_member
    this_node = Node.where(namespace: local_namespace).first
    if this_node.nil?
      raise "Cannot create bags because system has no Node record for '#{local_namespace}'."
    end
    now = Time.now.utc
    puts "Creating bags"
    bags.values.each do |b|
      version_family = VersionFamily.where(uuid: b['uuid']).first
      Bag.create(uuid: b['uuid'],
                 ingest_node: this_node,
                 admin_node: this_node,
                 local_id: b['local_id'],
                 size: b.size,
                 version: b['version'],
                 type: "DataBag",
                 created_at: now,
                 updated_at: now,
                 version_family: version_family,
                 member: test_member)
    end

    # Create FixityCheck records
    puts 'Creating FixityChecks'
    sha256 = FixityAlg.where(name: 'sha256').first
    if sha256.nil?
      raise "Cannot load FixityChecks because FixityAlg sha256 is missing"
    end
    fixities.values.each do |f|
      # Get the bag uuid from the fixture data
      this_bag = bags[f['bag']]
      bag_uuid = this_bag['uuid']
      # Now look up the actual bag record in the DB
      bag = Bag.where(uuid: bag_uuid).first
      FixityCheck.create(bag: bag, fixity_alg: sha256, value: f['value'])
    end

    # Create ReplicationTransfer records
    rsync = Protocol.where(name: 'rsync').first
    if rsync.nil?
      raise "Cannot create Replication: 'rsync' is not in protocols table"
    end
    replications.values.each do |r|
      to_node = Node.where(namespace: r['to_node']).first
      if to_node.nil?
        raise "Cannot create Repication: to_node '#{r['to_node']}' is missing from the node table."
      end
      this_bag = bags[r['bag']]
      bag_uuid = this_bag['uuid']
      bag = Bag.where(uuid: bag_uuid).first
      ReplicationTransfer.create(link: r['link'],
                                 bag_valid: true,
                                 fixity_accept: false,
                                 created_at: now,
                                 updated_at: now,
                                 replication_id: r['replication_id'],
                                 bag: bag,
                                 from_node: this_node,
                                 to_node: to_node,
                                 status: 0,
                                 protocol: rsync,
                                 fixity_alg: sha256)
    end

    # Create ReplicationTransfer records
    restores.values.each do |r|
      from_node = Node.where(namespace: r['from_node']).first
      this_bag = bags[r['bag']]
      bag_uuid = this_bag['uuid']
      bag = Bag.where(uuid: bag_uuid).first
      RestoreTransfer.create(link: r['link'],
                             created_at: now,
                             updated_at: now,
                             restore_id: r['restore_id'],
                             bag: bag,
                             from_node: from_node,
                             to_node: this_node,
                             status: 0,
                             protocol: rsync)
    end
  end

  desc "Delete internode testing data and reload from fixtures"
  task reset: :environment do
    if Rails.env == "production"
      raise "Test data reset is not allowed in the production environment"
    end
    Rake::Task["integration:delete_test_data"].invoke
    Rake::Task["integration:load_fixtures"].invoke

    if Rails.env == "demo" && Rails.application.config.local_namespace == "aptrust"
      set_links_for_aptrust
    end
  end

  # Loads the specified YAML file, replacing embedded variables
  # like <%= Rails.root %> with their proper values.
  def load_yaml_file(filepath)
    YAML.load(ERB.new(File.read(filepath)).result)
  end

  def get_test_member
    test_member = Member.where(uuid: TEST_MEMBER_UUID).first
    if test_member.nil?
      now = Time.now.utc
      test_member = Member.create(uuid: TEST_MEMBER_UUID,
                                  name: "Integration Test University",
                                  email: "integration_test@example.com",
                                  created_at: now,
                                  updated_at: now)
    end
    test_member
  end

  # The replication transfer links in the fixture files work
  # for local testing, but not for the demo server, where
  # each remote node's ssh account gives it access only to
  # its own home directory. In APTrust, we symlink from the
  # node's own outbound directory to the general outbound dir.
  def set_links_for_aptrust
    ReplicationTransfer.where(from_node: 'aptrust').each do
      host = URI.parse(Rails.application.config.local_api_root).host
      ReplicationTransfer.where("link LIKE ?", "%IntTestValidBag__.tar").each do |xfer|
        path_to_bag = xfer.link
        bagname = xfer.link.split('/').last
        baguuid = xfer.bag.uuid

        # The rsync transfer link on the demo server should look like this:
        # dpn.tdr@dpn-demo.aptrust.org:outbound/533b3a28-03d7-4710-a411-99f49ca29a83.tar
        # We have to disable validation when we make the change,
        # because ReplicationTransfer#link is read-only
        xfer.link = "dpn.#{xfer.to_node}@#{host}:outbound/#{baguuid}.tar"
        xfer.save(validate: false)

        # Now make sure that there's a link to this bag in the
        # outbound directory for this to_node.
        symlink_path = "/home/dpn.#{xfer.to_node}/outbound/#{baguuid}.tar"
        File.symlink(path_to_bag, symlink_path)
      end
    end
  end

end
