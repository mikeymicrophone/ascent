class Views::OfficialCodes::EditView < Views::ApplicationView
  def initialize(official_code:)
    @official_code = official_code
  end

  def view_template(&)
    div(class: "scaffold official_code-edit", id: dom_id(@official_code, :edit)) do
      h1 { "Editing official code" }
      
      Views::OfficialCodes::OfficialCodeForm(official_code: @official_code)
      
      div do
        link_to "Show this official code", 
                @official_code,
                class: "secondary"
        link_to "Back to official codes", 
                official_codes_path,
                class: "secondary"
      end
    end
  end
end