# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

#
# Tasks to set up your demo node for integration tests with
# other demo nodes.
#

require_relative '../../test/helpers/fixture_helper.rb'

namespace :integration do

  desc "Delete data used in internode testing, but preserve nodes and members"
  task delete_test_data: :environment do
    if Rails.env == "production"
      raise "Deleting data is not allowed in the production environment"
    end
    puts "Deleting all Bags and Transfers"
    fixture_helper = FixtureHelper.new()
    fixture_helper.delete_fixtures
  end

  desc "Load fixture bags and replication requests for testing"
  task load_fixtures: :environment do
    if Rails.env == "production"
      raise "You may not load test fixtures in the production environment"
    end
    fixture_helper = FixtureHelper.new()
    puts "Loading Bags and Transfers from #{fixture_helper.fixture_dir}"
    fixture_helper.load_fixtures
  end

  desc "Delete internode testing data and reload from fixtures"
  task reset: :environment do
    Rake::Task["integration:delete_test_data"].invoke
    Rake::Task["integration:load_fixtures"].invoke
    if Rails.env == "demo" && Rails.application.config.local_namespace == "aptrust"
      set_links_for_aptrust
    end
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
