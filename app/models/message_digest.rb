# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class MessageDigest < ActiveRecord::Base
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
  validates_uniqueness_of :bag, scope: :fixity_alg


end