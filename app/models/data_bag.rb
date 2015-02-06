class DataBag < Bag
  has_and_belongs_to_many :brightening_bags, :uniq => true, :join_table => "data_brightenings"
  has_and_belongs_to_many :rights_bags, :uniq => true, :join_table => "data_rights"
end