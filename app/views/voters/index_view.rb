# frozen_string_literal: true

class Views::Voters::IndexView < Views::ApplicationView
  prop :voters, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @voters, pagy: @pagy, lede: "Everyone with an Ascent account. Only admins see this list.") do |voter|
      ListRow(record: voter, title: voter.full_name, meta: "Joined #{voter.created_at.strftime("%b %-d, %Y")}") do
        span(class: "row-badge") { "Verified" } if voter.is_verified
        span(class: "row-badge") { "Admin" } if voter.admin?
      end
    end
  end
end
