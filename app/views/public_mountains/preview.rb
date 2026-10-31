class Views::PublicMountains::Preview < Phlex::SVG
  def initialize(snapshot:)
    @snapshot = snapshot
    @candidates = snapshot.fetch("candidates").each_with_index
      .sort_by { |candidate, index| [ -(candidate["rating"] || -1), index ] }
      .first(MountainPreview::CANDIDATE_LIMIT).sort_by(&:last).map(&:first)
  end

  def view_template
    svg(xmlns: "http://www.w3.org/2000/svg", width: 1200, height: 630, viewBox: "0 0 1200 630", role: "img") do
      rect(width: 1200, height: 630, fill: "#F2F4EE")
      label(48, 48, "ASCENT · APPROVAL VOTING", size: 18)
      svg(x: 988, y: 6, width: 44, height: 44, viewBox: "0 0 40 40") do
        path(d: "M1 34 L11 19 L21 34 Z", fill: "#57645C")
        path(d: "M7 34 L22 6 L37 34 Z", fill: "#15201B")
        path(d: "M16.64 16 L22 6 L27.36 16 Z", fill: "#C5EE3F")
        path(d: "M2 16 H38", fill: "none", stroke: "#E05A12", stroke_width: 2.5, stroke_linecap: "round")
      end
      text(x: 1152, y: 40, fill: "#15201B", font_family: "DejaVu Sans, sans-serif", font_size: 32,
        font_weight: "bold", text_anchor: "end") { "Ascent" }
      label(1152, 64, "https://ascent.ing", size: 16, anchor: "end")
      label(48, 98, "#{shorten(@snapshot.fetch("voter_name"), 42)}'s mountain", size: 34)
      label(48, 134, shorten(@snapshot.fetch("race_name"), 78), size: 23)
      label(48, 165, shorten(@snapshot.fetch("election_name"), 95), size: 18)
      chart
      label(48, 605, "Lime = approved · Dashed = off the ballot · Ratings 0–500", size: 17)
      if @snapshot.fetch("candidates").length > @candidates.length
        label(1152, 605, "Top #{@candidates.length} shown · Full mountain at the link", size: 17, anchor: "end")
      end
    end
  end

  private

  def chart
    ground = 480
    top = 225
    step = 1060.0 / @candidates.length
    baseline_y = ground - @snapshot.fetch("baseline") * (ground - top) / 500.0
    points = [ [ 70, ground ] ] + @candidates.each_with_index.map do |candidate, index|
      [ 70 + step * (index + 0.5), ground - candidate["rating"].to_i * (ground - top) / 500.0 ]
    end + [ [ 1130, ground ] ]
    shape = points.map { it.join(",") }.join(" ")
    defs do
      clipPath(id: "approved") { rect(x: 70, y: top, width: 1060, height: baseline_y - top) }
    end
    polygon(points: shape, fill: "#CDD5C8", stroke: "#56635B", stroke_width: 2)
    polygon(points: shape, fill: "#C5EE3F", clip_path: "url(#approved)")
    line(x1: 70, x2: 1130, y1: baseline_y, y2: baseline_y, stroke: "#E05A12", stroke_width: 3)
    label(70, 197, "Baseline: #{@snapshot.fetch("baseline")}", size: 18)
    @candidates.each_with_index do |candidate, index|
      x, y = points[index + 1]
      rating = candidate["rating"]
      circle(cx: x, cy: y, r: 6, fill: rating && rating > @snapshot.fetch("baseline") ? "#C5EE3F" : "#FFFFFF",
        stroke: "#15201B", stroke_width: 2, stroke_dasharray: candidate["off_ballot"] ? "3 2" : "none")
      label_y = [ y - 16, top - 5 ].max
      label_y = baseline_y - 10 if (label_y - baseline_y).between?(0, 18)
      label(x, label_y, rating.nil? ? "Unrated" : rating.to_s, size: 16, anchor: "middle")
      words = candidate.fetch("name").split
      name_size = @candidates.length > 6 ? 13 : 16
      label(x, 510, shorten(words[0...-1].join(" ").presence || words.last, 14), size: name_size, anchor: "middle")
      label(x, 532, shorten(words.length > 1 ? words.last : "", 14), size: name_size, anchor: "middle")
      label(x, 553, "Off ballot", size: 13, anchor: "middle") if candidate["off_ballot"]
    end
  end

  def label(x, y, value, size:, anchor: "start")
    text(x: x, y: y, fill: "#15201B", font_family: "DejaVu Sans, sans-serif", font_size: size, text_anchor: anchor) { value }
  end

  def shorten(value, limit)
    value.length > limit ? "#{value.first(limit - 1)}…" : value
  end
end
