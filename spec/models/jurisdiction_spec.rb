require 'rails_helper'

RSpec.describe Jurisdiction, type: :model do
  it 'rejects a parent that would create an indirect cycle' do
    country = create(:jurisdiction, :country)
    state = create(:jurisdiction, :state, parent: country)
    municipality = create(:jurisdiction, parent: state)
    country.parent = municipality

    expect(country).not_to be_valid
    expect(country.errors[:parent]).to include('must not create a cycle')
  end

  it 'aggregates descendant Elections once even when an Election has several Races' do
    country = create(:country)
    country_jurisdiction = create(:jurisdiction, jurisdictionable: country)
    municipality = create(:municipality, state: create(:state, country: country))
    local = create(:jurisdiction, jurisdictionable: municipality, parent: country_jurisdiction)
    election = create(:election, :active, jurisdiction: local)
    create_list(:race, 2, election: election)

    expect(country.active_elections_count).to eq(1)
    expect(country.total_offices_count).to eq(2)
    expect(municipality.elections).to contain_exactly(election)
    expect(country_jurisdiction.self_and_descendants).to contain_exactly(country_jurisdiction, local)
  end

  it 'lets all five entity types own one Jurisdiction and prevents duplicate owners' do
    [ :country, :state, :county, :municipality, :district ].each do |factory|
      owner = create(factory)
      jurisdiction = create(:jurisdiction, jurisdictionable: owner)
      expect(owner.reload.jurisdiction).to eq(jurisdiction)
      expect(build(:jurisdiction, jurisdictionable: owner)).not_to be_valid
    end
  end

  it 'rejects a Municipality whose County belongs to another State' do
    municipality = build(:municipality, county: create(:county))

    expect(municipality).not_to be_valid
    expect(municipality.errors[:county]).to include('must belong to the same state')
  end
end
