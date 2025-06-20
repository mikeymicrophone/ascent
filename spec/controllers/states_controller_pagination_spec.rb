require 'rails_helper'

RSpec.describe StatesController, type: :controller do
  before do
    # Skip authentication for these tests
    allow(controller).to receive(:authenticate_voter!).and_return(true)
    allow(controller).to receive(:current_voter).and_return(create(:voter))
  end

  describe 'GET #index with pagination' do
    before do
      # Create enough states to trigger pagination (more than default 25)
      create_list(:state, 30)
    end

    it 'paginates states correctly' do
      get :index
      
      expect(response).to have_http_status(:success)
      
      # Check that pagy object is created
      pagy = assigns(:pagy)
      expect(pagy).to be_present
      expect(pagy).to be_a(Pagy)
      
      # Check pagination properties
      expect(pagy.count).to be >= 30 # At least 30 states
      expect(pagy.limit).to eq(25)   # Default page size
      expect(pagy.pages).to be >= 2  # Multiple pages
    end

    it 'respects page parameter' do
      get :index, params: { page: 2 }
      
      expect(response).to have_http_status(:success)
      
      pagy = assigns(:pagy)
      expect(pagy.page).to eq(2)
    end

    it 'handles out of range page gracefully with overflow protection' do
      get :index, params: { page: 999 }
      
      expect(response).to have_http_status(:success)
      
      pagy = assigns(:pagy)
      # With overflow: :last_page, should redirect to last page
      expect(pagy.page).to eq(pagy.pages)
    end

    it 'passes correct states to view' do
      get :index
      
      states = assigns(:states)
      expect(states).to be_present
      expect(states.count).to be <= 25 # Should not exceed page size
      expect(states).to all(be_a(State))
    end
  end

  describe 'pagination integration with view' do
    before do
      create_list(:state, 30)
    end

    it 'renders pagination when multiple pages exist' do
      get :index
      
      # Check that view receives pagy object
      expect(assigns(:pagy)).to be_present
      expect(assigns(:pagy).pages).to be > 1
    end
  end
end