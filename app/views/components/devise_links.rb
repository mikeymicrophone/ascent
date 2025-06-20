class Views::Components::DeviseLinks < Views::ApplicationView
  def initialize(current_voter: nil)
    @current_voter = current_voter
  end

  def view_template
    div(class: "devise-links") do
      if @current_voter
        authenticated_links
      else
        unauthenticated_links
      end
    end
  end

  private

  def authenticated_links
    span(class: "voter-greeting") { "Hello, #{@current_voter.first_name}" }
    link_to "Profile", edit_voter_path(@current_voter), class: "nav-link"
    link_to "Sign Out", destroy_voter_session_path, 
            method: :delete, 
            class: "nav-link",
            data: { "turbo-method": :delete }
  end

  def unauthenticated_links
    link_to "Sign In", new_voter_session_path, class: "nav-link"
    link_to "Sign Up", new_voter_registration_path, class: "nav-link"
  end
end