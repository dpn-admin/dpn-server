class FrequentApple::RunTime < ActiveRecord::Base

  # We set this manually as autoloading for ActiveJobs was not
  # picking up the parent module's prefix.
  def self.table_name
    "frequent_apple_run_times"
  end

  after_initialize :defaults!

  validates :name, presence: true, uniqueness: true
  validates :last_run_time, presence: true

  def defaults!
    self.last_run_time ||= Time.at(0)
  end

end
