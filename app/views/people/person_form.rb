class Views::People::PersonForm < Views::Components::Forms::Base
  def view_template
    row field(:first_name).text
    row field(:last_name).text
    row field(:middle_name).text
    row field(:email).text
    row field(:birth_date).date
    row field(:bio).textarea(rows: 4)
    row field(:portrait_url).input(type: :url), label: "Portrait image URL"
    row field(:portrait_credit).text, label: "Photo credit"
    row field(:portrait_source_url).input(type: :url), label: "Photo source URL"
  end
end
