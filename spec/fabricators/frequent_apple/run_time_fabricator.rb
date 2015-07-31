Fabricator(:frequent_apple_run_time, class_name: "FrequentApple::RunTime") do
  name { Faker::Internet.user_name }
  namespace { Fabricate(:node).namespace }
  last_run_time nil
end