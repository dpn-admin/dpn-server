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

  desc 'Load cluster fixture data'
  task load_cluster_fixtures: :environment do
    # Use the same rake task to load fixtures as the one used in
    # script/run_cluster.rb
    node = Rails.application.config.local_namespace
    ENV['FIXTURES_DIR'] = "integration/#{node}"
    ENV['IMPERSONATE'] = node
    ENV['DATABASE_URL'] = "sqlite3:db/impersonate_#{node}.sqlite3"
    Rake::Task['db:fixtures:load'].invoke
  end

  desc 'Validate fixture data'
  task validate_cluster_fixtures: :environment do
    Rake::Task['integration:load_cluster_fixtures'].invoke
    models = Dir.glob('app/models/*.rb').map do |file|
      next if `grep 'ActiveRecord::Base' #{file}`.empty?
      file_name = File.basename(file).remove '.rb'
      file_name.split('_').map(&:capitalize).join
    end.compact.sort
    models.each do |model|
      begin
        klass = model.constantize
        klass.connection
        printf "Validating %3d records for #{model}\n", klass.count
        klass.all.each do |record|
          next if record.valid?
          puts "#{model}: id ##{record.id} is invalid:"
          record.errors.full_messages.each do |msg|
            puts "   - #{msg}"
          end
        end
      rescue => e
        puts "#{model}: skipping: #{e.message}"
      end
    end
  end # validate

  # The replication transfer links in the fixture files work
  # for local testing, but not for the demo server, where
  # each remote node's ssh account gives it access only to
  # its own home directory. In APTrust, we symlink from the
  # node's own outbound directory to the general outbound dir.
  def set_links_for_aptrust
    aptrust = Node.where(namespace: 'aptrust').first
    ReplicationTransfer.where(from_node: aptrust).each do
      host = URI.parse(Rails.application.config.local_api_root).host
      ReplicationTransfer.where("link LIKE ?", "%00000000-0000-4000-a000-00000000000_.tar").each do |xfer|
        path_to_bag = xfer.link
        bagname = xfer.link.split('/').last
        baguuid = xfer.bag.uuid

        # The rsync transfer link on the demo server should look like this:
        # dpn.tdr@dpn-demo.aptrust.org:outbound/533b3a28-03d7-4710-a411-99f49ca29a83.tar
        # We have to disable validation when we make the change,
        # because ReplicationTransfer#link is read-only
        xfer.link = "dpn.#{xfer.to_node.namespace}@#{host}:outbound/#{baguuid}.tar"
        xfer.save(validate: false)

        # Now make sure that there's a link to this bag in the
        # outbound directory for this to_node.
        symlink_path = "/home/dpn.#{xfer.to_node.namespace}/outbound/#{baguuid}.tar"
        if !File.exist?(symlink_path)
          puts "Creating symlink #{symlink_path} -> #{path_to_bag}"
          File.symlink(path_to_bag, symlink_path)
        else
          puts "Symlink exists at #{symlink_path}"
        end
      end
    end
  end

end
