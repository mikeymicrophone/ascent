class VoterStatementsController < ApplicationController
  def create
    statement = current_voter.voter_statements.new(statement_params)
    if statement.save
      redirect_to influencer_profile_path(anchor: "statements"), notice: "Statement added.", status: :see_other
    else
      render Views::InfluencerProfiles::ShowView.new(voter: current_voter, invalid_item: statement), status: :unprocessable_content
    end
  end

  def update
    statement = current_voter.voter_statements.find(params[:id])
    if statement.update(statement_params)
      redirect_to influencer_profile_path(anchor: "statements"), notice: "Statement saved.", status: :see_other
    else
      render Views::InfluencerProfiles::ShowView.new(voter: current_voter, invalid_item: statement), status: :unprocessable_content
    end
  end

  def move
    return head :bad_request unless %w[up down].include?(params[:direction])

    current_voter.voter_statements.find(params[:id]).move!(params[:direction])
    redirect_to influencer_profile_path(anchor: "statements"), status: :see_other
  end

  private

  def statement_params
    params.require(:voter_statement).permit(:body, :active)
  end
end
