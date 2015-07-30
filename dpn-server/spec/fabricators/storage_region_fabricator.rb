Fabricator(:storage_region) do
  name do
    sequence(:name, 50) do |i|
      "region_#{i}"
    end
  end
end