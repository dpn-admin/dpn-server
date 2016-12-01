# frozen_string_literal: true
# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "json"

module Db

  # Loads seed files and converts to a ruby hash.
  class SeedFileLoader
    BASE_DIR = File.join "db", "seeds"

    attr_reader :seed_dir
    def initialize(env_name, base_dir = BASE_DIR)
      @seed_dir = File.join(base_dir, "#{env_name}-seeds.d")
    end

    def seed_files
      @seed_files ||= Dir[File.join(seed_dir, "*")].sort
    end

    def seed_hashes
      seed_files.each do |f|
        seed_hash = JSON.parse(File.read(f), symbolize_names: true)
        yield seed_hash
      end
    end
  end

end
