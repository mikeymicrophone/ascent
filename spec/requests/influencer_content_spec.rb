require "rails_helper"

RSpec.describe "Influencer links and statements", type: :request do
  let(:voter) { create(:voter) }
  let(:neighbor) { create(:voter) }

  def page
    Nokogiri::HTML(response.body)
  end

  it "lets any voter manage their own collections before inviting anyone or going public" do
    sign_in voter
    get edit_voter_path(voter)
    expect(page.at_css("a[href='#{influencer_profile_path}']")).to be_present
    get influencer_profile_path, params: { voter_id: neighbor.id }

    expect(response).to have_http_status(:ok)
    expect(page.at_css("form[action='#{voter_links_path}']")).to be_present
    expect(page.at_css("form[action='#{voter_statements_path}']")).to be_present
    expect(voter).not_to be_public_influencer
    expect(voter.invites).to be_empty
  end

  [ VoterLink, VoterStatement ].each do |model|
    context model.name do
      let(:key) { model.model_name.param_key }
      let(:attributes) { model == VoterLink ? { label: "Community guide", url: "https://example.com/guide" } : { body: "Give every voter a meaningful voice." } }
      let(:changed_attributes) { model == VoterLink ? { label: "Voting guide", url: "https://example.com/voting" } : { body: "Make local government easier to understand." } }
      let(:invalid_attributes) { model == VoterLink ? { label: "Keep this label", url: "javascript:alert(1)" } : { body: " " } }
      let(:item) { model.create!(voter: voter, **attributes) }
      let(:collection_path) { polymorphic_path(model) }

      it "adds content owned by the signed-in voter and ignores ownership and order parameters" do
        sign_in voter
        expect do
          post collection_path, params: { key => attributes.merge(voter_id: neighbor.id, position: 99, active: "1") }
        end.to change(model, :count).by(1)

        expect(response).to have_http_status(:see_other)
        expect(model.last).to have_attributes(voter: voter, active: true, position: 1)
      end

      it "edits, deactivates, and reactivates existing content" do
        sign_in voter
        patch polymorphic_path(item), params: { key => changed_attributes.merge(active: "0") }

        expect(response).to have_http_status(:see_other)
        expect(item.reload).to have_attributes(**changed_attributes, active: false)
        get influencer_profile_path
        expect(page.at_css("##{key}_#{item.id}").text).to include("Inactive")

        patch polymorphic_path(item), params: { key => { active: "1" } }
        expect(item.reload).to be_active
      end

      it "shows validation errors and submitted content when adding or editing fails" do
        sign_in voter
        expect do
          post collection_path, params: { key => invalid_attributes }
        end.not_to change(model, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(page.at_css("[role='alert']")).to be_present
        if model == VoterLink
          expect(page.at_css("input[name='#{key}[label]']")["value"]).to eq("Keep this label")
        end

        original_attributes = item.attributes
        patch polymorphic_path(item), params: { key => invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(page.css("form[action='#{polymorphic_path(item)}']").size).to eq(1)
        expect(page.at_css("[role='alert']")).to be_present
        expect(item.reload.attributes).to eq(original_attributes)
      end

      it "reorders only the signed-in voter's matching collection" do
        first = item
        second = model.create!(voter: voter, **changed_attributes)
        other_owner_item = model.create!(voter: neighbor, **attributes)
        sign_in voter

        patch polymorphic_path([ :move, second ]), params: { direction: "up" }
        expect(response).to have_http_status(:see_other)
        expect(model.where(voter: voter).ordered).to eq([ second, first ])
        expect(other_owner_item.reload.position).to eq(1)

        patch polymorphic_path([ :move, second ]), params: { direction: "down" }
        expect(model.where(voter: voter).ordered).to eq([ first, second ])
        patch polymorphic_path([ :move, second ]), params: { direction: "sideways" }
        expect(response).to have_http_status(:bad_request)
        expect(model.where(voter: voter).ordered).to eq([ first, second ])
      end

      it "prevents other voters, including admins, from editing or reordering the collection" do
        original = item.attributes
        [ neighbor, create(:admin_voter) ].each do |visitor|
          sign_in visitor
          patch polymorphic_path(item), params: { key => changed_attributes }
          expect(response).to redirect_to(root_path)
          patch polymorphic_path([ :move, item ]), params: { direction: "up" }
          expect(response).to redirect_to(root_path)
        end
        expect(item.reload.attributes).to eq(original)
      end

      it "requires sign-in for adding, editing, and reordering content" do
        existing = item
        expect do
          post collection_path, params: { key => attributes }
        end.not_to change(model, :count)
        expect(response).to redirect_to(new_voter_session_path)
        patch polymorphic_path(existing), params: { key => changed_attributes }
        expect(response).to redirect_to(new_voter_session_path)
        patch polymorphic_path([ :move, existing ]), params: { direction: "up" }
        expect(response).to redirect_to(new_voter_session_path)
        expect(existing.reload).to have_attributes(**attributes)
      end
    end
  end

  it "requires sign-in to open the content editor" do
    get influencer_profile_path
    expect(response).to redirect_to(new_voter_session_path)
  end

  it "shows only active content in saved order inside collapsed sections above Connect" do
    voter.update!(public_influencer: true)
    voter.invites.create!(invitee: neighbor)
    first_link = voter.voter_links.create!(label: "Town meetings", url: "https://example.com/town")
    voter.voter_links.create!(label: "Private notes", url: "https://example.com/private", active: false)
    last_link = voter.voter_links.create!(label: "Voter guide", url: "https://example.com/voters")
    last_link.move!("up")
    last_link.move!("up")
    first_statement = voter.voter_statements.create!(body: "Start with local issues.")
    voter.voter_statements.create!(body: "Unpublished statement", active: false)
    last_statement = voter.voter_statements.create!(body: "Every voter deserves a voice.\n<script>alert('unsafe')</script>")
    last_statement.move!("up")
    last_statement.move!("up")
    other = neighbor.voter_links.create!(label: "Another voter's link", url: "https://example.com/other")
    sign_in create(:voter)

    get influencer_path(token: voter.invite_token)

    expect(response).to have_http_status(:ok)
    links = page.at_css("details#influencer-links")
    statements = page.at_css("details#influencer-statements")
    expect(links["open"]).to be_nil
    expect(statements["open"]).to be_nil
    expect(links.css("li a").map(&:text)).to eq([ last_link.label, first_link.label ])
    expect(links.at_css("a")["rel"]).to include("noopener", "noreferrer")
    expect(statements.css("li p").map(&:text)).to eq([ last_statement.body, first_statement.body ])
    expect(statements.css("script")).to be_empty
    expect(response.body).not_to include("Private notes", "https://example.com/private", "Unpublished statement", other.label)
    expect(response.body.index('id="influencer-links"')).to be < response.body.index('id="influencer-statements"')
    expect(response.body.index('id="influencer-statements"')).to be < response.body.index('action="/invites"')
  end

  it "does not reveal content for a private influencer" do
    allow(Rails.application).to receive(:env_config).and_return(
      Rails.application.env_config.merge("action_dispatch.show_detailed_exceptions" => false)
    )
    voter.invites.create!(invitee: neighbor)
    voter.voter_statements.create!(body: "Private civic priorities")
    get influencer_path(token: voter.invite_token)

    expect(response).to have_http_status(:not_found)
    expect(response.body).not_to include("Private civic priorities")
  end
end
