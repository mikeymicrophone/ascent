# frozen_string_literal: true

class Views::Countries::ShowView < Views::ApplicationView

  def initialize(country:)
    @country = country
  end

  def view_template(&)
    div(class: "scaffold country-show", id: dom_id(@country, :show)) do
      h1 { "Showing country" }

      CountryPartial(country: @country)

      Ui::ResourceActions(resource: @country)
    end
  end
end
