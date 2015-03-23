Fabricator(:restore_status) do
  name do
    sequence(:name, 50) do |i|
      "restore_status_#{i}"
    end
  end
end