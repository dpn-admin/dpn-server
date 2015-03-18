Fabricator(:restore_status) do
  name do
    sequence(:name) do |i|
      "restore_status_#{i}"
    end
  end
end