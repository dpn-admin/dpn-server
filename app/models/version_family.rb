class VersionFamily < ActiveRecord::Base
  has_many :bags, :inverse_of => :version_family

  validates :uuid, format: {
                   with: /\A[A-Fa-f0-9]{8}[A-Fa-f0-9]{4}[A-Fa-f0-9]{4}[A-Fa-f0-9]{4}[A-Fa-f0-9]{12}\Z/,
                   message: "Must be a UUIDv4 without dashes to save to the db."
                 }, on: :save

  def uuid=(uuid)
    write_attribute(:uuid, uuid.delete('-'))
  end

  def uuid
    uuid = read_attribute(:uuid)
    # 9th, 14th, 19th and 24th
    if uuid.include?('-') == false
      uuid.insert(8, "-")
      uuid.insert(13, "-")
      uuid.insert(18, "-")
      uuid.insert(23, "-")
    end
    return uuid
  end

  # Override the find_by_uuid call to eliminate dashes.
  def self.find_by_uuid(_uuid)
    super(_uuid.delete('-'))
  end

end