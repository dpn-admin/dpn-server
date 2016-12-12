# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

logger = Logger.new(STDOUT)
logger.info("Beginning seed process.")

seeder = Db::Seeder.new(Logger.new(STDOUT))
Db::SeedFileLoader.new(Rails.env.to_s).seed_hashes do |hash|
  seeder.seed!(hash)
end

logger.info("Seeding complete.")
