class Views::OfficialCodes::ShowView < Views::ApplicationView
  def initialize(official_code:)
    @official_code = official_code
  end

  def view_template(&)
    div(class: "scaffold official_code-show", id: dom_id(@official_code, :show)) do
      h1 { "Showing official code" }

      OfficialCodePartial(official_code: @official_code)

      Ui::ResourceActions(resource: @official_code)
    end
  end
end
