class StatesController < ApplicationController
  before_action :set_state, only: %i[ show edit update destroy ]

  def index
    @pagy, @states = pagy(State.includes(:cities).all)
    render Views::States::IndexView.new(states: @states, pagy: @pagy, notice: notice)
  end

  def show
    render Views::States::ShowView.new(state: @state, notice: notice)
  end

  def new
    @state = State.new
    render Views::States::NewView.new(state: @state)
  end

  def edit
    render Views::States::EditView.new(state: @state)
  end

  def create
    @state = State.new(state_params)

    if @state.save
      redirect_to @state, notice: "State was successfully created."
    else
      render Views::States::NewView.new(state: @state), status: :unprocessable_entity
    end
  end

  def update
    if @state.update(state_params)
      redirect_to @state, notice: "State was successfully updated.", status: :see_other
    else
      render Views::States::EditView.new(state: @state), status: :unprocessable_entity
    end
  end

  def destroy
    @state.destroy!
    redirect_to states_url, notice: "State was successfully destroyed.", status: :see_other
  end

  private

  def set_state
    @state = State.find(params[:id])
  end

  def state_params
    params.require(:state).permit(:name, :code)
  end
end