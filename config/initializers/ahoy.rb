class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = true

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false

Ahoy.user_method = :current_voter
Ahoy.mask_ips = true
Ahoy.track_bots = Rails.env.test?
Ahoy.exclude_method = ->(controller, request) do
  request.cookie_jar[:ascent_analytics_exclude] == "1" || controller&.send(:current_voter)&.can_review?
end
