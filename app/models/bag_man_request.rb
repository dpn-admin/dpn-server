# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class BagManRequest < ActiveRecord::Base
  enum status: {
           requested: 0,
           downloaded: 1,
           unpacked: 2,
           preserved: 3,
           rejected: 4
       }

  has_one :replication_transfer, inverse_of: :bag_man_request

  validates :source_location, presence: true
  validates :validity, inclusion: {in: [nil, false, true]}
  validates :cancelled, inclusion: {in: [false, true]}

  after_create do |record|
    BagRetrievalJob.perform_later(record, Rails.configuration.staging_dir)
  end

  def staging_location(staging_dir = Rails.configuration.staging_dir)
    destination = File.join staging_dir, self.id.to_s
    staging_location = File.join(destination, File.basename(self.source_location))
  end
end
