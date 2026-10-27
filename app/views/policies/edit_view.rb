class Views::Policies::EditView < Views::ApplicationView
  prop :policy, Policy

  def view_template
    ResourceFormPage(record: @policy) { render Views::Policies::PolicyForm.new(@policy) }
  end
end
