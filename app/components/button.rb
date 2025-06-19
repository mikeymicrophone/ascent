# frozen_string_literal: true

class Components::Button < Components::Base
  def view_template
    h1 { "Button" }
    p { "Find me in app/components/button.rb" }
  end
end
