# frozen_string_literal: true

module Views
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/views"), namespace: Views
)

# Superform expects a top-level application component before production eager
# loading begins. It only needs the shared route helpers.
class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
end unless defined?(ApplicationComponent)
