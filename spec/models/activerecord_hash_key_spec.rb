require 'rails_helper'

RSpec.describe 'ActiveRecord objects as hash keys' do
  let(:candidacy1) { create(:candidacy) }
  let(:candidacy2) { create(:candidacy) }
  
  it 'works correctly as hash keys' do
    hash = {}
    hash[candidacy1] = 10
    hash[candidacy2] = 5
    
    # Test basic functionality
    expect(hash[candidacy1]).to eq(10)
    expect(hash[candidacy2]).to eq(5)
    expect(hash.keys).to include(candidacy1, candidacy2)
    expect(hash.values).to include(10, 5)
  end
  
  it 'maintains consistency with reloaded objects' do
    hash = {}
    hash[candidacy1] = 15
    
    # Reload the object from database
    reloaded_candidacy = Candidacy.find(candidacy1.id)
    
    # Test if reloaded object works as same key
    expect(hash[reloaded_candidacy]).to eq(15)
    expect(hash.key?(reloaded_candidacy)).to be true
  end
  
  it 'handles object identity correctly' do
    hash = { candidacy1 => 20 }
    
    # Same object should work
    expect(hash[candidacy1]).to eq(20)
    
    # Different instance of same record should also work
    same_candidacy = Candidacy.find(candidacy1.id)
    expect(hash[same_candidacy]).to eq(20)
  end
  
  it 'differentiates between different records' do
    hash = {}
    hash[candidacy1] = 100
    hash[candidacy2] = 200
    
    expect(hash[candidacy1]).not_to eq(hash[candidacy2])
    expect(hash.size).to eq(2)
  end
end