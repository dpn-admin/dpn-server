namespace :db do
  desc "Clear the data tuples from the db."
  task clear: :environment do
    RestoreTransfer.delete_all
    ReplicationTransfer.delete_all
    BagManagerRequest.delete_all
    FixityCheck.delete_all
    Bag.destroy_all
    Node.delete_all
  end

end
