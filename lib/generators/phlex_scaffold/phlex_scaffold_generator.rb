# frozen_string_literal: true

require "rails/generators"
require "rails/generators/resource_helpers"

class PhlexScaffoldGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers

  source_root File.expand_path("templates", __dir__)

  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  class_option :skip_routes, type: :boolean, desc: "Don't add routes to config/routes.rb."
  class_option :skip_controller, type: :boolean, desc: "Don't generate controller"
  class_option :skip_model, type: :boolean, desc: "Don't generate model"

  def create_phlex_views
    create_view_directory
    create_phlex_views_files
  end

  def generate_controller
    return if options[:skip_controller]
    
    template "controller.rb.tt", File.join("app/controllers", "#{controller_file_name}_controller.rb")
  end

  def generate_model
    return if options[:skip_model]
    
    attributes_with_index = attributes.map do |attr|
      attr_str = "#{attr.name}:#{attr.type}"
      attr_str += ":index" if attr.reference?
      attr_str
    end
    
    invoke "model", [singular_name] + attributes_with_index
  end

  def add_resource_route
    return if options[:skip_routes]
    
    route "resources :#{plural_name}"
  end

  private

  def create_view_directory
    empty_directory File.join("app/views", controller_file_path)
  end

  def create_phlex_views_files
    %w[index show new edit].each do |view|
      template "#{view}_view.rb.tt", File.join("app/views", controller_file_path, "#{view}_view.rb")
    end
    
    # Create form component
    template "form_component.rb.tt", File.join("app/views", controller_file_path, "#{singular_name}_form.rb")
    
    # Create partial component
    template "partial_component.rb.tt", File.join("app/views", controller_file_path, "#{singular_name}_partial.rb")
  end

  def controller_actions
    %w[index show new create edit update destroy]
  end

  def attributes_names
    @attributes_names ||= attributes.select { |attr| !attr.reference? }.map(&:name)
  end

  def form_attributes
    attributes.select { |attr| !attr.password_digest? && !attr.attachment? }
  end

  def display_attributes
    attributes.select { |attr| !attr.password_digest? }
  end

  def route_url
    @route_url ||= regular_class_path.empty? ? plural_name : "#{regular_class_path.join('/')}/#{plural_name}"
  end

  def index_helper
    singular_route_name.pluralize
  end

  def orm_class
    @orm_class ||= begin
      ActiveRecord::Generators::Base
    end
  end

  def orm_instance(name = singular_table_name)
    "@#{name}"
  end
end