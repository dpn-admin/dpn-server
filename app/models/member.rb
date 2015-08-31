class Member < ActiveRecord::Base
  ### Modifications and Concerns
  include Lowercased
  make_lowercased :uuid

  def to_param
    uuid
  end

  has_many :member_bags, class_name: "Bag", foreign_key: "member_id", autosave: true, inverse_of: :member

  ### ActiveModel::Dirty Validations
  validates_with ChangeValidator # Only perform a save if the record actually changed.
  validates :uuid, read_only: true, on: :update

  ### Static Validations
  validates :uuid, presence: true, uniqueness: true,
            format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
            message: "must be a valid v4 uuid." }
end
