Fabricator(:protocol) do
  name do
    sequence(:name) do |i|
      "protocol_#{i}"
    end
  end
end