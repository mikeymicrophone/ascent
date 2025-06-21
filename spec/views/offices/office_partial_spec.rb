require 'rails_helper'

RSpec.describe Views::Offices::OfficePartial, type: :view do
  let(:position) { create(:position, title: "Mayor") }
  let(:city) { create(:city, name: "Springfield") }
  let(:office) { create(:office, position: position, jurisdiction: city, is_active: true, notes: "City executive office") }
  
  let(:partial) { described_class.new(office: office) }
  
  def render_component(component = partial)
    view_context.render(component)
  end

  def view_context
    controller.view_context
  end

  def controller
    @controller ||= ActionView::TestCase::TestController.new.tap do |c|
      c.request = ActionDispatch::TestRequest.create
    end
  end
  
  let(:rendered) { render_component }

  describe '#view_template' do
    it 'renders the office position title' do
      expect(rendered).to include("Mayor")
    end

    it 'renders the jurisdiction information' do
      expect(rendered).to include("Jurisdiction:")
      expect(rendered).to include("Springfield")
    end

    it 'renders the active status' do
      expect(rendered).to include("Is active:")
      expect(rendered).to include(office.is_active.to_s)
    end

    it 'renders the office notes' do
      expect(rendered).to include("Notes:")
      expect(rendered).to include("City executive office")
    end

    it 'includes the office-partial CSS class' do
      expect(rendered).to include('class="office-partial"')
    end

    it 'includes the DOM ID for the office' do
      expect(rendered).to include(dom_id(office))
    end

    context 'when office is inactive' do
      let(:inactive_office) { create(:office, :inactive, position: position, jurisdiction: city) }
      let(:inactive_partial) { described_class.new(office: inactive_office) }
      let(:inactive_rendered) { render_component(inactive_partial) }

      it 'shows inactive status' do
        expect(inactive_rendered).to include(inactive_office.is_active.to_s)
      end
    end

    context 'when office has multiline notes' do
      let(:multiline_office) { create(:office, position: position, jurisdiction: city, notes: "Line 1\nLine 2\nLine 3") }
      let(:multiline_partial) { described_class.new(office: multiline_office) }
      let(:multiline_rendered) { render_component(multiline_partial) }

      it 'formats notes with simple_format' do
        expect(multiline_rendered).to include("Line 1")
        expect(multiline_rendered).to include("Line 2")
        expect(multiline_rendered).to include("Line 3")
      end
    end
  end

  describe '#render_election_history' do
    context 'when office has no elections' do
      it 'does not render election history section' do
        expect(rendered).not_to include("Election History")
      end
    end

    context 'when office has elections' do
      let!(:election1) { create(:election, office: office, election_date: 1.year.ago) }
      let!(:election2) { create(:election, office: office, election_date: 6.months.ago) }
      let!(:election3) { create(:election, office: office, election_date: 1.month.ago) }

      before do
        # Reload office to pick up elections association
        office.reload
      end

      it 'renders election history expandable section' do
        expect(rendered).to include("Election History")
      end

      it 'shows the correct election count' do
        expect(rendered).to include("3")
      end

      it 'includes expandable section structure' do
        expect(rendered).to include('class="expandable-section"')
        expect(rendered).to include('class="expandable-header"')
      end

      it 'includes election timeline for elections' do
        # The election timeline should be present
        expect(rendered).to include('class="election-timeline"')
      end

      context 'when office has many elections' do
        before do
          # Create additional elections beyond the limit of 3
          create_list(:election, 5, office: office)
          office.reload
        end

        it 'shows the total count of all elections' do
          expect(rendered).to include("8") # 3 original + 5 new = 8 total
        end

        it 'includes view all link structure' do
          expect(rendered).to include('class="elections-view-all"')
        end
      end
    end

    context 'with elections that have candidates' do
      let!(:election) { create(:election, office: office) }
      let!(:candidate1) { create(:person, first_name: "John", last_name: "Doe") }
      let!(:candidate2) { create(:person, first_name: "Jane", last_name: "Smith") }
      let!(:candidacy1) { create(:candidacy, election: election, person: candidate1) }
      let!(:candidacy2) { create(:candidacy, election: election, person: candidate2) }

      before do
        office.reload
      end

      it 'renders election with candidate information' do
        expect(rendered).to include("Election History")
        # The elections should include candidate data through the includes
        expect(office.elections.first.candidates).to include(candidate1, candidate2)
      end
    end
  end

  describe 'integration with components' do
    let!(:election) { create(:election, office: office, election_date: 1.year.ago) }
    let(:office_with_elections) { Office.includes(:elections).find(office.id) }
    let(:partial_with_elections) { described_class.new(office: office_with_elections) }
    let(:rendered_with_elections) { render_component(partial_with_elections) }

    it 'integrates with ExpandableSection component' do
      expect(rendered_with_elections).to include('data-controller="expandable-section"')
      expect(rendered_with_elections).to include('data-action="click->expandable-section#toggle"')
    end

    it 'integrates with election timeline component' do
      expect(rendered_with_elections).to include('class="election-timeline"')
    end
  end

  describe 'accessibility' do
    it 'includes proper button semantics for expandable sections' do
      election = create(:election, office: office)
      office_with_elections = Office.includes(:elections).find(office.id)
      partial_with_elections = described_class.new(office: office_with_elections)
      rendered_with_elections = render_component(partial_with_elections)
      
      expect(rendered_with_elections).to include('<button')
      expect(rendered_with_elections).to include('expandable-header')
    end

    it 'includes proper labeling for sections' do
      expect(rendered).to include("Jurisdiction:")
      expect(rendered).to include("Is active:")
      expect(rendered).to include("Notes:")
    end
  end

  describe 'current office holder' do
    context 'when office has completed elections' do
      let(:completed_office) { create(:office, position: position, jurisdiction: city) }
      let!(:completed_election) { create(:election, office: completed_office, status: 'completed', election_date: 1.year.ago) }
      let!(:candidacy) { create(:candidacy, election: completed_election) }
      let!(:voter_baseline) { create(:voter_election_baseline, election: completed_election, baseline: 5) }
      let!(:rating) { create(:rating, candidacy: candidacy, voter: voter_baseline.voter, rating: 7) }
      let(:completed_partial) { described_class.new(office: completed_office) }
      let(:completed_rendered) { render_component(completed_partial) }
      
      before do
        completed_office.reload
      end

      it 'renders current office holder section' do
        expect(completed_rendered).to include('Current Office Holder')
        expect(completed_rendered).to include('class="current-holder-section"')
      end

      it 'shows the winner from most recent completed election' do
        expect(completed_rendered).to include(candidacy.person.name)
        expect(completed_rendered).to include('current-holder-name')
      end
    end

    context 'when office has no completed elections' do
      it 'does not render current office holder section' do
        expect(rendered).not_to include('Current Office Holder')
        expect(rendered).not_to include('class="current-holder-section"')
      end
    end
  end

  describe 'election timeline details' do
    context 'with completed elections' do
      let!(:completed_election) { create(:election, office: office, status: 'completed', election_date: 1.year.ago) }
      let!(:candidacy1) { create(:candidacy, election: completed_election) }
      let!(:candidacy2) { create(:candidacy, election: completed_election) }
      let!(:voter_baseline) { create(:voter_election_baseline, election: completed_election, baseline: 5) }
      let!(:rating1) { create(:rating, candidacy: candidacy1, voter: voter_baseline.voter, rating: 8) }
      let!(:rating2) { create(:rating, candidacy: candidacy2, voter: voter_baseline.voter, rating: 3) }

      before do
        office.reload
      end

      it 'shows election results for completed elections' do
        expect(rendered).to include('Results')
        expect(rendered).to include('class="election-results"')
        expect(rendered).to include(candidacy1.person.name)
      end

      it 'shows voter turnout statistics' do
        expect(rendered).to include('Voter Participation')
        expect(rendered).to include('class="turnout-stats"')
        expect(rendered).to include('Registered Voters:')
        expect(rendered).to include('Total Approvals:')
      end

      it 'includes winner indicator for top candidate' do
        expect(rendered).to include('👑')
        expect(rendered).to include('class="winner-indicator"')
      end
    end

    context 'with upcoming elections' do
      let!(:upcoming_election) { create(:election, office: office, status: 'upcoming', election_date: 1.month.from_now) }

      before do
        office.reload
      end

      it 'shows election schedule for upcoming elections' do
        expect(rendered).to include('Scheduled:')
        expect(rendered).to include('class="election-schedule"')
        expect(rendered).to include('days away')
      end
    end
  end

  describe 'performance considerations' do
    it 'works with preloaded associations' do
      # This test ensures the partial works with preloaded data
      office_with_includes = Office.includes(:position, :elections).find(office.id)
      partial_with_includes = described_class.new(office: office_with_includes)
      
      expect { render_component(partial_with_includes) }.not_to raise_error
    end
  end
end