require 'rails_helper'

RSpec.describe Views::Components::HierarchicalNavigation, type: :view do
  let!(:country) { create(:country, name: "United States") }
  let!(:state) { create(:state, country: country, name: "California") }
  let!(:city) { create(:city, state: state, name: "San Francisco") }
  
  def render_component(component)
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

  describe 'breadcrumb navigation' do
    context 'when displaying a city' do
      let(:component) { described_class.new(current_object: city) }
      let(:rendered) { render_component(component) }

      it 'renders the full hierarchy chain' do
        expect(rendered).to include("United States")
        expect(rendered).to include("California")
        expect(rendered).to include("San Francisco")
      end

      it 'includes breadcrumb separators' do
        expect(rendered).to include('class="breadcrumb-separator"')
        expect(rendered).to include(">")
      end

      it 'marks the current item correctly' do
        expect(rendered).to include('class="breadcrumb-current"')
        expect(rendered).to include('class="breadcrumb-item current"')
      end

      it 'makes parent items clickable' do
        expect(rendered).to include('class="breadcrumb-link"')
        expect(rendered).to include('href="/countries/')
        expect(rendered).to include('href="/states/')
      end

      it 'includes hierarchical navigation CSS class' do
        expect(rendered).to include('class="hierarchical-navigation"')
      end
    end

    context 'when displaying a state' do
      let(:component) { described_class.new(current_object: state) }
      let(:rendered) { render_component(component) }

      it 'renders hierarchy up to state level' do
        expect(rendered).to include("United States")
        expect(rendered).to include("California")
        expect(rendered).not_to include("San Francisco")
      end

      it 'marks state as current' do
        expect(rendered).to include('class="breadcrumb-current"')
        # Should contain California as current, not as link
        expect(rendered).to match(/class="breadcrumb-current"[^>]*>California/)
      end
    end

    context 'when displaying a country' do
      let(:component) { described_class.new(current_object: country) }
      let(:rendered) { render_component(component) }

      it 'renders only the country' do
        expect(rendered).to include("United States")
        expect(rendered).not_to include("California")
        expect(rendered).not_to include("San Francisco")
      end

      it 'marks country as current' do
        expect(rendered).to include('class="breadcrumb-current"')
      end
    end
  end

  describe 'quick stats display' do
    context 'with voter and office data' do
      let!(:office) { create(:office, jurisdiction: city) }
      let!(:voter_residence) { create(:residence, jurisdiction: city) }
      let!(:voter) { create(:voter, residences: [voter_residence]) }
      let!(:election) { create(:election, office: office, status: 'active') }
      
      let(:component) { described_class.new(current_object: city, show_stats: true) }
      let(:rendered) { render_component(component) }

      it 'displays quick stats section' do
        expect(rendered).to include('class="quick-stats"')
      end

      it 'shows voter count' do
        expect(rendered).to include('class="voter-count"')
        expect(rendered).to include("voters")
      end

      it 'shows active elections count' do
        expect(rendered).to include('class="election-count"')
        expect(rendered).to include("active elections")
      end

      it 'shows office count' do
        expect(rendered).to include('class="office-count"')
        expect(rendered).to include("offices")
      end
    end

    context 'when show_stats is false' do
      let(:component) { described_class.new(current_object: city, show_stats: false) }
      let(:rendered) { render_component(component) }

      it 'does not display quick stats' do
        expect(rendered).not_to include('class="quick-stats"')
      end
    end
  end

  describe 'drill-down functionality' do
    context 'for a country with states' do
      let!(:other_state) { create(:state, country: country, name: "Texas") }
      let(:component) { described_class.new(current_object: country, expandable: true) }
      let(:rendered) { render_component(component) }

      it 'includes expandable drill-down section' do
        expect(rendered).to include('class="expandable-section"')
        expect(rendered).to include("Country Overview")
      end

      it 'shows children preview' do
        expect(rendered).to include('class="children-preview"')
        expect(rendered).to include("States")
      end

      it 'lists child states' do
        expect(rendered).to include("California")
        expect(rendered).to include("Texas")
      end

      it 'includes geographic summary' do
        expect(rendered).to include('class="geographic-summary"')
        expect(rendered).to include("Geographic Summary")
      end
    end

    context 'for a state with cities' do
      let!(:other_city) { create(:city, state: state, name: "Los Angeles") }
      let(:component) { described_class.new(current_object: state, expandable: true) }
      let(:rendered) { render_component(component) }

      it 'shows state overview' do
        expect(rendered).to include("State Overview")
      end

      it 'lists child cities' do
        expect(rendered).to include("San Francisco")
        expect(rendered).to include("Los Angeles")
      end
    end

    context 'for a city (no children)' do
      let(:component) { described_class.new(current_object: city, expandable: true) }
      let(:rendered) { render_component(component) }

      it 'does not show drill-down section' do
        expect(rendered).not_to include("City Overview")
        expect(rendered).not_to include('class="children-preview"')
      end
    end

    context 'when expandable is false' do
      let(:component) { described_class.new(current_object: country, expandable: false) }
      let(:rendered) { render_component(component) }

      it 'does not show drill-down section' do
        expect(rendered).not_to include('class="expandable-section"')
        expect(rendered).not_to include("Country Overview")
      end
    end
  end

  describe 'geographic summary stats' do
    context 'for a country with comprehensive data' do
      let!(:state2) { create(:state, country: country, name: "Texas") }
      let!(:city2) { create(:city, state: state, name: "Los Angeles") }
      let!(:city3) { create(:city, state: state2, name: "Houston") }
      
      let(:component) { described_class.new(current_object: country) }
      let(:rendered) { render_component(component) }

      it 'calculates total states correctly' do
        # Should count California and Texas
        summary_stats = component.send(:calculate_comprehensive_stats, country)
        expect(summary_stats[:total_states]).to eq(2)
      end

      it 'calculates total cities correctly' do
        # Should count San Francisco, Los Angeles, Houston
        summary_stats = component.send(:calculate_comprehensive_stats, country)
        expect(summary_stats[:total_cities]).to eq(3)
      end
    end
  end

  describe 'accessibility and usability' do
    let(:component) { described_class.new(current_object: city) }
    let(:rendered) { render_component(component) }

    it 'uses semantic nav element' do
      expect(rendered).to include('<nav')
      expect(rendered).to include('class="hierarchical-navigation"')
    end

    it 'provides clear visual hierarchy' do
      expect(rendered).to include('class="breadcrumb-chain"')
      expect(rendered).to include('class="breadcrumb-item"')
    end

    it 'includes proper link semantics' do
      expect(rendered).to include('class="breadcrumb-link"')
    end
  end

  describe 'edge cases' do
    context 'with nil or invalid object' do
      it 'handles gracefully' do
        expect {
          described_class.new(current_object: nil)
        }.not_to raise_error
      end
    end

    context 'with empty collections' do
      let(:empty_country) { create(:country, name: "Empty Country") }
      let(:component) { described_class.new(current_object: empty_country) }
      let(:rendered) { render_component(component) }

      it 'renders without errors' do
        expect(rendered).to include("Empty Country")
        expect(rendered).to include('class="hierarchical-navigation"')
      end

      it 'shows zero stats appropriately' do
        # Should not show stats sections when counts are zero
        expect(rendered).not_to include('class="voter-count"')
        expect(rendered).not_to include('class="election-count"')
      end
    end
  end
end