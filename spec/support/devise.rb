RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  # Rails loads routes lazily in tests, and Devise only knows its voter mapping once they load,
  # so signing in before the first path helper would fail without this.
  config.before(:suite) { Rails.application.reload_routes_unless_loaded }
end
