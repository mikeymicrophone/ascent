class OfficialCodesController < ApplicationController
  before_action :set_official_code, only: %i[ show edit update destroy ]

  def index
    @pagy, @official_codes = pagy(OfficialCode.all)
    render Views::OfficialCodes::IndexView.new(official_codes: @official_codes, pagy: @pagy, notice: notice)
  end

  def show
    render Views::OfficialCodes::ShowView.new(official_code: @official_code, notice: notice)
  end

  def new
    @official_code = OfficialCode.new
    render Views::OfficialCodes::NewView.new(official_code: @official_code)
  end

  def edit
    render Views::OfficialCodes::EditView.new(official_code: @official_code)
  end

  def create
    @official_code = OfficialCode.new(official_code_params)

    if @official_code.save
      redirect_to @official_code, notice: "Official code was successfully created."
    else
      render Views::OfficialCodes::NewView.new(official_code: @official_code), status: :unprocessable_entity
    end
  end

  def update
    if @official_code.update(official_code_params)
      redirect_to @official_code, notice: "Official code was successfully updated.", status: :see_other
    else
      render Views::OfficialCodes::EditView.new(official_code: @official_code), status: :unprocessable_entity
    end
  end

  def destroy
    @official_code.destroy!
    redirect_to official_codes_url, notice: "Official code was successfully destroyed.", status: :see_other
  end

  private

  def set_official_code
    @official_code = OfficialCode.find(params[:id])
  end

  def official_code_params
    params.require(:official_code).permit(:code_number, :title, :full_text, :summary, :enforcement_mechanism, :penalty_structure, :effective_date, :status)
  end
end