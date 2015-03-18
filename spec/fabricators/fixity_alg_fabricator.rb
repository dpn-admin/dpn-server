Fabricator(:fixity_alg) do
  name do
    sequence(:name) do |i|
      "fixity_alg_#{i}"
    end
  end
end