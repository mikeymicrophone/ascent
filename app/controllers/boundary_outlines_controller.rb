# frozen_string_literal: true

# Public SVG and PNG downloads of a single jurisdiction outline. Metadata only; no voter data.
class BoundaryOutlinesController < ApplicationController
  FORMATS = {
    "svg" => "image/svg+xml",
    "png" => "image/png"
  }.freeze

  def show
    authorize! Jurisdiction, to: :index?
    place = find_place
    outline = BoundaryOutline.for(place, detail: detail)
    raise ActiveRecord::RecordNotFound if outline.missing?

    format = params.fetch(:format, "svg")
    raise ActionController::BadRequest unless FORMATS.key?(format)

    expires_in 1.hour, public: true
    if format == "png"
      send_data outline.png, type: FORMATS.fetch(format), disposition: "inline", filename: "#{filename(place)}.png"
    else
      send_data outline.svg, type: FORMATS.fetch(format), disposition: "inline", filename: "#{filename(place)}.svg"
    end
  end

  private

  def find_place
    type = params.expect(:place_type)
    raise ActiveRecord::RecordNotFound unless BoundaryOutline::PLACE_TYPES.include?(type)

    type.constantize.find(params.expect(:place_id))
  end

  def detail
    value = params.fetch(:detail, "panel").to_sym
    raise ActionController::BadRequest unless BoundaryOutline::DETAIL.key?(value)

    value
  end

  def filename(place)
    "#{place.model_name.singular}-#{place.id}-outline"
  end
end
