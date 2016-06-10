# Copyright (c) 2016 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

namespace :xfer do

  # Usage:
  #
  # 1) duplicate by RepliationTransfer.replication_id:
  #
  #    rake xfer:duplicate[5ef76916-28bc-4c33-929a-f0731ae9863d]
  #
  # 2) duplicate by RepliationTransfer.id:
  #
  #    rake xfer:duplicate[178]
  #
  desc "Duplicate a ReplicationTransfer and set to requested"
  task :duplicate, [:xfer_id] => :environment do |t, args|
    raise RuntimeError, "Param xfer_id (int or uuid) is required" if args.xfer_id == nil
    begin
      id = Integer(args.xfer_id)
      xfer = ReplicationTransfer.find(id)
    rescue ArgumentError
      xfer = ReplicationTransfer.where(replication_id: args.xfer_id).first
    rescue ActiveRecord::RecordNotFound
      # Handled below
    end
    if xfer.nil?
      puts "Cannot find ReplicationTransfer #{args.xfer_id}"
    else
      new_xfer = ReplicationTransfer.new
      new_xfer.bag_id = xfer.bag_id
      new_xfer.from_node_id = xfer.from_node_id
      new_xfer.to_node_id = xfer.to_node_id
      new_xfer.fixity_alg_id = xfer.fixity_alg_id
      new_xfer.protocol_id = xfer.protocol_id
      new_xfer.link = xfer.link
      new_xfer.created_at = new_xfer.updated_at = Time.now.utc
      new_xfer.replication_id = SecureRandom.uuid
      new_xfer.status = 0
      new_xfer.save
      puts "Created replication transfer this ReplicationTransfer, based on #{args.xfer_id}"
      puts ActiveSupport::JSON.encode(new_xfer)
    end
  end

end
