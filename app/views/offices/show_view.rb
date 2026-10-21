class Views::Offices::ShowView < Views::ApplicationView
  def initialize(office:)
    @office = office
  end

  def view_template(&)
    div(class: "scaffold office-show", id: dom_id(@office, :show)) do
      h1 { "Showing office" }

      OfficePartial(office: @office)

      Ui::ResourceActions(resource: @office)
    end
  end
end
