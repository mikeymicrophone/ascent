class Views::InfluencerProfiles::ShowView < Views::ApplicationView
  prop :voter, Voter
  prop :invalid_item, _Nilable(ActiveRecord::Base)

  def view_template
    div(class: "index-page") do
      PageHeader(title: "Influencer links and statements", trail: [ [ "Profile", edit_voter_path(@voter) ] ],
        lede: "Add and edit your links and statements. Move them into the order you want. Inactive items stay private.")
      collection("Links", @voter.voter_links.reload.to_a, VoterLink)
      collection("Statements", @voter.voter_statements.reload.to_a, VoterStatement)
    end
  end

  private

  def collection(title, items, model)
    section(class: "place-section", id: title.downcase) do
      section_heading(title)
      items.each_with_index do |item, index|
        item = @invalid_item if @invalid_item&.class == model && @invalid_item.id == item.id
        article(class: "influencer-content-item", id: dom_id(item)) do
          span(class: "row-badge") { "Inactive" } unless item.active?
          VoterContentForm(item: item)
          div(class: "place-actions") do
            button_to "Move up", polymorphic_path([ :move, item ]), method: :patch, params: { direction: "up" },
              disabled: index.zero?, class: "secondary", aria: { label: "Move #{title.singularize.downcase} #{index + 1} up" }
            button_to "Move down", polymorphic_path([ :move, item ]), method: :patch, params: { direction: "down" },
              disabled: index == items.length - 1, class: "secondary", aria: { label: "Move #{title.singularize.downcase} #{index + 1} down" }
          end
        end
      end
      h3(class: "card-title") { "Add #{title.singularize.downcase}" }
      new_item = @invalid_item&.class == model && @invalid_item.new_record? ? @invalid_item : model.new(voter: @voter)
      VoterContentForm(item: new_item)
    end
  end
end
