# frozen_string_literal: true

class MapsController < ApplicationController
  def show
    authorize! Jurisdiction, to: :index?
    render Views::Maps::ShowView.new(explorer: explorer)
  end

  def features
    authorize! Jurisdiction, to: :index?
    render json: explorer.feature_collection
  end

  private

  def explorer
    @explorer ||= begin
      state = MapExplorer.new.states.find(params.expect(:state_id)) if params[:state_id].present?
      MapExplorer.new(state: state, layer: params[:layer], layers: params[:layers])
    end
  end
end
