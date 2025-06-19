class CountriesController < ApplicationController
  before_action :set_country, only: %i[ show edit update destroy ]

  def index
    countries = Country.all
    render Views::Countries::IndexView.new(countries: countries, notice: notice)
  end

  def show
    render Views::Countries::ShowView.new(country: @country, notice: notice)
  end

  def new
    country = Country.new
    render Views::Countries::NewView.new(country: country)
  end

  def edit
    render Views::Countries::EditView.new(country: @country)
  end

  def create
    country = Country.new(country_params)

    if country.save
      redirect_to country, notice: "Country was successfully created."
    else
      render Views::Countries::NewView.new(country: country), status: :unprocessable_entity
    end
  end

  def update
    if @country.update(country_params)
      redirect_to @country, notice: "Country was successfully updated.", status: :see_other
    else
      render Views::Countries::EditView.new(country: @country), status: :unprocessable_entity
    end
  end

  def destroy
    @country.destroy!
    redirect_to countries_url, notice: "Country was successfully destroyed.", status: :see_other
  end

  private

  def set_country
    @country = Country.find(params[:id])
  end

  def country_params
    params.require(:country).permit(:name, :code, :description)
  end
end