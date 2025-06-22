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

  def expandable(context, collection_or_symbol, title: nil, &block)
    # Handle array context (future expansion for complex where clauses)
    if context.is_a?(Array)
      raise NotImplementedError, "Array context not implemented yet - for future stances filtering by topic AND state"
    end

    # Determine the collection
    if collection_or_symbol.is_a?(Symbol)
      # Fetch collection from context object using symbol
      if context.nil?
        raise ArgumentError, "Context cannot be nil when using symbol for collection"
      end
      collection = context.send(collection_or_symbol)
      section_title = title || collection_or_symbol.to_s.humanize
    else
      # Use provided collection directly
      collection = collection_or_symbol
      section_title = title || collection.first&.class&.name&.pluralize || "Items"
    end

    return unless collection.respond_to?(:any?) && collection.any?

    ExpandableSection(
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
