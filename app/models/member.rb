# Header

class Member < ActiveRecord::Base
  ### Modifications and Concerns
  include ManagedUpdate
  include Lowercased
  make_lowercased :member_id

  def to_param
    member_id
  end

  def self.find_fields
    Set.new [:member_id]
  end

  has_many :bags, class_name: "Bag", foreign_key: "member_id", autosave: true, inverse_of: :member

  ### ActiveModel::Dirty Validations
  validates :member_id, read_only: true, on: :update

  ### Static Validations
  validates :member_id, presence: true, uniqueness: true,
            format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
            message: "must be a valid v4 uuid." }
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true

  scope :with_name, -> (name) {
    unless name.blank?
      where(name: name)
    end
  }
  scope :with_email, -> (email) {
    unless email.blank?
      where(email: email)
    end
  }


end
