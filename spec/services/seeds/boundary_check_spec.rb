require "rails_helper"

# After an import, the check places a point inside every county and a set of landmarks, and reports any
# that find no town, a town in another state, a missing or doubled district, or the wrong town. Here
# Alder County spans -77..-74 by 41..44 and Port Merritt sits in its middle; its districts are squares.
RSpec.describe Seeds::BoundaryCheck do
  include_context "Port Merritt ballot"

  let(:factory) { RGeo::Geos.factory(srid: 4326) }
  let(:senate_9) { create(:jurisdiction, jurisdictionable: create(:district, name: "Calder State Senate District 9", kind: "state senate district"), parent: state) }
  let(:in_port_merritt) { described_class::Landmark.new("Port Merritt harbor", 42.5, -75.5, "Port Merritt") }

  def boundary!(jurisdiction, west, south, size)
    corners = [ [ west, south ], [ west + size, south ], [ west + size, south + size ], [ west, south + size ], [ west, south ] ]
    JurisdictionBoundary.create!(jurisdiction: jurisdiction, valid_from: Date.new(2024, 1, 1),
      geometry: factory.multi_polygon([ factory.polygon(factory.linear_ring(corners.map { factory.point(*it) })) ]))
  end

  before do
    state.jurisdictionable.update!(code: "CL")
    boundary!(state, -80, 40, 8)
    boundary!(alder_county, -77, 41, 3)
    boundary!(port_merritt, -76, 42, 1)
    boundary!(congressional_7, -78, 40, 5)
    boundary!(assembly_52, -78, 40, 5)
  end

  it "passes when every county finds its town and one district per chamber, and each landmark its town" do
    boundary!(senate_9, -78, 40, 5)

    check = described_class.new(landmarks: [ in_port_merritt ]).run

    expect(check).to be_ok
    expect(check.counties_checked).to eq(1)
    expect(check.town_kinds).to eq("Municipality" => 1)
  end

  it "reports a missing district, two districts of one chamber, and a landmark in the wrong town" do
    create(:jurisdiction, jurisdictionable: create(:district, name: "Calder Assembly District 53", kind: "assembly district"), parent: state)
      .then { boundary!(it, -76, 42, 1) }
    stray = described_class::Landmark.new("Alder countryside", 41.2, -76.8, "Port Merritt")

    check = described_class.new(landmarks: [ in_port_merritt, stray ]).run

    expect(check).not_to be_ok
    expect(check.problems).to include(
      state_senate_districts: [ "Alder County, CL is in 0, expected 1" ],
      state_house_districts: [ "Alder County, CL is in 2, expected 1" ],
      landmarks: [ "Alder countryside found Alder County, expected Port Merritt" ])
  end

  it "tries other points in a county whose first point lies in water, and reports it only if none is on land" do
    boundary!(senate_9, -77, 41, 1.4)
    JurisdictionBoundary.where(jurisdiction: [ congressional_7, assembly_52 ]).delete_all
    boundary!(congressional_7, -77, 41, 1.4)
    boundary!(assembly_52, -77, 41, 1.4)

    check = described_class.new(landmarks: []).run

    expect(check.in_water).to eq([ "Alder County, CL" ])
    expect(check).to be_ok

    JurisdictionBoundary.where(jurisdiction: senate_9).delete_all
    expect(described_class.new(landmarks: []).run.problems).to include(:state_senate_districts)
  end
end
