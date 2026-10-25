# frozen_string_literal: true

module Views
  module Pages
    extend Phlex::Kit

    private

    def metric_label(metric_key)
      {
        active_elections: "Active elections",
        offices: "Offices modeled",
        topics: "Topics tracked",
        issues: "Issues connected"
      }.fetch(metric_key)
    end

    def race_context(race)
      [ race.office.position.title, race.office.jurisdiction.name ].compact.join(" in ")
    end
  end
end
