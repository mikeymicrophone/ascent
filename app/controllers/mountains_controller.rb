class MountainsController < ApplicationController
  before_action :set_race, only: [:show, :edit, :update, :simulate, :primary_candidates]
  before_action :set_voter, only: [:show, :edit, :update, :simulate, :primary_candidates]
  before_action :set_baseline, only: [:show, :edit, :update]

  def index
    @races = Race.active.with_naming_details.includes(:candidacies)
    render Views::Mountains::IndexView.new(races: @races)
  end

  def show
    render_mountain_editor
  end

  def edit
    render_mountain_editor
  end

  def update
    ActiveRecord::Base.transaction do
      update_baseline
      update_ratings
    end

    # Stay on the editable mountain so ratings remain draggable after save.
    redirect_to mountain_path(@race, voter_id: @voter.id), notice: "Mountain ratings updated."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    redirect_to mountain_path(@race, voter_id: @voter.id),
                alert: "Could not save mountain ratings: #{e.message}"
  end

  def primary_candidates
    included = params[:included] == "1"
    @voter.include_primary_candidates!(@race, included)
    redirect_to mountain_path(@race, voter_id: @voter.id),
                notice: included ? "Primary candidates added to your mountain." : "Primary candidates removed from your mountain."
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
                                                  person: person, race: @race)
    end

    # Create realistic policy stances for each candidate
    @race.candidacies.reload.each do |candidacy|
      # Skip if candidate already has stances
      next if candidacy.stances.any?
      
      # Create 2-5 stances per candidate on different policy areas
      stance_count = rand(2..5)
      created_issues = []
      
      stance_count.times do
        # Get a random issue that hasn't been used for this candidate
        available_issues = Issue.where.not(id: created_issues)
        next if available_issues.empty?
        
        issue = available_issues.sample
        created_issues << issue.id
        
        # Find an approach for this issue
        approach = issue.approaches.sample
        next unless approach
        
        # Create stance with realistic priority and explanation
        priority_level = [:high, :medium, :low].sample
        stance_traits = case priority_level
                       when :high then [:high_priority]
                       when :medium then [:medium_priority] 
                       else [:low_priority]
                       end
        
        SmartFactory.create_for_mountain_simulation(:stance, stance_traits,
                                                   candidacy: candidacy,
                                                   approach: approach)
      end
    end

    # Create realistic ratings with varied patterns
    @race.candidacies.reload.each do |candidacy|
      # Skip if rating already exists for this voter-candidacy combination
      next if Rating.exists?(voter: @voter, candidacy: candidacy)
      
      # Use different rating patterns for more realistic mountain visualization
      rating_type = [:high_variance, :polarized, :moderate].sample
      
      # Ratings should never be reused (each voter rates each candidate once)
      SmartFactory.create_for_mountain_simulation(:rating, [rating_type], 
                                                  candidacy: candidacy, voter: @voter)
    end

    # Create realistic baseline for voter (high reuse - voters often have similar standards)
    SmartFactory.create_for_mountain_simulation(:voter_race_baseline, [:realistic_distribution],
                                                race: @race, voter: @voter)

    redirect_to mountain_path(@race, voter_id: @voter.id), notice: 'Simulation data generated successfully!'
  end

  private

  def render_mountain_editor
    @mountain_data = build_mountain_data
    render Views::Mountains::EditView.new(
      race: @race,
      voter: @voter,
      baseline: @baseline,
      mountain_data: @mountain_data
    )
  end

  def set_race
    @race = Race.with_naming_details.find(params[:id])
  end

  def set_voter
    @voter = if params[:voter_id].present?
               Voter.find(params[:voter_id])
             else
               current_voter || Voter.first
             end

    raise ActiveRecord::RecordNotFound, "No voter available for mountain" unless @voter
  end

  def set_baseline
    @baseline = @race.voter_race_baselines.find_by(voter: @voter)
  end

  def build_mountain_data
    @race.candidacies_for(@voter).active.with_rating_details.map do |candidacy|
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
    Views::Mountains.calculate_label_position(rating)
  end

  def update_baseline
    baseline_value = params[:baseline].presence

    if baseline_value
      baseline_record = VoterRaceBaseline.find_or_initialize_by(voter: @voter, race: @race)
      baseline_record.update!(baseline: normalize_rating(baseline_value))
    else
      @baseline&.destroy
    end
  end

  def update_ratings
    rating_params.each do |candidacy_id, rating_value|
      candidacy = @race.candidacies_for(@voter).find(candidacy_id)
      rating_record = Rating.find_by(voter: @voter, candidacy: candidacy)

      if rating_value.present?
        if rating_record
          rating_record.update!(rating: normalize_rating(rating_value))
        else
          Rating.create!(voter: @voter, candidacy: candidacy, rating: normalize_rating(rating_value))
        end
      else
        rating_record&.destroy
      end
    end
  end

  def rating_params
    params.fetch(:ratings, {}).to_unsafe_h
  end

  def normalize_rating(value)
    value.to_i.clamp(0, 500)
  end

end
