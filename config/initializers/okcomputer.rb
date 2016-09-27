OkComputer.mount_at = 'status' # mounts at /status
OkComputer.check_in_parallel = true

OkComputer::Registry.register 'resque_down', OkComputer::ResqueDownCheck.new
OkComputer.make_optional %w(resque_down)
