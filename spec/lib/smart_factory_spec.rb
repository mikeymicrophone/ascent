require 'rails_helper'

RSpec.describe SmartFactory do
  describe '.create_for_mountain_simulation' do
    context 'with reuse functionality' do
      let(:factory_name) { :person }
      let(:traits) { [:young_candidate] }
      let(:attributes) { { first_name: 'Test' } }

      it 'creates new objects when no existing objects match' do
        expect {
          SmartFactory.create_for_mountain_simulation(factory_name, traits, **attributes)
        }.to change(Person, :count).by(1)
      end

      it 'can reuse existing objects based on likelihood' do
        # Create an initial person
        existing_person = create(:person, :young_candidate, first_name: 'Test')
        
        # Mock random to always trigger reuse
        allow(SmartFactory).to receive(:rand).and_return(1) # Always reuse
        
        # Should not create a new person
        result = SmartFactory.create_for_mountain_simulation(factory_name, traits, **attributes)
        expect(result).to eq(existing_person)
      end

      it 'creates new objects when reuse is not triggered' do
        # Create an initial person
        create(:person, :young_candidate, first_name: 'Test')
        
        # Mock random to never trigger reuse
        allow(SmartFactory).to receive(:rand).and_return(10) # Never reuse (likelihood is typically lower)
        
        # Should create a new person
        expect {
          SmartFactory.create_for_mountain_simulation(factory_name, traits, **attributes)
        }.to change(Person, :count).by(1)
      end
    end

    context 'with count parameter' do
      it 'creates multiple objects when count is specified' do
        # Mock random to prevent reuse for this test
        allow(SmartFactory).to receive(:rand).and_return(10) # Never reuse
        
        expect {
          SmartFactory.create_for_mountain_simulation(:person, [:young_candidate], count: 3)
        }.to change(Person, :count).by(3)
      end
    end

    context 'with different factory types' do
      let(:person) { create(:person) }
      let(:election) { create(:election) }

      it 'works with candidacy factory' do
        expect {
          SmartFactory.create_for_mountain_simulation(:candidacy, [:democrat], 
                                                     person: person, election: election)
        }.to change(Candidacy, :count).by(1)
      end

      it 'works with rating factory' do
        candidacy = create(:candidacy)
        voter = create(:voter)
        
        expect {
          SmartFactory.create_for_mountain_simulation(:rating, [], 
                                                     voter: voter, candidacy: candidacy, rating: 350)
        }.to change(Rating, :count).by(1)
      end
    end

    context 'input validation' do
      it 'handles empty traits array' do
        expect {
          SmartFactory.create_for_mountain_simulation(:person, [])
        }.not_to raise_error
      end

      it 'handles nil attributes' do
        expect {
          SmartFactory.create_for_mountain_simulation(:person, [:young_candidate])
        }.not_to raise_error
      end
    end
  end

  describe 'private reuse logic' do
    let(:factory_name) { :person }
    let(:traits) { [:young_candidate] }
    
    before do
      # Create some existing people with different traits
      create(:person, :young_candidate, first_name: 'John')
      create(:person, :experienced_politician, first_name: 'Jane')
      create(:person, :business_leader, first_name: 'Bob')
    end

    it 'finds reusable objects that match traits and attributes' do
      # Should find the young_candidate
      result = SmartFactory.send(:find_reusable_object, factory_name, traits, { first_name: 'John' })
      expect(result).to be_present
      expect(result.first_name).to eq('John')
    end

    it 'returns nil when no matching objects exist' do
      result = SmartFactory.send(:find_reusable_object, factory_name, [:veteran], { first_name: 'NonExistent' })
      expect(result).to be_nil
    end
  end
end