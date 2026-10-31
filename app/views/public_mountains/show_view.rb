class Views::PublicMountains::ShowView < Views::ApplicationView
  prop :public_mountain, PublicMountain

  def view_template
    section(class: "public-mountain") do
      h1(class: "display-title") { @public_mountain.title }
      p { @public_mountain.description }
      img(src: public_mountain_path(@public_mountain, format: :png, v: @public_mountain.updated_at.to_f),
        alt: @public_mountain.description, width: 1200, height: 630, class: "public-mountain-preview")
      table(class: "public-mountain-ratings") do
        caption { "Saved ratings · Lime peaks above the baseline are approved" }
        thead { tr { th { "Candidate" }; th { "Rating" }; th { "Approval" } } }
        tbody do
          @public_mountain.snapshot.fetch("candidates").each do |candidate|
            rating = candidate["rating"]
            tr do
              td { "#{candidate.fetch("name")}#{" (off the ballot)" if candidate["off_ballot"]}" }
              td { rating.nil? ? "Unrated" : rating.to_s }
              td { rating && rating > @public_mountain.snapshot.fetch("baseline") ? "Approved" : "Not approved" }
            end
          end
        end
      end
      link_to "View race", race_path(@public_mountain.race), class: "pill-button pill-button-outline"
    end
  end
end
