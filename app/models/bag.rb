class Bag < ActiveRecord::Base
  belongs_to :ingest_node, :foreign_key => "ingest_node_id", :class_name => "Node"
  belongs_to :admin_node, :foreign_key => "admin_node_id", :class_name => "Node"
  has_many :fixity_checks

  belongs_to :version_family, :inverse_of => :bags

  has_many :replication_transfers
  has_many :restore_transfers

  has_and_belongs_to_many :replicating_nodes, :join_table => "replicating_nodes", :class_name => "Node", :uniq => true

  include Lowercased
  make_lowercased :uuid

  def to_param
    uuid
  end

  validates :uuid, presence: true, uniqueness: true
  validates :local_id, presence: true, uniqueness: true
  validates :size, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :version, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates_uniqueness_of :version, :scope => :version_family
  validate :self_legal_if_first_version?, on: [:create, :update]

  def legal_if_first_version?(version, uuid, version_family_uuid)
    if version == 1 || uuid == version_family_uuid
      return uuid == version_family_uuid && version == 1
    else
      return true
    end
  end

  private
  def self_legal_if_first_version?
    unless legal_if_first_version?(version, uuid, version_family.uuid)
      errors.add(:version, "version == 1 IFF uuid==version_family.uuid\n" +
        "\tgot version=#{version}, uuid=#{uuid}, version_family.uuid=#{version_family.uuid}")
    end
  end

end