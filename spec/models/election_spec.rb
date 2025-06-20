require 'rails_helper'

RSpec.describe Election, type: :model do
  describe 'validations' do
    subject { build(:election) }
    
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[upcoming active completed cancelled]) }
    it { should validate_presence_of(:election_date) }
    it { should validate_inclusion_of(:is_mock).in_array([true, false]) }
    it { should validate_inclusion_of(:is_historical).in_array([true, false]) }
  end

  describe 'associations' do
    it { should belong_to(:office) }
    it { should belong_to(:year) }
    it { should have_many(:candidacies).dependent(:destroy) }
    it { should have_many(:candidates).through(:candidacies) }
    it { should have_many(:voter_election_baselines).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:upcoming_election) { create(:election, status: 'upcoming') }
    let!(:active_election) { create(:election, status: 'active') }
    let!(:completed_election) { create(:election, status: 'completed') }
    let!(:mock_election) { create(:election, is_mock: true) }

    it '.upcoming returns upcoming elections' do
      expect(Election.upcoming).to include(upcoming_election)
      expect(Election.upcoming).not_to include(active_election)
    end

    it '.active returns active elections' do
      expect(Election.active).to include(active_election)
      expect(Election.active).not_to include(upcoming_election)
    end

    it '.completed returns completed elections' do
      expect(Election.completed).to include(completed_election)
      expect(Election.completed).not_to include(upcoming_election)
    end

    it '.mock returns mock elections' do
      expect(Election.mock).to include(mock_election)
    end
  end

  describe '#aggregate_votes' do
    let(:election) { create(:election) }
    let!(:candidacy1) { create(:candidacy, election: election) }
    let!(:candidacy2) { create(:candidacy, election: election) }
    let!(:candidacy3) { create(:candidacy, election: election) }

    context 'with no voters or ratings' do
      it 'returns all candidacies with zero votes' do
        results = election.aggregate_votes
        
        expect(results).to be_a(Hash)
        expect(results.keys).to match_array([candidacy1, candidacy2, candidacy3])
        expect(results.values).to all(eq(0))
      end
    end

    context 'with voters and ratings' do
      let!(:voter1) { create(:voter) }
      let!(:voter2) { create(:voter) }
      let!(:voter3) { create(:voter) }
      
      # Set baselines
      let!(:baseline1) { create(:voter_election_baseline, voter: voter1, election: election, baseline: 250) }
      let!(:baseline2) { create(:voter_election_baseline, voter: voter2, election: election, baseline: 300) }
      let!(:baseline3) { create(:voter_election_baseline, voter: voter3, election: election, baseline: 200) }

      before do
        # Voter 1 ratings (baseline: 250)
        create(:rating, voter: voter1, candidacy: candidacy1, rating: 400) # Above baseline - COUNTS
        create(:rating, voter: voter1, candidacy: candidacy2, rating: 200) # Below baseline - doesn't count
        create(:rating, voter: voter1, candidacy: candidacy3, rating: 250) # At baseline - COUNTS

        # Voter 2 ratings (baseline: 300)
        create(:rating, voter: voter2, candidacy: candidacy1, rating: 350) # Above baseline - COUNTS
        create(:rating, voter: voter2, candidacy: candidacy2, rating: 280) # Below baseline - doesn't count
        create(:rating, voter: voter2, candidacy: candidacy3, rating: 100) # Below baseline - doesn't count

        # Voter 3 ratings (baseline: 200)
        create(:rating, voter: voter3, candidacy: candidacy1, rating: 150) # Below baseline - doesn't count
        create(:rating, voter: voter3, candidacy: candidacy2, rating: 450) # Above baseline - COUNTS
        create(:rating, voter: voter3, candidacy: candidacy3, rating: 300) # Above baseline - COUNTS
      end

      it 'correctly counts approval votes based on individual baselines' do
        results = election.aggregate_votes
        
        expect(results[candidacy1]).to eq(2) # voter1(400≥250) + voter2(350≥300)
        expect(results[candidacy2]).to eq(1) # voter3(450≥200)
        expect(results[candidacy3]).to eq(2) # voter1(250≥250) + voter3(300≥200)
      end

      it 'includes all candidacies even if they have no approval votes' do
        # Remove all ratings for candidacy2 that would count
        Rating.where(candidacy: candidacy2, voter: voter3).update_all(rating: 150)
        
        results = election.aggregate_votes
        expect(results.keys).to include(candidacy2)
        expect(results[candidacy2]).to eq(0)
      end
    end

    context 'with voters who have no ratings' do
      let!(:voter) { create(:voter) }
      let!(:baseline) { create(:voter_election_baseline, voter: voter, election: election, baseline: 250) }

      it 'does not affect vote counts' do
        results = election.aggregate_votes
        expect(results.values).to all(eq(0))
      end
    end

    context 'with ratings but no baselines' do
      let!(:voter) { create(:voter) }
      
      before do
        create(:rating, voter: voter, candidacy: candidacy1, rating: 400)
      end

      it 'returns zero votes for all candidacies' do
        results = election.aggregate_votes
        expect(results.values).to all(eq(0))
      end
    end
  end

  describe '#approval_results' do
    let(:election) { create(:election) }
    let!(:candidacy1) { create(:candidacy, election: election) }
    let!(:candidacy2) { create(:candidacy, election: election) }
    let!(:candidacy3) { create(:candidacy, election: election) }

    before do
      # Mock aggregate_votes to return known results
      allow(election).to receive(:aggregate_votes).and_return({
        candidacy1 => 5,
        candidacy2 => 10,
        candidacy3 => 3
      })
    end

    it 'returns candidacies sorted by vote count descending' do
      results = election.approval_results
      
      expect(results).to be_an(Array)
      expect(results.map(&:first)).to eq([candidacy2, candidacy1, candidacy3])
      expect(results.map(&:second)).to eq([10, 5, 3])
    end
  end

  describe '#approval_winner' do
    let(:election) { create(:election) }
    let!(:candidacy1) { create(:candidacy, election: election) }
    let!(:candidacy2) { create(:candidacy, election: election) }

    context 'with clear winner' do
      before do
        allow(election).to receive(:aggregate_votes).and_return({
          candidacy1 => 3,
          candidacy2 => 7
        })
      end

      it 'returns the candidacy with most votes' do
        expect(election.approval_winner).to eq(candidacy2)
      end
    end

    context 'with tie' do
      before do
        allow(election).to receive(:aggregate_votes).and_return({
          candidacy1 => 5,
          candidacy2 => 5
        })
      end

      it 'returns one of the tied candidacies' do
        winner = election.approval_winner
        expect([candidacy1, candidacy2]).to include(winner)
      end
    end

    context 'with no votes' do
      before do
        allow(election).to receive(:aggregate_votes).and_return({
          candidacy1 => 0,
          candidacy2 => 0
        })
      end

      it 'returns nil' do
        expect(election.approval_winner).to be_nil
      end
    end

    context 'with empty election' do
      before do
        allow(election).to receive(:aggregate_votes).and_return({})
      end

      it 'returns nil' do
        expect(election.approval_winner).to be_nil
      end
    end
  end

  describe '#results_summary' do
    let(:election) { create(:election) }
    let!(:candidacy1) { create(:candidacy, election: election) }
    let!(:candidacy2) { create(:candidacy, election: election) }
    let!(:voter1) { create(:voter) }
    let!(:voter2) { create(:voter) }

    before do
      create(:voter_election_baseline, voter: voter1, election: election, baseline: 250)
      create(:voter_election_baseline, voter: voter2, election: election, baseline: 300)
      
      allow(election).to receive(:aggregate_votes).and_return({
        candidacy1 => 3,
        candidacy2 => 7
      })
      allow(election).to receive(:approval_winner).and_return(candidacy2)
      allow(candidacy2.person).to receive(:name).and_return("Jane Smith")
    end

    it 'returns comprehensive election statistics' do
      summary = election.results_summary
      
      expect(summary).to include(
        total_candidacies: 2,
        total_registered_voters: 2,
        total_approval_votes: 10,
        average_approvals_per_voter: 5.0,
        winner: "Jane Smith",
        winning_vote_count: 7
      )
    end

    context 'with no voters' do
      before do
        VoterElectionBaseline.where(election: election).destroy_all
      end

      it 'handles division by zero gracefully' do
        summary = election.results_summary
        expect(summary[:average_approvals_per_voter]).to eq(0)
      end
    end
  end

  describe '#result_for' do
    let(:election) { create(:election) }
    let!(:candidacy1) { create(:candidacy, election: election) }
    let!(:candidacy2) { create(:candidacy, election: election) }
    let!(:candidacy3) { create(:candidacy, election: election) }

    context 'with mock aggregate_votes results' do
      before do
        allow(election).to receive(:aggregate_votes).and_return({
          candidacy1 => 15,
          candidacy2 => 7,
          candidacy3 => 0
        })
      end

      it 'returns the correct vote count for each candidacy' do
        expect(election.result_for(candidacy1)).to eq(15)
        expect(election.result_for(candidacy2)).to eq(7)
        expect(election.result_for(candidacy3)).to eq(0)
      end

      it 'works with reloaded candidacy objects' do
        reloaded_candidacy = Candidacy.find(candidacy1.id)
        expect(election.result_for(reloaded_candidacy)).to eq(15)
      end
    end

    context 'with candidacy not in election' do
      let(:other_election) { create(:election) }
      let!(:external_candidacy) { create(:candidacy, election: other_election) }

      before do
        allow(election).to receive(:aggregate_votes).and_return({
          candidacy1 => 5
        })
      end

      it 'returns 0 for candidacy not in this election' do
        expect(election.result_for(external_candidacy)).to eq(0)
      end
    end

    context 'with real vote aggregation' do
      let!(:voter1) { create(:voter) }
      let!(:voter2) { create(:voter) }
      
      before do
        # Set up baselines
        create(:voter_election_baseline, voter: voter1, election: election, baseline: 250)
        create(:voter_election_baseline, voter: voter2, election: election, baseline: 300)
        
        # Voter 1 ratings (baseline: 250)
        create(:rating, voter: voter1, candidacy: candidacy1, rating: 400) # Above baseline - COUNTS
        create(:rating, voter: voter1, candidacy: candidacy2, rating: 200) # Below baseline - doesn't count
        
        # Voter 2 ratings (baseline: 300)
        create(:rating, voter: voter2, candidacy: candidacy1, rating: 350) # Above baseline - COUNTS
        create(:rating, voter: voter2, candidacy: candidacy2, rating: 280) # Below baseline - doesn't count
      end

      it 'returns correct approval vote counts from real data' do
        expect(election.result_for(candidacy1)).to eq(2) # Both voters approved
        expect(election.result_for(candidacy2)).to eq(0) # No approvals
        expect(election.result_for(candidacy3)).to eq(0) # No ratings at all
      end

      it 'is consistent with aggregate_votes method' do
        full_results = election.aggregate_votes
        
        election.candidacies.each do |candidacy|
          expect(election.result_for(candidacy)).to eq(full_results[candidacy])
        end
      end
    end

    context 'edge cases' do
      it 'handles election with no votes gracefully' do
        expect(election.result_for(candidacy1)).to eq(0)
        expect(election.result_for(candidacy2)).to eq(0)
        expect(election.result_for(candidacy3)).to eq(0)
      end
    end
  end
end