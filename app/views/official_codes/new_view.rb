class Views::OfficialCodes::NewView < Views::ApplicationView
  def initialize(official_code:)
    @official_code = official_code
  end

  def view_template(&)
    div(class: "scaffold official_code-new", id: dom_id(@official_code, :new)) do
      h1 { "New official code" }
      
      Views::OfficialCodes::OfficialCodeForm(official_code: @official_code)
      
      div do
        link_to "Back to official codes", 
                official_codes_path,
                class: "secondary"
      end
    end
  end
end