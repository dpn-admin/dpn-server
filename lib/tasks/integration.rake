# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

#
# Tasks to set up your demo node for integration tests with
# other demo nodes.
#

namespace :integration do

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

    require 'active_record/fixtures'
    fixture_dir = "#{Rails.root}/test/fixtures/integration/#{Rails.application.config.local_namespace}"

    puts "Reloading RestoreTransfers, ReplicationTransfers, " +
         "FixityChecks, Bags and VersionFamilies from #{fixture_dir}"

    ActiveRecord::FixtureSet.create_fixtures(fixture_dir, 'version_families')
    ActiveRecord::FixtureSet.create_fixtures(fixture_dir, 'bags')
    ActiveRecord::FixtureSet.create_fixtures(fixture_dir, 'fixity_checks')
    ActiveRecord::FixtureSet.create_fixtures(fixture_dir, 'replication_transfers')
    ActiveRecord::FixtureSet.create_fixtures(fixture_dir, 'restore_transfers')
  end

  desc "Delete internode testing data and reload from fixtures"
  task reset: :environment do
    if Rails.env == "production"
      raise "Test data reset is not allowed in the production environment"
    end
    Rake::Task["integration:delete_test_data"].invoke
    Rake::Task["integration:load_fixtures"].invoke
  end

end
