Rails.configuration.default_per_page = 25
Rails.configuration.max_per_page = 100


Kaminari.configure do |config|
  config.default_per_page = Rails.configuration.default_per_page
  config.max_per_page = Rails.configuration.max_per_page
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
end
