# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require "json"

hash = JSON.parse(File.read("db/seeds/frequent_apple/seeds.json"), symbolize_names: true)
nodes = Node.all
hash[:run_time].each do |name|
  nodes.each do |node|
    FrequentApple::RunTime.create!(name: name, namespace: node.namespace)
  end
end