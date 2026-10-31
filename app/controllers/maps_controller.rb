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
      layer = params.fetch(:layer, "counties")
      raise ActiveRecord::RecordNotFound unless MapExplorer::LAYERS.key?(layer)

      state = MapExplorer.new.states.find(params.expect(:state_id)) if params[:state_id].present?
      MapExplorer.new(state: state, layer: layer)
    end
  end
end
