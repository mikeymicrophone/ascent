# frozen_string_literal: true

class Views::Mountains::PartyEndorsements < Views::Components::Base
  prop :candidacy, Candidacy

  def view_template
    names = @candidacy.endorsements.filter_map do |endorsement|
      endorsement.endorser.name if endorsement.withdrawn_on.nil? && endorsement.endorser.is_a?(Party)
    end.uniq
    return if names.empty?

    span(class: "party-endorsements") { names.join("; ") }
  end
end
