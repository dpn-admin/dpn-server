Fabricator(:protocol) do
  name do
    sequence(:name, 50) do |i|
      "protocol_#{i}"
    end
  end
end