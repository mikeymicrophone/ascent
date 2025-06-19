class PositionsController < ApplicationController
  before_action :set_position, only: %i[ show edit update destroy ]

  def index
    @positions = Position.all
    render Views::Positions::IndexView.new(positions: @positions, notice: notice)
  end

  def show
    render Views::Positions::ShowView.new(position: @position, notice: notice)
  end

  def new
    @position = Position.new
    render Views::Positions::NewView.new(position: @position)
  end

  def edit
    render Views::Positions::EditView.new(position: @position)
  end

  def create
    @position = Position.new(position_params)

    if @position.save
      redirect_to @position, notice: "Position was successfully created."
    else
      render Views::Positions::NewView.new(position: @position), status: :unprocessable_entity
    end
  end

  def update
    if @position.update(position_params)
      redirect_to @position, notice: "Position was successfully updated.", status: :see_other
    else
      render Views::Positions::EditView.new(position: @position), status: :unprocessable_entity
    end
  end

  def destroy
    @position.destroy!
    redirect_to positions_url, notice: "Position was successfully destroyed.", status: :see_other
  end

  private

  def set_position
    @position = Position.find(params[:id])
  end

  def position_params
    params.require(:position).permit(:title, :description, :is_executive, :term_length_years)
  end
end