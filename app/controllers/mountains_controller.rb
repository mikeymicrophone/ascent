class MountainsController < ApplicationController
  before_action :set_race, except: :index
  before_action :set_voter, except: :index
  before_action :set_baseline, only: [ :show, :edit, :update ]
  before_action :authorize_mountain!, except: :index
  # Simulated candidates and ratings never mix with a real race's mountains.
  before_action :require_mock_race, only: :simulate

  def index
    authorize! :mountain
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
    mountain.publish!(ratings: rating_params, baseline: params[:baseline].presence)

    # Stay on the editable mountain so ratings remain draggable after save.
    redirect_to mountain_path(@race, voter_id: @voter.id), notice: "Mountain ratings updated."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    redirect_to mountain_path(@race, voter_id: @voter.id),
                alert: "Could not save mountain ratings: #{e.message}"
  end

  # Keeps unsaved edits on the server as the voter drags, answering with the mountain as it now stands.
  def draft
    render json: mountain.revise_draft!(ratings: rating_params, baseline: params[:baseline])
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end

  def discard
    mountain.discard!
    respond_with_mountain notice: "Changes discarded."
  end

  def save
    mountain.save!
    respond_with_mountain notice: "Mountain saved."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.html { redirect_to mountain_path(@race, voter_id: @voter.id), alert: "Could not save your mountain: #{e.message}" }
      format.json { render json: { errors: [ e.message ] }, status: :unprocessable_content }
    end
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
    candidate_types = [ :young_candidate, :experienced_politician, :business_leader,
                      :community_activist, :educator, :veteran ]

    candidate_count.times do
      # Mix of candidate types for realistic diversity with intelligent reuse
      person_type = candidate_types.sample
      candidacy_traits = [ :democrat, :republican, :independent, :green ].sample

      # Use SmartFactory for people (low reuse for diversity)
      person = SmartFactory.create_for_mountain_simulation(:person, [ person_type ])

      # Use SmartFactory for candidacies (very low reuse - each should be unique)
      SmartFactory.create_for_mountain_simulation(:candidacy, [ candidacy_traits ],
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
        priority_level = [ :high, :medium, :low ].sample
        stance_traits = case priority_level
        when :high then [ :high_priority ]
        when :medium then [ :medium_priority ]
        else [ :low_priority ]
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
      rating_type = [ :high_variance, :polarized, :moderate ].sample

      # Ratings should never be reused (each voter rates each candidate once)
      SmartFactory.create_for_mountain_simulation(:rating, [ rating_type ],
                                                  candidacy: candidacy, voter: @voter)
    end

    # Create realistic baseline for voter (high reuse - voters often have similar standards)
    SmartFactory.create_for_mountain_simulation(:voter_race_baseline, [ :realistic_distribution ],
                                                race: @race, voter: @voter)

    redirect_to mountain_path(@race, voter_id: @voter.id), notice: "Simulation data generated successfully!"
  end

  private

  def mountain
    @mountain ||= Mountain.new(voter: @voter, race: @race)
  end

  def respond_with_mountain(notice:)
    respond_to do |format|
      format.html { redirect_to mountain_path(@race, voter_id: @voter.id), notice: notice }
      format.json { render json: mountain }
    end
  end

  def require_mock_race
    redirect_to mountain_path(@race, voter_id: @voter.id), alert: "Simulated data can only go in a mock election." unless @race.mock?
  end

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
    @voter = params[:voter_id].present? ? Voter.find(params[:voter_id]) : current_voter
  end

  # Without a signed-in voter this fails, and the visitor is sent to sign in.
  def authorize_mountain!
    authorize! @voter, with: MountainPolicy
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

  def rating_params
    params.fetch(:ratings, {}).to_unsafe_h
  end
end
