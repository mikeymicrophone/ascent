# frozen_string_literal: true

module Views
end

module Components
  extend Phlex::Kit
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/views"), namespace: Views
)

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/components"), namespace: Components
)

# Superform expects a top-level application component before production eager
# loading begins. This uses the same shared route helpers as Components::Base.
class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
end unless defined?(ApplicationComponent)
