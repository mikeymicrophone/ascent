class Views::People::ShowView < Views::ApplicationView
  def initialize(person:, notice: nil)
    @person = person
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold person-show", id: dom_id(@person, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing person" }
      
      PersonPartial(person: @person)
      
      Ui::ResourceActions(resource: @person)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end