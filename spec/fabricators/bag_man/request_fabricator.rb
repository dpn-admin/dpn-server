Fabricator(:bag_man_request, class_name: "BagManRequest") do
  source_location { Faker::Internet.url }
  preservation_location nil
  status :requested
  fixity nil
  validity nil
  cancelled false
end