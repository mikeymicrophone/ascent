class ApproachesController < ApplicationController
  before_action :set_approach, only: %i[ show edit update destroy ]

  # GET /approaches or /approaches.json
  def index
    @approaches = Approach.all
    render Views::Approaches::IndexView.new(approaches: @approaches, notice: notice)
  end

  # GET /approaches/1 or /approaches/1.json
  def show
    render Views::Approaches::ShowView.new(approach: @approach, notice: notice)
  end

  # GET /approaches/new
  def new
    @approach = Approach.new
    render Views::Approaches::NewView.new(approach: @approach)
  end

  # GET /approaches/1/edit
  def edit
    render Views::Approaches::EditView.new(approach: @approach)
  end

  # POST /approaches or /approaches.json
  def create
    @approach = Approach.new(approach_params)

    respond_to do |format|
      if @approach.save
        format.html { redirect_to @approach, notice: "Approach was successfully created." }
        format.json { render :show, status: :created, location: @approach }
      else
        format.html { render Views::Approaches::NewView.new(approach: @approach), status: :unprocessable_entity }
        format.json { render json: @approach.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /approaches/1 or /approaches/1.json
  def update
    respond_to do |format|
      if @approach.update(approach_params)
        format.html { redirect_to @approach, notice: "Approach was successfully updated." }
        format.json { render :show, status: :ok, location: @approach }
      else
        format.html { render Views::Approaches::EditView.new(approach: @approach), status: :unprocessable_entity }
        format.json { render json: @approach.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /approaches/1 or /approaches/1.json
  def destroy
    @approach.destroy!

    respond_to do |format|
      format.html { redirect_to approaches_path, status: :see_other, notice: "Approach was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_approach
      @approach = Approach.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def approach_params
      params.expect(approach: [ :title, :description, :issue_id ])
    end
end
