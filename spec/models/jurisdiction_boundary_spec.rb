require 'rails_helper'

RSpec.describe JurisdictionBoundary, type: :model do
  let(:shape) do
    RGeo::Geos.factory(srid: 4326).parse_wkt(
      'MULTIPOLYGON(((-74 42,-73 42,-73 43,-74 43,-74 42),(-73.8 42.2,-73.8 42.4,-73.6 42.4,-73.6 42.2,-73.8 42.2)),((-72 42,-71 42,-71 43,-72 43,-72 42)))'
    )
  end

  it 'uses the historical boundary effective on the requested date' do
    jurisdiction = create(:jurisdiction)
    other_shape = RGeo::Geos.factory(srid: 4326).parse_wkt('MULTIPOLYGON(((0 0,1 0,1 1,0 1,0 0)))')
    jurisdiction.boundaries.create!(geometry: shape, valid_from: Date.new(2020, 1, 1), valid_until: Date.new(2030, 1, 1))
    jurisdiction.boundaries.create!(geometry: other_shape, valid_from: Date.new(2030, 1, 1))

    expect(Jurisdiction.covering(-73.5, 42.5, on: Date.new(2029, 12, 31))).to contain_exactly(jurisdiction)
    expect(Jurisdiction.covering(-73.5, 42.5, on: Date.new(2030, 1, 1))).to be_empty
    expect(Jurisdiction.covering(0.5, 0.5, on: Date.new(2030, 1, 1))).to contain_exactly(jurisdiction)
  end

  it 'respects holes, disconnected areas, boundary points, and overlapping jurisdictions' do
    jurisdictions = create_list(:jurisdiction, 2)
    jurisdictions.each { |jurisdiction| jurisdiction.boundaries.create!(geometry: shape, valid_from: Date.new(2020, 1, 1)) }

    expect(Jurisdiction.covering(-73.7, 42.3)).to be_empty
    expect(Jurisdiction.covering(-71.5, 42.5)).to match_array(jurisdictions)
    expect(Jurisdiction.covering(-74, 42.5)).to match_array(jurisdictions)
  end

  it 'rejects overlapping periods and invalid or empty boundary geometry' do
    jurisdiction = create(:jurisdiction)
    jurisdiction.boundaries.create!(geometry: shape, valid_from: Date.new(2020, 1, 1))
    overlap = jurisdiction.boundaries.build(geometry: shape, valid_from: Date.new(2021, 1, 1))
    expect(overlap).not_to be_valid
    expect(overlap.errors[:valid_from]).to be_present

    empty = described_class.new(jurisdiction: create(:jurisdiction), valid_from: Date.new(2020, 1, 1),
      geometry: RGeo::Geos.factory(srid: 4326).parse_wkt('MULTIPOLYGON EMPTY'))
    expect(empty).not_to be_valid
    expect(empty.errors[:geometry]).to be_present
  end
end
