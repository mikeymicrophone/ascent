class ElectionsController < ApplicationController
  before_action :set_election, only: %i[ show edit update destroy ]

  def index
    elections = filtered(Election.listing(listing_filters[:tab]))
    @pagy, @elections = pagy(elections.includes(races: { office: :position }, jurisdiction: :jurisdictionable))
    render Views::Elections::IndexView.new(
      elections: @elections, pagy: @pagy, filters: listing_filters,
      tab_counts: Election::LISTING_TABS.index_with { filtered(Election.listing(it)).count },
      day_counts: elections.where(election_date: @elections.map(&:election_date)).reorder(nil).group(:election_date).count
    )
  end

  def show
    render Views::Elections::ShowView.new(election: @election)
  end

  def new
    @election = Election.new
    render Views::Elections::NewView.new(election: @election)
  end

  def edit
    render Views::Elections::EditView.new(election: @election)
  end

  def create
    @election = Election.new(election_params)

    if @election.save
      redirect_to @election, notice: "Election was successfully created."
    else
      render Views::Elections::NewView.new(election: @election), status: :unprocessable_entity
    end
  end

  def update
    if @election.update(election_params)
      redirect_to @election, notice: "Election was successfully updated.", status: :see_other
    else
      render Views::Elections::EditView.new(election: @election), status: :unprocessable_entity
    end
  end

  def destroy
    @election.destroy!
    redirect_to elections_url, notice: "Election was successfully destroyed.", status: :see_other
  end

  private

  # The list's tab, kind chip, search and "where I live" toggle, cleaned of anything unknown.
  def listing_filters
    @listing_filters ||= {
      tab: Election::LISTING_TABS.include?(params[:tab]) ? params[:tab] : "upcoming",
      kind: (params[:kind] if Election::KIND_GROUPS.key?(params[:kind])),
      q: params[:q].to_s.strip.presence,
      near: params[:near] == "1" && current_voter&.current_residence.present?
    }
  end

  def filtered(elections)
    elections = elections.of_kind(listing_filters[:kind]) if listing_filters[:kind]
    elections = elections.matching(listing_filters[:q]) if listing_filters[:q]
    elections = elections.in_jurisdictions(current_voter.current_residence.ballot_jurisdictions) if listing_filters[:near]
    elections
  end

  def set_election
    @election = Election.with_full_details.find(params[:id])
  end

  def election_params
    params.require(:election).permit(:jurisdiction_id, :year_id, :name, :kind, :election_date,
                                     :early_voting_starts_on, :early_voting_ends_on,
                                     :status, :description, :is_mock, :is_historical)
  end
end
