class DataBag < Bag
  has_and_belongs_to_many :interpretive_bags, :uniq => true, :join_table => "data_interpretive"
  has_and_belongs_to_many :rights_bags, :uniq => true, :join_table => "data_rights"
end