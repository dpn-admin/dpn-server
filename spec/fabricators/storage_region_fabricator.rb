Fabricator(:storage_region) do
  name do
    sequence(:name) do |i|
      "region_#{i}"
    end
  end
end