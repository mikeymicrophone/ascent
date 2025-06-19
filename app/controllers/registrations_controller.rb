class RegistrationsController < ApplicationController
  before_action :set_registration, only: %i[ show edit update destroy ]

  def index
    @registrations = Registration.all
    render Views::Registrations::IndexView.new(registrations: @registrations, notice: notice)
  end

  def show
    render Views::Registrations::ShowView.new(registration: @registration, notice: notice)
  end

  def new
    @registration = Registration.new
    render Views::Registrations::NewView.new(registration: @registration)
  end

  def edit
    render Views::Registrations::EditView.new(registration: @registration)
  end

  def create
    @registration = Registration.new(registration_params)

    if @registration.save
      redirect_to @registration, notice: "Registration was successfully created."
    else
      render Views::Registrations::NewView.new(registration: @registration), status: :unprocessable_entity
    end
  end

  def update
    if @registration.update(registration_params)
      redirect_to @registration, notice: "Registration was successfully updated.", status: :see_other
    else
      render Views::Registrations::EditView.new(registration: @registration), status: :unprocessable_entity
    end
  end

  def destroy
    @registration.destroy!
    redirect_to registrations_url, notice: "Registration was successfully destroyed.", status: :see_other
  end

  private

  def set_registration
    @registration = Registration.find(params[:id])
  end

  def registration_params
    params.require(:registration).permit(:registered_at, :status, :notes)
  end
end