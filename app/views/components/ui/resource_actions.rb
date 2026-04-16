# frozen_string_literal: true

class Views::Components::Ui::ResourceActions < Views::Components::Base
  def initialize(resource:, show_path: nil, edit_path: nil, destroy_confirm: "Are you sure?")
    @resource = resource
    @show_path = show_path
    @edit_path = edit_path
    @destroy_confirm = destroy_confirm
  end

  def view_template
    return unless scaffold_record_actions_visible?(@resource)

    div do
      if show_path && scaffold_show_action_visible?(@resource)
        link_to "Show", show_path, class: scaffold_secondary_action_class
      end

      if edit_path && scaffold_edit_action_visible?(@resource)
        link_to "Edit", edit_path, class: scaffold_secondary_action_class
      end

      if can_destroy?
        button_to "Destroy", @resource,
                  method: :delete,
                  class: scaffold_destructive_action_class,
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
    scaffold_destroy_action_visible?(@resource)
  end
end
