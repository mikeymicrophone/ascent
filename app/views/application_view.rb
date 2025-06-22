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
  include Phlex::Rails::Helpers::CurrentPage
  include Phlex::Rails::Helpers::Request

  include Devise::Controllers::Helpers
  include Pagy::Frontend

  include Views::Components

  def self.inherited(subclass)
    super
    auto_include_namespace_module subclass
  end

  private

  def expandable(object_or_collection, association_or_options = nil, title: nil, &block)
    # Handle different argument patterns:
    # expandable(@city, :offices) { ... }
    # expandable(collection, title: "Custom Title") { ... }

    if association_or_options.is_a?(Symbol)
      # Pattern: expandable(object, :association)
      collection = object_or_collection.send(association_or_options)
      section_title = title || association_or_options.to_s.humanize
    elsif association_or_options.is_a?(Hash) || title
      # Pattern: expandable(collection, title: "Title") or expandable(collection, "Title")
      collection = object_or_collection
      section_title = title || association_or_options[:title] || "Items"
    else
      # Pattern: expandable(collection) - use collection class name
      collection = object_or_collection
      section_title = collection.first&.class&.name&.pluralize || "Items"
    end

    return unless collection.respond_to?(:any?) && collection.any?

    Views::Components::ExpandableSection(
      title: section_title,
      count: collection.count
    ) do
      yield(collection) if block
    end
  end

  # All views that inherit from this have access to methods on their namespace module, including Kits
  def self.auto_include_namespace_module(klass)
    # Extract the module name from the class name
    # Views::Candidacies::EditView -> Views::Candidacies
    class_name = klass.name; return unless class_name&.start_with?("Views::")
    parts = class_name.split("::"); return unless parts.length >= 3  # Views, Namespace, ClassName
    module_name = parts[0..2].join("::")  # Views::Issues, Views::Candidacies, etc.

    begin
      target_module = module_name.constantize
      # Only include if it's a Module (not a Class) and is different from the class itself
      if target_module.is_a?(Module) && !target_module.is_a?(Class) && target_module != klass
        klass.include target_module
      end
    rescue NameError
      # This allows views that don't have a corresponding module
    end
  end
end
