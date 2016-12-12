# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

namespace :config do

  Dir[Rails.root.join("lib", "templates", "config", "current", "*").to_s].each do |path|
    file = File.basename path
    desc "Generate #{file}"
    task file.to_sym do
      puts "Copying #{file}"
      copy_file path, "config/#{file}"
    end
  end

  desc "Generate cipher iv, key"
  task :cipher do
    cipher = EasyCipher::Cipher.new
    puts "key: #{cipher.key64.inspect}"
    puts "iv: #{cipher.iv64.inspect}"
  end

end

dependencies = Dir[Rails.root.join("lib", "templates", "config", "current", "*").to_s].map do |path|
  "config:#{File.basename(path)}".to_sym
end

task :config => dependencies do
  puts "Installed basic configuration files for development and test."
  puts "See config/*.yml.example for more info."
  puts "You may also wish to create a Gemfile.local to include gems specific to your environment."
end

