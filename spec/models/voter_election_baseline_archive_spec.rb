require 'rails_helper'

RSpec.describe VoterElectionBaselineArchive, type: :model do
  describe 'validations' do
    subject { build(:voter_election_baseline_archive) }
    
    it { should validate_presence_of(:baseline) }
    it { should validate_inclusion_of(:baseline).in_range(0..500) }
    it { should validate_presence_of(:archived_at) }
    it { should validate_presence_of(:reason) }
    it { should validate_inclusion_of(:previous_baseline).in_range(0..500) }
    it { should validate_inclusion_of(:new_baseline).in_range(0..500) }
  end

  describe 'associations' do
    it { should belong_to(:voter) }
    it { should belong_to(:election) }
  end

  describe 'scopes' do
    let!(:recent_archive) { create(:voter_election_baseline_archive, archived_at: 1.hour.ago) }
    let!(:older_archive) { create(:voter_election_baseline_archive, archived_at: 1.day.ago) }

    describe '.recent' do
      it 'orders archives by archived_at descending' do
        expect(VoterElectionBaselineArchive.recent.first).to eq(recent_archive)
      end
    end
  end

  describe 'utility methods' do
    let(:archive) { build(:voter_election_baseline_archive, baseline: 300, previous_baseline: 200, new_baseline: 400) }

    describe '#baseline_percentage' do
      it 'calculates baseline as percentage of 500' do
        expect(archive.baseline_percentage).to eq(60.0)
      end
    end

    describe '#baseline_change' do
      it 'calculates the difference between new and previous baseline' do
        expect(archive.baseline_change).to eq(200)
      end
    end

    describe '#baseline_change_percentage' do
      it 'calculates percentage change from previous baseline' do
        expect(archive.baseline_change_percentage).to eq(100.0)
      end
    end

    describe '#name' do
      context 'when baseline changed' do
        it 'includes direction of change' do
          expect(archive.name).to include('increased')
        end
      end
    end
  end
end