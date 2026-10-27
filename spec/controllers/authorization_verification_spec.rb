require 'rails_helper'

# An action that authorizes nothing raises, so a new controller cannot skip its policy by accident.
RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      head :ok
    end
  end

  it "raises when an action authorizes nothing" do
    expect { get :index }.to raise_error(ActionPolicy::UnauthorizedAction)
  end
end
