class YearsController < ApplicationController
  before_action :set_year, only: %i[ show edit update destroy ]

  def index
    @years = Year.all
    render Views::Years::IndexView.new(years: @years, notice: notice)
  end

  def show
    render Views::Years::ShowView.new(year: @year, notice: notice)
  end

  def new
    @year = Year.new
    render Views::Years::NewView.new(year: @year)
  end

  def edit
    render Views::Years::EditView.new(year: @year)
  end

  def create
    @year = Year.new(year_params)

    if @year.save
      redirect_to @year, notice: "Year was successfully created."
    else
      render Views::Years::NewView.new(year: @year), status: :unprocessable_entity
    end
  end

  def update
    if @year.update(year_params)
      redirect_to @year, notice: "Year was successfully updated.", status: :see_other
    else
      render Views::Years::EditView.new(year: @year), status: :unprocessable_entity
    end
  end

  def destroy
    @year.destroy!
    redirect_to years_url, notice: "Year was successfully destroyed.", status: :see_other
  end

  private

  def set_year
    @year = Year.find(params[:id])
  end

  def year_params
    params.require(:year).permit(:year, :is_even_year, :is_presidential_year, :description)
  end
end