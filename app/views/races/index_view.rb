class Views::Races::IndexView < Views::ApplicationView
  def initialize(races:, pagy: nil, notice: nil)
    @races = races
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold races-index", id: "index_races") do
      render_notice if @notice.present?
      
      div do
        h1 { "Races" }
        scaffold_new_resource_link "New race", new_race_path, record: Race
      end

      div(id: "races") do
        if @races.any?
          @races.each do |race|
            div(id: dom_id(race, :list_item)) do
              RacePartial(race: race)
              
              div do
                button_to("Simulate Data", simulate_mountain_path(race), 
                  method: :post, class: "btn-secondary", form: { style: "display: inline;" })
                whitespace
                Ui::ResourceActions(resource: race)
              end
            end
          end
        else
          p { "No races found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end
