class Views::AreaOfConcerns::AreaOfConcernForm < Views::Components::Forms::Base
  def view_template
    row field(:name).text
    row field(:description).textarea(rows: 4)
    row field(:policy_domain).text
    row field(:regulatory_scope).text
  end
end
