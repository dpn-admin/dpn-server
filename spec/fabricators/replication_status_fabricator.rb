Fabricator(:replication_status) do
  name do
    sequence(:name) do |i|
      "replication_status_#{i}"
    end
  end
end