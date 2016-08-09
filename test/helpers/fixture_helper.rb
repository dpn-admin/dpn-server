#
# FixtureHelper loads fixtures for integration tests. Use this in
# your local environment and on your demo server to seed or reset
# your database for integration testing.
#
# Use this instead of ActiveRecord::FixtureSet on the demo/staging
# servers. ActiveRecord::FixtureSet generates record ids by hashing
# the record labels from the YAML fixture files. Those generated ids
# will never correspond to the actual records in the tables for
# Node, Protocol, FixityAlg and Member. That means fixtures will not
# load at all on demo/staging servers using ActiveRecord::FixtureSet.
#
class FixtureHelper

  TEST_MEMBER_UUID = "471fe920-bea3-4eb3-aafc-7841f8160479"
  APRIL_01_2016    = Time.new(2016, 4, 1, 0, 0, 0, "+00:00").utc


  def initialize
    @local_namespace = Rails.application.config.local_namespace
    @fixture_dir = "#{Rails.root}/test/fixtures/integration/#{@local_namespace}"
  end

  # This delete ALL of the VersionFamily, Bag, FixityCheck, ReplicationTransfer
  # and RestoreTransfer records from the database. This will raise an exception
  # if you try to run it in production.
  #
  # This does NOT delete core information that the system needs to run, such
  # as Node, Member, FixityAlg or Protocol records.
  def delete_fixtures
    raise "No deleting data in production!" unless safe_environment?
    puts "deleting message digests"
    MessageDigest.delete_all
    puts "done"
    Ingest.delete_all
    RestoreTransfer.delete_all
    ReplicationTransfer.delete_all
    FixityCheck.delete_all
    Bag.destroy_all
    VersionFamily.destroy_all
  end

  # This loads fixtures from the following files into the database:
  #
  # test/fixtures/integration/<namespace>/version_families.yml
  # test/fixtures/integration/<namespace>/bags.yml
  # test/fixtures/integration/<namespace>/fixity_checks.yml
  # test/fixtures/integration/<namespace>/replication_transfers.yml
  # test/fixtures/integration/<namespace>/restore_transfers.yml
  # test/fixtures/integration/<namespace>/digests.yml
  # test/fixtures/integration/<namespace>/ingests.yml
  #
  # This will raise an exception if you try to run it in production.
  def load_fixtures
    raise "No loading fixtures in production!" unless safe_environment?

    # Set vars we'll need while loading...
    @this_node = Node.where(namespace: @local_namespace).first
    if @this_node.nil?
      raise "Cannot load fixtures because system has no Node record for '#{@local_namespace}'."
    end

    # Load data from YAML fixture files.
    @versions = load_yaml_file(File.join(@fixture_dir, 'version_families.yml'))
    @bags = load_yaml_file(File.join(@fixture_dir, 'bags.yml'))
    @fixities = load_yaml_file(File.join(@fixture_dir, 'fixity_checks.yml'))
    @replications = load_yaml_file(File.join(@fixture_dir, 'replication_transfers.yml'))
    @restores = load_yaml_file(File.join(@fixture_dir, 'restore_transfers.yml'))
    @digests = load_yaml_file(File.join(@fixture_dir, 'digests.yml'))
    @ingests = load_yaml_file(File.join(@fixture_dir, 'ingests.yml'))

    # Now push the data in the database
    load_version_families
    load_bags
    load_message_digests
    load_fixity_checks
    load_ingests
    load_replication_transfers
    load_restore_transfers
  end

  # Loads the specified YAML file, replacing embedded variables
  # like <%= Rails.root %> with their proper values. If the items
  # in the YAML file have labels, this will return a hash of objects
  # in which the keys are the labels and the values are the objects.
  # Otherwise, it will return an array of objects.
  def load_yaml_file(filepath)
    yaml_data = YAML.load(ERB.new(File.read(filepath)).result)
    if yaml_data.is_a?(Hash)
      return_data = {}
      yaml_data.each do |key, value|
        return_data[key] = OpenStruct.new(value)
      end
    else
      return_data = []
      yaml_data.each do |item|
        return_data.push(OpenStruct.new(item))
      end
    end
    return_data
  end

  # Returns true if we're NOT running in the production environment.
  # We don't want to be loading fixtures or erasing anything in the
  # production environment.
  def safe_environment?
    Rails.env != "production"
  end

  # Returns the name of the directory from which fixtures are loaded.
  def fixture_dir
    @fixture_dir
  end

  # Returns the Protocol object for the rsync protocol.
  # Creates it if it doesn't exist.
  def rsync
    @rsync ||= Protocol.where(name: 'rsync').first
    if @rsync.nil?
      @rsync = Protocol.create(name: 'rsync', created_at: APRIL_01_2016, updated_at: APRIL_01_2016)
    end
    @rsync
  end

  # Returns the FixityAlg object for the sha256 algorithm.
  # Creates it if it does not exist.
  def sha256
    @sha256 ||= FixityAlg.where(name: 'sha256').first
    if @sha256.nil?
      @sha256 = FixityAlg.create(name: 'sha256', created_at: APRIL_01_2016, updated_at: APRIL_01_2016)
    end
    @sha256
  end

  # Returns a test member who will be the owner of all of the
  # bags used in integration test. If this member does not exist,
  # this method will create it.
  def test_member
    @test_member ||= Member.where(uuid: TEST_MEMBER_UUID).first
    if @test_member.nil?
      now = Time.now.utc
      test_member = Member.create!(uuid: TEST_MEMBER_UUID,
                                   name: "Integration Test University",
                                   email: "integration_test@example.com",
                                   created_at: now,
                                   updated_at: now)
    end
    @test_member
  end

  private

  # Loads VersionFamily records from
  # test/fixtures/integration/<namespace>/version_families.yml
  # into the database.
  def load_version_families
    @versions.values.each do |v|
      VersionFamily.create(uuid: v.uuid)
    end
  end

  # Loads Bag records from
  # test/fixtures/integration/<namespace>/bags.yml
  # into the database. Requires version_families be
  # loaded first.
  def load_bags
    @bags.values.each do |bag|
      version_family = VersionFamily.where(uuid: bag.uuid).first
      Bag.create!(uuid: bag.uuid,
                  ingest_node: @this_node,
                  admin_node: @this_node,
                  local_id: bag.local_id,
                  size: bag.size,
                  version: bag.version,
                  type: "DataBag",
                  created_at: APRIL_01_2016,
                  updated_at: APRIL_01_2016,
                  version_family: version_family,
                  member: self.test_member)
    end
  end

  # Loads FixityCheck records from
  # test/fixtures/integration/<namespace>/fixity_checks.yml
  # into the database. Requires bags be loaded first.
  def load_fixity_checks
    @fixities.values.each do |fixity|
      bag_uuid = @bags[fixity.bag].uuid
      bag = Bag.where(uuid: bag_uuid).first
      node = Node.where(namespace: fixity.node).first
      FixityCheck.create!(fixity_check_id: fixity.fixity_check_id,
                          bag: bag, 
                          node: node,
                          success: fixity.success,
                          fixity_at: APRIL_01_2016,
                          created_at: APRIL_01_2016)
                          
    end
  end

  # Loads ReplicationTransfer records from
  # test/fixtures/integration/<namespace>/replication_transfers.yml
  # into the database. Requires bags be loaded first.
  def load_replication_transfers
    @replications.values.each do |xfer|
      to_node = Node.where(namespace: xfer.to_node).first
      raise "to_node '#{xfer.to_node}' is missing from the node table." if to_node.nil?
      bag_uuid = @bags[xfer.bag].uuid
      bag = Bag.where(uuid: bag_uuid).first
      ReplicationTransfer.create(link: xfer.link,
                                 created_at: APRIL_01_2016,
                                 updated_at: APRIL_01_2016,
                                 replication_id: xfer.replication_id,
                                 bag: bag,
                                 from_node: @this_node,
                                 to_node: to_node,
                                 protocol: self.rsync,
                                 fixity_alg: self.sha256,
                                 store_requested: false,
                                 stored: false,
                                 cancelled: false)
    end
  end

  # Loads RestoreTransfer records from
  # test/fixtures/integration/<namespace>/restore_transfers.yml
  # into the database. Requires bags be loaded first.
  def load_restore_transfers
    @restores.values.each do |xfer|
      from_node = Node.where(namespace: xfer.from_node).first
      raise "from_node '#{xfer.from_node}' is missing from the node table." if from_node.nil?
      bag_uuid = @bags[xfer.bag].uuid
      bag = Bag.where(uuid: bag_uuid).first
      RestoreTransfer.create(link: xfer.link,
                             created_at: APRIL_01_2016,
                             updated_at: APRIL_01_2016,
                             restore_id: xfer.restore_id,
                             bag: bag,
                             from_node: from_node,
                             to_node: @this_node,
                             protocol: self.rsync,
                             cancelled: false)
    end
  end

  # Loads Digest records from
  # test/fixtures/integration/<namespace>/digests.yml
  # into the database. Requires bags be loaded first.
  def load_message_digests
    @digests.values.each do |digest|
      bag_uuid = @bags[digest.bag].uuid
      bag = Bag.where(uuid: bag_uuid).first
      node = Node.where(namespace: digest.node).first
      MessageDigest.create(bag: bag,
                           algorithm: slef.sha256,
                           node: node,
                           value: digest.value,
                           created_at: APRIL_01_2016)
    end 
  end 

  # Loads Ingest records from
  # test/fixtures/integration/<namespace>/ingests.yml
  # into the database. Requires bags be loaded first.
  def load_ingests
    @ingests.values.each do |ingest|
      bag_uuid = @bags[ingest.bag].uuid
      bag = Bag.where(uuid: bag_uuid).first
      Ingest.create(bag: bag,
                    ingest_id: ingest.ingest_id,
                    ingested: ingest.ingested,
                    created_at: APRIL_01_2016)
    end
  end 


end
