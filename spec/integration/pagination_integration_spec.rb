require 'rails_helper'

RSpec.describe 'Pagination Integration', type: :request do
  before do
    # Ensure we have enough states for pagination
    create_list(:state, 30) if State.count < 30
  end

  describe 'States index pagination' do
    it 'displays pagination when there are more than 25 states' do
      get states_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include('pagination-container')
      expect(response.body).to include('pagination-nav')
      expect(response.body).to include('pagination-info')
    end

    it 'respects page parameter' do
      get states_path, params: { page: 2 }
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include('pagination-container')
    end

    it 'shows page information' do
      get states_path
      
      expect(response).to have_http_status(:success)
      # Should show something like "Displaying items 1-25 of 30 in total"
      expect(response.body).to match(/Displaying items \d+-\d+ of \d+ in total/i)
    end

    it 'shows navigation links' do
      get states_path
      
      expect(response).to have_http_status(:success)
      # Should have next page link since we have more than 25 states
      expect(response.body).to include('Next')
    end
  end

  describe 'Pagination styling' do
    it 'includes semantic CSS classes for styling' do
      get states_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include('class="pagination-container"')
      expect(response.body).to include('class="pagination-info"')
      expect(response.body).to include('class="pagination-nav"')
    end
  end
end