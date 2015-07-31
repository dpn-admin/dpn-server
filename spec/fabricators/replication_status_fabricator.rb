Fabricator(:replication_status) do
  name do
    sequence(:name, 50) do |i|
      "replication_status_#{i}"
    end
  end
end