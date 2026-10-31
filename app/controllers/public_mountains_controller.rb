class PublicMountainsController < ApplicationController
  skip_before_action :authorize_action_policy_resource!

  def show
    @public_mountain = PublicMountain.find(params[:id])
    authorize! @public_mountain
    response.headers["Cache-Control"] = "no-store"

    respond_to do |format|
      format.html { render Views::PublicMountains::ShowView.new(public_mountain: @public_mountain) }
      format.png { send_data @public_mountain.preview_png, type: "image/png", disposition: "inline", filename: "mountain.png" }
    end
  end
end
