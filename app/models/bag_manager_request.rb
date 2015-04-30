class BagManagerRequest < ActiveRecord::Base
  enum status: {
           requested: 0,
           downloaded: 1,
           unpacked: 2,
           preserved: 3
       }

  validates :source_location, presence: true
  validates :bag_valid, inclusion: {in: [nil, false, true]}
end
