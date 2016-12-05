# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class MessageDigest < ActiveRecord::Base

  def self.find_fields
    Set.new [:bag_id, :fixity_alg_id]
  end
  
  belongs_to :node
  belongs_to :bag
  belongs_to :fixity_alg

  ### ActiveModel::Dirty Validations
  validates :bag_id,        read_only: true, on: :update
  validates :fixity_alg_id, read_only: true, on: :update
  validates :value,         read_only: true, on: :update
  validates :node_id,       read_only: true, on: :update
  validates :created_at,    read_only: true, on: :update

  ### Static Validations
  validates :bag,         presence: true
  validates :fixity_alg,  presence: true
  validates :value,       presence: true
  validates :node,        presence: true
  validates :created_at,  presence: true

  ### Scopes
  scope :created_after, ->(time) { where("created_at > ?", time) unless time.blank? }
  scope :created_before, ->(time) { where("created_at < ?", time) unless time.blank? }
  scope :with_bag_id, ->(id) { where(bag_id: id) unless id.blank? }


end