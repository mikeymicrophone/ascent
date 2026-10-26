require "rails_helper"

# Any signed-in voter can make a mock election; only its creator or an admin can remove it.
RSpec.describe "Mock elections", type: :request do
  let(:teacher) { create(:voter, first_name: "Imani", last_name: "Brooks") }
  let(:city) { create(:jurisdiction, jurisdictionable: create(:municipality, name: "Port Merritt")) }
  let(:params) do
    { mock_election: { name: "School board, classroom edition", election_date: "2026-11-17", jurisdiction_id: city.id,
                       races: [ { title: "School Board", candidates: "Avery Lin\nJordan Okafor-Reyes" }, { title: "", candidates: "" } ] } }
  end

  it "lets a signed-in voter make one" do
    sign_in teacher

    expect { post mock_elections_path, params: params }.to change(Election.mock, :count).by(1)
    expect(response).to redirect_to(election_path(Election.created_by(teacher).sole))
  end

  it "sends a visitor who is not signed in to sign in" do
    expect { post mock_elections_path, params: params }.not_to change(Election, :count)
    expect(response).to redirect_to(new_voter_session_path)
  end

  it "lets only the creator remove it" do
    election = MockElection.new(**params[:mock_election], races: [ { title: "School Board", candidates: [ "Avery Lin", "Jordan Okafor-Reyes" ] } ],
                                creator: teacher).save!

    sign_in create(:voter)
    expect { delete mock_election_path(election) }.not_to change(Election, :count)

    sign_in teacher
    expect { delete mock_election_path(election) }.to change(Election, :count).by(-1)
  end

  it "never removes a real election" do
    sign_in create(:voter, admin: true)
    real = create(:election)

    expect { delete mock_election_path(real) }.not_to change(Election, :count)
  end
end
