require "json"

hash = JSON.parse(File.read("db/seeds/frequent_apple/seeds.json"), symbolize_names: true)
hash[:run_time].each do |name|
  FrequentApple::RunTime.create!(name: name)
end