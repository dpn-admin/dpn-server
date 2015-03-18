Fabricator(:storage_type) do
  name do
    sequence(:name) do |i|
      "storage_type_#{i}"
    end
  end
end