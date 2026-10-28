class PeopleController < ApplicationController
  before_action :set_person, only: %i[ show edit update destroy ]

  def index
    people_scope = Person.includes(candidacies: [ :ballot_lines, { race: [ :election, { office: [ :position, { jurisdiction: :jurisdictionable } ] } ] } ])
      .visible_to(current_voter).order(:last_name, :first_name, :id)
    people_scope = people_scope.named_like(filters["q"]) if filters["q"].present?
    people_scope = people_scope.ran_in(Race.in_state(State.includes(:jurisdiction).find(filters["state_id"]))) if filters["state_id"].present?
    @pagy, @people = pagy(people_scope)
    render Views::People::IndexView.new(people: @people, pagy: @pagy, filters: filters, states: State.order(:name))
  end

  def show
    render Views::People::ShowView.new(person: @person)
  end

  def new
    @person = Person.new
    render Views::People::NewView.new(person: @person)
  end

  def edit
    render Views::People::EditView.new(person: @person)
  end

  def create
    @person = Person.new(person_params)

    if @person.save
      redirect_to @person, notice: "Person was successfully created."
    else
      render Views::People::NewView.new(person: @person), status: :unprocessable_entity
    end
  end

  def update
    if @person.update(person_params)
      redirect_to @person, notice: "Person was successfully updated.", status: :see_other
    else
      render Views::People::EditView.new(person: @person), status: :unprocessable_entity
    end
  end

  def destroy
    @person.destroy!
    redirect_to people_url, notice: "Person was successfully destroyed.", status: :see_other
  end

  private

  def filters
    @filters ||= params.permit(:q, :state_id).to_h
  end

  def set_person
    @person = Person.with_candidacy_details.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:first_name, :last_name, :middle_name, :email, :birth_date, :bio,
      :portrait_url, :portrait_credit, :portrait_source_url)
  end
end
