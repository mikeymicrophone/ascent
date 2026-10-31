require "open3"

class MountainPreview
  CANDIDATE_LIMIT = 10
  class Error < StandardError; end

  def initialize(snapshot)
    @snapshot = snapshot
  end

  def png
    svg = Views::PublicMountains::Preview.new(snapshot: @snapshot).call
    bytes, error, status = Open3.capture3(RbConfig.ruby, Rails.root.join("script/render_mountain_preview").to_s,
      stdin_data: svg, binmode: true)
    raise Error, error unless status.success?

    bytes
  end
end
