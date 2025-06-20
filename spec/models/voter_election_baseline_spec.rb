require 'rails_helper'

RSpec.describe VoterElectionBaseline, type: :model do
  describe 'validations' do
    subject { build(:voter_election_baseline) }
    
    it { should validate_presence_of(:baseline) }
    it { should validate_inclusion_of(:baseline).in_range(0..500) }
  end

  describe 'associations' do
    it { should belong_to(:voter) }
    it { should belong_to(:election) }
  end

  describe 'baseline archival behavior' do
    let(:voter) { create(:voter) }
    let(:election) { create(:election) }
    let(:baseline) { create(:voter_election_baseline, voter: voter, election: election, baseline: 200) }

    context 'when baseline is updated' do
      it 'creates an archive record with previous and new values' do
        expect {
          baseline.update!(baseline: 350)
        }.to change(VoterElectionBaselineArchive, :count).by(1)

        archive = VoterElectionBaselineArchive.last
        expect(archive.voter).to eq(voter)
        expect(archive.election).to eq(election)
        expect(archive.baseline).to eq(200) # Previous baseline
        expect(archive.previous_baseline).to eq(200)
        expect(archive.new_baseline).to eq(350)
        expect(archive.reason).to eq("Baseline updated from 200 to 350")
      end

      it 'does not create archive if baseline unchanged' do
        expect {
          baseline.update!(baseline: 200) # Same value
        }.not_to change(VoterElectionBaselineArchive, :count)
      end
    end

    context 'when baseline is destroyed' do
      it 'creates an archive record marking deletion' do
        expect {
          baseline.destroy!
        }.to change(VoterElectionBaselineArchive, :count).by(1)

        archive = VoterElectionBaselineArchive.last
        expect(archive.baseline).to eq(200)
        expect(archive.previous_baseline).to eq(200)
        expect(archive.new_baseline).to be_nil
        expect(archive.reason).to eq("Baseline deleted (was 200)")
      end
    end
  end

  describe 'approval calculations' do
    let(:voter) { create(:voter) }
    let(:election) { create(:election) }
    let(:baseline) { create(:voter_election_baseline, voter: voter, election: election, baseline: 300) }
    let!(:high_rated_candidacy) { create(:candidacy, election: election) }
    let!(:low_rated_candidacy) { create(:candidacy, election: election) }

    before do
      create(:rating, voter: voter, candidacy: high_rated_candidacy, rating: 400)
      create(:rating, voter: voter, candidacy: low_rated_candidacy, rating: 200)
    end

    describe '#approved_candidacies' do
      it 'returns candidacies with ratings at or above baseline' do
        approved = baseline.approved_candidacies
        expect(approved).to include(high_rated_candidacy)
        expect(approved).not_to include(low_rated_candidacy)
      end
    end

    describe '#approval_count' do
      it 'counts candidacies with ratings at or above baseline' do
        expect(baseline.approval_count).to eq(1)
      end
    end
  end
end
