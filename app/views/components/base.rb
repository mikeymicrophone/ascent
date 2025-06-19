# frozen_string_literal: true

class Views::Components::Base < Phlex::HTML
  # Include all Rails view helpers to make them available in all components
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  
  # You can add more helpers as needed:
  # include Phlex::Rails::Helpers::NumberHelper
  # include Phlex::Rails::Helpers::DateHelper
  # include Phlex::Rails::Helpers::UrlHelper
end