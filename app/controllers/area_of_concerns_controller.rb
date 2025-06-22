class AreaOfConcernsController < ApplicationController
  before_action :set_area_of_concern, only: %i[ show edit update destroy ]

  def index
    @pagy, @area_of_concerns = pagy(AreaOfConcern.all)
    render Views::AreaOfConcerns::IndexView.new(area_of_concerns: @area_of_concerns, pagy: @pagy, notice: notice)
  end

  def show
    render Views::AreaOfConcerns::ShowView.new(area_of_concern: @area_of_concern, notice: notice)
  end

  def new
    @area_of_concern = AreaOfConcern.new
    render Views::AreaOfConcerns::NewView.new(area_of_concern: @area_of_concern)
  end

  def edit
    render Views::AreaOfConcerns::EditView.new(area_of_concern: @area_of_concern)
  end

  def create
    @area_of_concern = AreaOfConcern.new(area_of_concern_params)

    if @area_of_concern.save
      redirect_to @area_of_concern, notice: "Area of concern was successfully created."
    else
      render Views::AreaOfConcerns::NewView.new(area_of_concern: @area_of_concern), status: :unprocessable_entity
    end
  end

  def update
    if @area_of_concern.update(area_of_concern_params)
      redirect_to @area_of_concern, notice: "Area of concern was successfully updated.", status: :see_other
    else
      render Views::AreaOfConcerns::EditView.new(area_of_concern: @area_of_concern), status: :unprocessable_entity
    end
  end

  def destroy
    @area_of_concern.destroy!
    redirect_to area_of_concerns_url, notice: "Area of concern was successfully destroyed.", status: :see_other
  end

  private

  def set_area_of_concern
    @area_of_concern = AreaOfConcern.find(params[:id])
  end

  def area_of_concern_params
    params.require(:area_of_concern).permit(:name, :description, :policy_domain, :regulatory_scope)
  end
end