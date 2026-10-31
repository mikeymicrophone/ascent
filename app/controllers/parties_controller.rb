class PartiesController < OrganizationsController
  private

  def directory_model
    Party
  end

  def filters
    @filters ||= params.permit(:q, :state_id).to_h
  end
end
