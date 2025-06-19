# frozen_string_literal: true

class Views::ApplicationView < Phlex::HTML
  # Common helpers are included here to be available in all views.
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::SimpleFormat
  include Phlex::Rails::Helpers::Pluralize
end
