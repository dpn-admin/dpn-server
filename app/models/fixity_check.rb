class FixityCheck < ActiveRecord::Base
  belongs_to :fixity_alg
  belongs_to :bag
end