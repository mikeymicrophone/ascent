class ResidencesController < ApplicationController
  before_action :set_residence, only: %i[ show edit update destroy ]

  def index
    @residences = Residence.all
    render Views::Residences::IndexView.new(residences: @residences, notice: notice)
  end

  def show
    render Views::Residences::ShowView.new(residence: @residence, notice: notice)
  end

  def new
    @residence = Residence.new
    render Views::Residences::NewView.new(residence: @residence)
  end

  def edit
    render Views::Residences::EditView.new(residence: @residence)
  end

  def create
    @residence = Residence.new(residence_params)

    if @residence.save
      redirect_to @residence, notice: "Residence was successfully created."
    else
      render Views::Residences::NewView.new(residence: @residence), status: :unprocessable_entity
    end
  end

  def update
    if @residence.update(residence_params)
      redirect_to @residence, notice: "Residence was successfully updated.", status: :see_other
    else
      render Views::Residences::EditView.new(residence: @residence), status: :unprocessable_entity
    end
  end

  def destroy
    @residence.destroy!
    redirect_to residences_url, notice: "Residence was successfully destroyed.", status: :see_other
  end

  private

  def set_residence
    @residence = Residence.find(params[:id])
  end

  def residence_params
    params.require(:residence).permit(:registered_at, :status, :notes)
  end
end