class PoliciesController < ApplicationController
  before_action :set_policy, only: %i[ show edit update destroy ]

  def index
    policies = Policy.includes(:governing_body, approach: :issue).by_governing_body(params[:governing_body_id]).order(enacted_date: :desc, title: :asc)
    policies = policies.titled_like(filters["q"]) if filters["q"].present?
    policies = policies.where(status: filters["status"]) if filters["status"].present?
    @pagy, @policies = pagy(policies)
    render Views::Policies::IndexView.new(policies: @policies, pagy: @pagy, parent: filtering_governing_body, filters: filters)
  end

  def show
    render Views::Policies::ShowView.new(policy: @policy)
  end

  def new
    @policy = Policy.new
    render Views::Policies::NewView.new(policy: @policy)
  end

  def edit
    render Views::Policies::EditView.new(policy: @policy)
  end

  def create
    @policy = Policy.new(policy_params)

    if @policy.save
      redirect_to @policy, notice: "Policy was successfully created."
    else
      render Views::Policies::NewView.new(policy: @policy), status: :unprocessable_entity
    end
  end

  def update
    if @policy.update(policy_params)
      redirect_to @policy, notice: "Policy was successfully updated.", status: :see_other
    else
      render Views::Policies::EditView.new(policy: @policy), status: :unprocessable_entity
    end
  end

  def destroy
    @policy.destroy!
    redirect_to policies_url, notice: "Policy was successfully destroyed.", status: :see_other
  end

  private

  def filters
    @filters ||= params.permit(:q, :status).to_h
  end

  def filtering_governing_body
    GoverningBody.find(params[:governing_body_id]) if params[:governing_body_id]
  end


  def set_policy
    @policy = Policy.find(params[:id])
  end

  def policy_params
    params.require(:policy).permit(:title, :description, :status, :enacted_date, :expiration_date)
  end
end
