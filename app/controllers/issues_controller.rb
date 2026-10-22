class IssuesController < ApplicationController
  before_action :set_issue, only: %i[ show edit update destroy ]

  # GET /issues or /issues.json
  def index
    @pagy, @issues = pagy(Issue.includes(:topic).by_topic(params[:topic_id]).visible_to(current_voter))
    render Views::Issues::IndexView.new(issues: @issues, pagy: @pagy, parent: filtering_topic)
  end

  # GET /issues/1 or /issues/1.json
  def show
    render Views::Issues::ShowView.new(issue: @issue)
  end

  # GET /issues/new
  def new
    @issue = Issue.new
    render Views::Issues::NewView.new(issue: @issue)
  end

  # GET /issues/1/edit
  def edit
    render Views::Issues::EditView.new(issue: @issue)
  end

  # POST /issues or /issues.json
  def create
    @issue = Issue.new(issue_params)

    respond_to do |format|
      if @issue.save
        format.html { redirect_to @issue, notice: "Issue was successfully created." }
        format.json { render :show, status: :created, location: @issue }
      else
        format.html { render Views::Issues::NewView.new(issue: @issue), status: :unprocessable_entity }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /issues/1 or /issues/1.json
  def update
    respond_to do |format|
      if @issue.update(issue_params)
        format.html { redirect_to @issue, notice: "Issue was successfully updated." }
        format.json { render :show, status: :ok, location: @issue }
      else
        format.html { render Views::Issues::EditView.new(issue: @issue), status: :unprocessable_entity }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1 or /issues/1.json
  def destroy
    @issue.destroy!

    respond_to do |format|
      format.html { redirect_to issues_path, status: :see_other, notice: "Issue was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def filtering_topic
      Topic.find(params[:topic_id]) if params[:topic_id]
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def issue_params
      params.expect(issue: [ :title, :description, :topic_id ])
    end
end
