Fabricator(:restore_transfer) do
  restore_id { Faker::Internet.password(7) }
  bag { Fabricate(:bag) }
  from_node { Fabricate(:node) }
  to_node { Fabricate(:node) }
  restore_status { Fabricate(:restore_status) }
  protocol { Fabricate(:protocol) }
  link { Faker::Internet.url }
end