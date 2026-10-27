module ScaffoldUiHelper
  def scaffold_controls_visible?
    true
  end

  def scaffold_new_resource_visible?(record)
    scaffold_controls_visible? && scaffold_allowed_to?(:create?, record)
  end

  def scaffold_record_actions_visible?(record)
    scaffold_controls_visible? && [
      scaffold_show_action_visible?(record),
      scaffold_edit_action_visible?(record),
      scaffold_destroy_action_visible?(record)
    ].any?
  end

  def scaffold_primary_action_class
    "primary"
  end

  def scaffold_secondary_action_class
    "secondary"
  end

  def scaffold_destructive_action_class
    "danger"
  end

  def scaffold_new_resource_link(label, path, record:, **options)
    return unless scaffold_new_resource_visible?(record)

    link_to label, path, **{ class: scaffold_primary_action_class }.merge(options)
  end

  def scaffold_show_action_visible?(record)
    scaffold_allowed_to?(:show?, record)
  end

  def scaffold_edit_action_visible?(record)
    scaffold_allowed_to?(:edit?, record)
  end

  def scaffold_destroy_action_visible?(record)
    scaffold_allowed_to?(:destroy?, record)
  end

  private

  def scaffold_allowed_to?(rule, record)
    return false unless scaffold_controls_visible?
    return false unless respond_to?(:allowed_to?)

    allowed_to?(rule, record, context: { voter: current_voter })
  rescue ActionPolicy::Unauthorized, ActionPolicy::NotFound, ActionPolicy::AuthorizationContextMissing
    false
  end
end
