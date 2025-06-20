class MountainsController < ApplicationController
  before_action :set_election, only: [:show, :edit, :update, :simulate]
  before_action :set_voter, only: [:show, :edit, :update, :simulate]
  before_action :set_baseline, only: [:show, :edit, :update]

  def index
    @elections = Election.active.includes(:candidacies)
    render Views::Mountains::IndexView.new(elections: @elections)
  end

  def show
    @mountain_data = build_mountain_data
    render Views::Mountains::ShowView.new(
      election: @election, 
      voter: @voter, 
      baseline: @baseline, 
      mountain_data: @mountain_data
    )
  end

  def edit
    @mountain_data = build_mountain_data
    render Views::Mountains::EditView.new(
      election: @election, 
      voter: @voter, 
      baseline: @baseline, 
      mountain_data: @mountain_data
    )
  end

  def update
    # Handle batch rating updates
    redirect_to mountain_path(@election, voter_id: @voter.id)
  end

  def simulate
    # Generate random candidacies with diverse backgrounds using SmartFactory
    candidate_count = rand(5..15)
    candidate_types = [:young_candidate, :experienced_politician, :business_leader, 
                      :community_activist, :educator, :veteran]
    
    candidate_count.times do
      # Mix of candidate types for realistic diversity with intelligent reuse
      person_type = candidate_types.sample
      candidacy_traits = [:democrat, :republican, :independent, :green].sample
      
      # Use SmartFactory for people (low reuse for diversity)
      person = SmartFactory.create_for_mountain_simulation(:person, [person_type])
      
      # Use SmartFactory for candidacies (very low reuse - each should be unique)
      SmartFactory.create_for_mountain_simulation(:candidacy, [candidacy_traits], 
                                                  person: person, election: @election)
    end

    # Create realistic ratings with varied patterns
    @election.candidacies.reload.each do |candidacy|
      # Use different rating patterns for more realistic mountain visualization
      rating_type = [:high_variance, :polarized, :moderate].sample
      
      # Ratings should never be reused (each voter rates each candidate once)
      SmartFactory.create_for_mountain_simulation(:rating, [rating_type], 
                                                  candidacy: candidacy, voter: @voter)
    end

    # Create realistic baseline for voter (high reuse - voters often have similar standards)
    SmartFactory.create_for_mountain_simulation(:voter_election_baseline, [:realistic_distribution],
                                                election: @election, voter: @voter)

    redirect_to mountain_path(@election, voter_id: @voter.id), notice: 'Simulation data generated successfully!'
  end

  private

  def set_election
    @election = Election.find(params[:id])
  end

  def set_voter
    @voter = if params[:voter_id].present?
               Voter.find(params[:voter_id])
             else
               current_voter || Voter.first || FactoryBot.create(:voter)
             end
  end

  def set_baseline
    @baseline = @election.voter_election_baselines.find_by(voter: @voter)
  end

  def build_mountain_data
    @election.candidacies.active.includes(:person, :ratings).map do |candidacy|
      rating = candidacy.ratings.find_by(voter: @voter)
      
      {
        candidacy: candidacy,
        rating_value: rating&.rating || 0,
        has_rating: rating.present?,
        is_approved: rating&.approved?(@baseline&.baseline),
        position_y: calculate_position(rating&.rating || 0)
      }
    end
  end

  def calculate_position(rating)
    # Convert 0-500 rating to CSS position (inverted for top-origin)
    max_height = 320 # pixels
    (max_height - (rating.to_f / 500.0 * max_height)).to_i
  end

  def current_voter
    # TODO: Implement proper voter session management
    nil
  end
end