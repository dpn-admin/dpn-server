# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

namespace :db do
  desc "Clear the data tuples from the db."
  task clear: :environment do
    RestoreTransfer.delete_all
    BagManRequest.delete_all
    ReplicationTransfer.delete_all
    FixityCheck.delete_all
    Bag.destroy_all
    Node.delete_all
    Member.delete_all
  end

  desc "Create an admin user."
  task admin_user: :environment do
    raise RuntimeError, "Refusing to create a dummy admin user in production." if Rails.env.production?
    email = "admin@example.org"
    password = "password"
    User.create!( email: email, admin: true, password: password)
    puts "Created user #{email} with password: \"#{password}\", without the quotes."
  end

end
