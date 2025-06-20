require 'rails_helper'

RSpec.describe Election, type: :model do
  describe 'vote aggregation with realistic mountain simulation data' do
    let(:election) { create(:election) }
    
    before do
      # Create a realistic election scenario using mountain simulation
      # Generate candidates with diverse backgrounds (SmartFactory may reuse some people)
      8.times do |i|
        person = SmartFactory.create_for_mountain_simulation(:person, [:young_candidate, :experienced_politician, :business_leader, :community_activist, :educator, :veteran].sample)
        SmartFactory.create_for_mountain_simulation(:candidacy, [:democrat, :republican, :independent, :green].sample, 
                                                   person: person, election: election)
      end
      
      @actual_candidacy_count = election.candidacies.count
      
      # Create 15 unique voters with varying baselines
      15.times do |i|
        voter = create(:voter, email: "voter#{i}@election.test")
        
        # Create diverse baselines - some high standards, some low, some moderate
        baseline_value = case i % 5
                        when 0, 1 then rand(180..220) # Lower standards (36-44%)
                        when 2, 3 then rand(240..290) # Moderate standards (48-58%)
                        when 4 then rand(320..380)    # High standards (64-76%)
                        end
        
        create(:voter_election_baseline, voter: voter, election: election, baseline: baseline_value)
        
        # Each voter rates all candidates with realistic distributions
        election.candidacies.each do |candidacy|
          # Create realistic rating distributions
          # Some candidates are generally well-liked, others polarizing
          base_rating = case candidacy.party_affiliation
                       when 'democrat' then rand(200..400)
                       when 'republican' then rand(180..420)
                       when 'independent' then rand(150..350)
                       when 'green' then rand(120..280)
                       else rand(150..350)
                       end
          
          # Add some voter-specific variation
          personal_adjustment = rand(-50..50)
          final_rating = [base_rating + personal_adjustment, 0].max.clamp(0, 500)
          
          create(:rating, voter: voter, candidacy: candidacy, rating: final_rating)
        end
      end
    end

    it 'correctly aggregates votes across all voters and candidacies' do
      results = election.aggregate_votes
      
      # Basic structure validation
      expect(results).to be_a(Hash)
      expect(results.keys.size).to eq(@actual_candidacy_count) # All candidacies present
      expect(results.keys).to all(be_a(Candidacy))
      expect(results.values).to all(be_a(Integer))
      expect(results.values).to all(be >= 0)
      
      # Vote counts should be reasonable for 15 voters
      total_votes = results.values.sum
      expect(total_votes).to be > 0 # Someone should get at least one vote
      expect(total_votes).to be <= 15 * @actual_candidacy_count # Can't exceed max possible
      
      # Each candidacy should have a vote count
      election.candidacies.each do |candidacy|
        expect(results).to have_key(candidacy)
      end
    end

    it 'produces realistic approval voting patterns' do
      results = election.aggregate_votes
      
      # Should have a distribution of vote counts, not all the same
      vote_counts = results.values
      expect(vote_counts.uniq.size).to be > 1 # Different candidates get different vote counts
      
      # Winner should have meaningful support
      max_votes = vote_counts.max
      expect(max_votes).to be >= 3 # Winner should have at least 3 approval votes
      
      # Should have both winners and losers
      min_votes = vote_counts.min
      expect(max_votes).to be > min_votes # Some differentiation in performance
    end

    it 'correctly identifies election winner and provides meaningful summary' do
      winner = election.approval_winner
      summary = election.results_summary
      
      # Winner validation
      expect(winner).to be_a(Candidacy)
      expect(winner.election).to eq(election)
      
      # Summary validation
      expect(summary).to include(
        total_candidacies: @actual_candidacy_count,
        total_registered_voters: 15,
        total_approval_votes: be_a(Integer),
        average_approvals_per_voter: be_a(Float),
        winner: be_a(String),
        winning_vote_count: be_a(Integer)
      )
      
      # Logical consistency checks
      expect(summary[:total_approval_votes]).to be > 0
      expect(summary[:average_approvals_per_voter]).to be > 0
      expect(summary[:winning_vote_count]).to be > 0
      expect(summary[:average_approvals_per_voter]).to be_within(0.01).of(summary[:total_approval_votes].to_f / 15)
      
      # Winner consistency
      results = election.aggregate_votes
      expect(summary[:winning_vote_count]).to eq(results[winner])
      expect(summary[:winner]).to eq(winner.person.name)
    end

    it 'properly handles individual voter baseline differences' do
      # Test that the same rating is counted differently based on voter baseline
      
      # Find a specific rating and voter
      sample_rating = Rating.joins(:candidacy).where(candidacies: { election: election }).first
      voter = sample_rating.voter
      candidacy = sample_rating.candidacy
      baseline = VoterElectionBaseline.find_by(voter: voter, election: election)
      
      original_rating = sample_rating.rating
      original_results = election.aggregate_votes
      original_count = original_results[candidacy]
      
      # Case 1: Rating above baseline should count as approval
      if original_rating >= baseline.baseline
        # Lower the rating below baseline
        sample_rating.update!(rating: baseline.baseline - 1)
        new_results = election.aggregate_votes
        expect(new_results[candidacy]).to eq(original_count - 1)
        
        # Restore and verify
        sample_rating.update!(rating: original_rating)
        restored_results = election.aggregate_votes
        expect(restored_results[candidacy]).to eq(original_count)
      else
        # Raise the rating above baseline
        sample_rating.update!(rating: baseline.baseline + 1)
        new_results = election.aggregate_votes
        expect(new_results[candidacy]).to eq(original_count + 1)
        
        # Restore and verify
        sample_rating.update!(rating: original_rating)
        restored_results = election.aggregate_votes
        expect(restored_results[candidacy]).to eq(original_count)
      end
    end

    it 'handles edge cases gracefully' do
      # Test empty baseline scenario
      all_baselines = VoterElectionBaseline.where(election: election)
      all_baselines.destroy_all
      
      empty_results = election.aggregate_votes
      expect(empty_results.values).to all(eq(0))
      expect(election.approval_winner).to be_nil
      
      # Test high baseline scenario - update existing baselines to be very high
      VoterElectionBaseline.where(election: election).update_all(baseline: 490) # Very high standard
      
      high_baseline_results = election.aggregate_votes
      # Most votes should be zero with such high standards
      zero_vote_count = high_baseline_results.values.count(0)
      expect(zero_vote_count).to be >= high_baseline_results.size / 2 # At least half should have zero votes
    end

    it 'maintains consistency across multiple calls' do
      # Results should be deterministic
      results1 = election.aggregate_votes
      results2 = election.aggregate_votes
      results3 = election.aggregate_votes
      
      expect(results1).to eq(results2)
      expect(results2).to eq(results3)
      
      # Summary should also be consistent
      summary1 = election.results_summary
      summary2 = election.results_summary
      
      expect(summary1).to eq(summary2)
    end
  end
end