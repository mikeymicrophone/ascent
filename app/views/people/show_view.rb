class Views::People::ShowView < Views::ApplicationView
  def initialize(person:, notice: nil)
    @person = person
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold person-show", id: dom_id(@person, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing person" }
      
      Views::People::PersonPartial(person: @person)
      
      div do
        link_to "Edit this person", 
                edit_person_path(@person),
                class: "secondary"
        link_to "Back to people", 
                people_path,
                class: "secondary"
        button_to "Destroy this person", 
                  @person,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: "Are you sure?" }
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end