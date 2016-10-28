OkComputer.mount_at = 'status' # mounts at /status
OkComputer.check_in_parallel = true

OkComputer::Registry.register 'resque_down', OkComputer::ResqueDownCheck.new
OkComputer.make_optional %w(resque_down)

# Simply report the application semantic version
class AppVersionCheck < OkComputer::Check
  def check
    mark_message "dpn-server: #{DPN::Server::Application::VERSION}"
  end
end
OkComputer::Registry.register 'app_version', AppVersionCheck.new
