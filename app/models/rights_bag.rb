class RightsBag < Bag
  has_and_belongs_to_many :data_bags, :uniq => true
end