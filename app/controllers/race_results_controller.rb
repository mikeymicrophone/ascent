class RaceResultsController < ApplicationController
  def show
    race = Race.with_naming_details.includes(office: { governing_body: :governance_type }).find(params.expect(:race_id))
    authorize! race, to: :show?
    group = RaceResults::GROUPS.include?(params[:group]) ? params[:group] : "resident"
    render Views::RaceResults::ShowView.new(race: race, group: group, summary: race.results_for(group))
  end
end
