class BallotsController < ApplicationController
  def show
    authorize! :ballot
    render Views::Ballots::ShowView.new(ballot: current_voter.ballot, query: params[:q].to_s.strip)
  end
end
