module FrequentApple; end
module RunTimeManagement
  extend ActiveSupport::Concern

  included do
    before_perform do |job|
      @current_run_time = Time.now.utc
      @last_run_object = FrequentApple::RunTime.find_by(name: job.class.to_s, namespace: job.arguments[0])
    end

    after_perform do |job|
      @last_run_object.last_run_time = @current_run_time
      @last_run_object.save!
    end
  end

  def last_run_time
    @last_run_object.last_run_time.strftime(Time::DATE_FORMATS[:dpn])
  end

end