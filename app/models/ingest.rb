# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class Ingest < ActiveRecord::Base

  def self.find_fields
    Set.new [:ingest_id]
  end
  
  belongs_to :bag, inverse_of: :ingests
  
  has_many :node_ingests, inverse_of: :ingest, dependent: :destroy,
    before_add: :fail_unless_new,
    before_remove: :fail_unless_new
  has_many :nodes, through: :node_ingests, source: :node

  ### ActiveModel::Dirty Validations
  validates :ingest_id,   read_only: true, on: :update
  validates :bag_id,      read_only: true, on: :update
  validates :ingested,    read_only: true, on: :update
  validates :created_at,  read_only: true, on: :update

  ### Static Validations
  validates :ingest_id, presence: true, uniqueness: true,
    format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
      message: "must be a valid v4 uuid." }
  validates :bag,             presence: true
  validates :ingested,        inclusion: {in: [false, true]}

  ### Scopes
  scope :created_after, ->(time) { where("created_at > ?", time) unless time.blank? }
  scope :created_before, ->(time) { where("created_at < ?", time) unless time.blank? }
  scope :with_bag_id, ->(id) { where(bag_id: id) unless id.blank? }
  scope :with_ingested, ->(ingested) { where(ingested: ingested) unless ingested.blank? }
  scope :latest_only, ->(flag) { group(:bag_id).having("created_at = max(created_at)") unless flag.blank? }
  
  private
  
  def fail_unless_new(node)
    unless new_record?
      errors.add(:nodes, "Cannot add or remove nodes after the initial creation of an ingest record.")
      raise ActiveRecord::RecordInvalid, self
    end
  end

end