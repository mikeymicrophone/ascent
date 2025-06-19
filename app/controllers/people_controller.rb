class PeopleController < ApplicationController
  before_action :set_person, only: %i[ show edit update destroy ]

  def index
    @people = Person.all
    render Views::People::IndexView.new(people: @people, notice: notice)
  end

  def show
    render Views::People::ShowView.new(person: @person, notice: notice)
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

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:first_name, :last_name, :middle_name, :email, :birth_date, :bio)
  end
end