require "json"

hash = JSON.parse(File.read("db/seeds/frequent_apple/seeds.json"), symbolize_names: true)
nodes = Node.all
hash[:run_time].each do |name|
  nodes.each do |node|
    FrequentApple::RunTime.create!(name: name, namespace: node.namespace)
  end
end