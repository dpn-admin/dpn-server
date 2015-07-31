
namespace :frequent_apple do
  namespace :jobs do
    desc "Run an arbitrary job for a specific node."
    task :run, [:jobname, :target_node, :local_node] => :environment do |t, args|
      args[:jobname].classify.constantize.perform_now(args[:target_node], args[:local_node])
    end
  end
end
