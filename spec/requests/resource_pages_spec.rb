require 'rails_helper'

# Issues, topics, approaches, and stances render their index and show pages
# through the shared ResourceIndex and ResourceShow shells.
RSpec.describe "Resource index and show pages", type: :request do
  let(:admin) { create(:admin_voter) }

  describe "an index page" do
    let!(:housing_issue) { create(:affordable_housing_issue) }
    let!(:school_issue) { create(:school_funding_issue) }

    it "lists each record with its partial and actions inside the scaffold" do
      get issues_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('class="scaffold issues-index" id="index_issues"')
      expect(response.body).to include("<h1>Issues</h1>")
      expect(response.body).to include("id=\"list_item_issue_#{housing_issue.id}\"")
      expect(response.body).to include("Affordable Housing Shortage", "Inadequate School Funding")
    end

    it "offers the new link only to voters allowed to create" do
      get issues_path
      expect(response.body).not_to include("New issue")

      sign_in admin
      get issues_path
      expect(response.body).to include(%(href="#{new_issue_path}">New issue</a>))
    end

    it "pages the records once there are more than a page of them" do
      create_list(:issue, Pagy::OPTIONS[:limit])

      get issues_path

      expect(response.body).to include(%(<nav class="pagination" aria-label="Pagination">), "Showing 1–25 of")
      expect(response.body.scan(/id="list_item_issue_\d+"/).size).to eq(Pagy::OPTIONS[:limit])
    end
  end

  it "names the empty state after the model" do
    get approaches_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No approaches found.")
  end

  describe "a show page" do
    it "wraps the record's partial with a heading and its actions" do
      approach = create(:approach, :affordable_housing_program)

      get approach_path(approach)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("class=\"scaffold approach-show\" id=\"show_approach_#{approach.id}\"")
      expect(response.body).to include("<h1>Showing approach</h1>")
      expect(response.body).to include("Affordable Housing Development Program")
    end

    it "lets a topic add its own sections between the partial and the actions" do
      issue = create(:affordable_housing_issue)

      get topic_path(issue.topic)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('class="topic-content-section topic-issues"')
      expect(response.body).to include("<h2>Issues in this Topic</h2>", "Affordable Housing Shortage")
    end
  end

  it "renders stances through the same shells" do
    stance = create(:stance)

    get stances_path
    expect(response.body).to include("id=\"list_item_stance_#{stance.id}\"")

    get stance_path(stance)
    expect(response.body).to include("<h1>Showing stance</h1>")
  end
end
