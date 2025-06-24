class GoverningBodiesController < ApplicationController
  before_action :set_governing_body, only: %i[ show edit update destroy ]

  def index
    @pagy, @governing_bodies = pagy(GoverningBody.all)
    render Views::GoverningBodies::IndexView.new(governing_bodies: @governing_bodies, pagy: @pagy, notice: notice)
  end

  def show
    render Views::GoverningBodies::ShowView.new(governing_body: @governing_body, notice: notice)
  end

  def new
    @governing_body = GoverningBody.new
    render Views::GoverningBodies::NewView.new(governing_body: @governing_body)
  end

  def edit
    render Views::GoverningBodies::EditView.new(governing_body: @governing_body)
  end

  def create
    @governing_body = GoverningBody.new(governing_body_params)

    if @governing_body.save
      redirect_to @governing_body, notice: "Governing body was successfully created."
    else
      render Views::GoverningBodies::NewView.new(governing_body: @governing_body), status: :unprocessable_entity
    end
  end

  def update
    if @governing_body.update(governing_body_params)
      redirect_to @governing_body, notice: "Governing body was successfully updated.", status: :see_other
    else
      render Views::GoverningBodies::EditView.new(governing_body: @governing_body), status: :unprocessable_entity
    end
  end

  def destroy
    @governing_body.destroy!
    redirect_to governing_bodies_url, notice: "Governing body was successfully destroyed.", status: :see_other
  end

  private

  def set_governing_body
    @governing_body = GoverningBody.find(params[:id])
  end

  def governing_body_params
    params.require(:governing_body).permit(:name, :jurisdiction_type, :jurisdiction_id, :description, :meeting_schedule, :is_active, :established_date)
  end
end