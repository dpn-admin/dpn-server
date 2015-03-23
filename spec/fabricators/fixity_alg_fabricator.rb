Fabricator(:fixity_alg) do
  name do
    sequence(:name, 50) do |i|
      "fixity_alg_#{i}"
    end
  end
end