# frozen_string_literal: true

class Views::Components::Ui::ResourceActions < Views::Components::Base
  def initialize(resource:, show_path: nil, edit_path: nil, destroy_confirm: "Are you sure?")
    @resource = resource
    @show_path = show_path
    @edit_path = edit_path
    @destroy_confirm = destroy_confirm
  end

  def view_template
    div do
      link_to "Show", show_path,
              class: "secondary" if show_path
      link_to "Edit", edit_path,
              class: "secondary" if edit_path
      if can_destroy?
        button_to "Destroy", @resource,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: @destroy_confirm }
      end
    end
  end

  private

  def show_path
    @show_path || @resource
  end

  def edit_path
    @edit_path || url_for([ :edit, @resource ])
  end

  def can_destroy?
    return true unless current_voter # If no voter is logged in, allow by default
    begin
      allowed_to?(:destroy?, @resource, context: { voter: current_voter })
    rescue ActionPolicy::NotFound
      # If no policy exists for this resource, allow destruction by default
      true
    rescue ActionPolicy::AuthorizationContextMissing
      # If authorization context is missing, allow destruction by default
      true
    end
  end
end
