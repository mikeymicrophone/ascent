class Views::Voters::VoterForm < Views::Components::Forms::Base
  def view_template
    row field(:first_name).text
    row field(:last_name).text
    row field(:birth_date).date
    row field(:is_verified).checkbox
  end
end
