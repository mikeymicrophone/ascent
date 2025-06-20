# Pagy initializer file (6.4.4)
# Customize only what you really need but notice that Pagy works also without any of the following lines.
# Should you just cherry pick part of this file, please maintain the require-order.

# Pagy DEFAULT values (they do not require a previous require)
# https://ddnexus.github.io/pagy/docs/api/pagy#variables
# As any other Pagy::DEFAULT variables, they can be:
# - overridden by the @pagy_* controller instance variables
# - customized by the variables argument in the #pagy* methods

# Items per page
Pagy::DEFAULT[:limit] = 25

# Other useful common options
# See https://ddnexus.github.io/pagy/docs/api/pagy#variables
# Pagy::DEFAULT[:size]       = 9                        # Nav bar links
# Pagy::DEFAULT[:page_param] = :page                    # page param name
# Pagy::DEFAULT[:params]     = {}                       # Query string params
# Pagy::DEFAULT[:fragment]   = '#fragment'              # URL fragment
# Pagy::DEFAULT[:link_extra] = 'data-remote="true"'     # page links extra

# Extras
# See https://ddnexus.github.io/pagy/docs/extras

# Backend Extras

# Arel extra: For better performance utilizing grouped ActiveRecord collections:
# See: https://ddnexus.github.io/pagy/docs/extras/arel
# require 'pagy/extras/arel'

# Array extra: Paginate arrays efficiently, avoiding expensive array-wrapping and without overriding
# See https://ddnexus.github.io/pagy/docs/extras/array
# require 'pagy/extras/array'

# Calendar extra: Add pagination filtering by calendar time unit (year, quarter, month, week, day)
# See https://ddnexus.github.io/pagy/docs/extras/calendar
# require 'pagy/extras/calendar'

# Countless extra: Paginate without the need of any count, saving one query per rendering
# See https://ddnexus.github.io/pagy/docs/extras/countless
# require 'pagy/extras/countless'

# Elasticsearch Rails extra: Paginate `ElasticsearchRails::Results` objects
# See https://ddnexus.github.io/pagy/docs/extras/elasticsearch_rails
# require 'pagy/extras/elasticsearch_rails'

# Headers extra: http response headers (and other helpers) useful for API pagination
# See http://ddnexus.github.io/pagy/docs/extras/headers
# require 'pagy/extras/headers'

# Meilisearch extra: Paginate `Meilisearch` result objects
# See https://ddnexus.github.io/pagy/docs/extras/meilisearch
# require 'pagy/extras/meilisearch'

# Metadata extra: Provides the pagination metadata to Javascript frameworks like Vue.js, react.js, etc.
# See https://ddnexus.github.io/pagy/docs/extras/metadata
# require 'pagy/extras/metadata'

# Searchkick extra: Paginate `Searchkick::Results` objects
# See https://ddnexus.github.io/pagy/docs/extras/searchkick
# require 'pagy/extras/searchkick'

# Frontend Extras

# Tailwind extra: Add nav, nav_js and combo_nav_js helpers and templates for Tailwind pagination
# See https://ddnexus.github.io/pagy/docs/extras/tailwind
# require 'pagy/extras/tailwind' # Using custom Tailwind CSS instead

# Bootstrap extra: Add nav, nav_js and combo_nav_js helpers and templates for Bootstrap pagination
# See https://ddnexus.github.io/pagy/docs/extras/bootstrap
# require 'pagy/extras/bootstrap'

# Bulma extra: Add nav, nav_js and combo_nav_js helpers and templates for Bulma pagination
# See https://ddnexus.github.io/pagy/docs/extras/bulma
# require 'pagy/extras/bulma'

# Foundation extra: Add nav, nav_js and combo_nav_js helpers and templates for Foundation pagination
# See https://ddnexus.github.io/pagy/docs/extras/foundation
# require 'pagy/extras/foundation'

# Materialize extra: Add nav, nav_js and combo_nav_js helpers and templates for Materialize pagination
# See https://ddnexus.github.io/pagy/docs/extras/materialize
# require 'pagy/extras/materialize'

# Navs extra: Add nav_js and combo_nav_js javascript helpers
# Notice: the other frontend extras add their own framework-styled versions,
# so require this extra only if you need the unstyled version
# See https://ddnexus.github.io/pagy/docs/extras/navs
# require 'pagy/extras/navs'

# Semantic extra: Add nav, nav_js and combo_nav_js helpers and templates for Semantic UI pagination
# See https://ddnexus.github.io/pagy/docs/extras/semantic
# require 'pagy/extras/semantic'

# UIkit extra: Add nav, nav_js and combo_nav_js helpers and templates for UIkit pagination
# See https://ddnexus.github.io/pagy/docs/extras/uikit
# require 'pagy/extras/uikit'

# Multi size var used by the *_nav_js helpers
# See https://ddnexus.github.io/pagy/docs/extras/navs#steps
# Pagy::DEFAULT[:steps] = { 0 => 5, 540 => 7, 720 => 9 }

# Feature Extras

# Gearbox extra: Automatically change the number of items per page depending on the page number
# See https://ddnexus.github.io/pagy/docs/extras/gearbox
# require 'pagy/extras/gearbox'
# uncomment the next line to globally disable gearbox
# Pagy::DEFAULT[:gearbox_extra] = false               # default true

# Limit extra: Allow the client to request a custom number of items per page with an optional selector UI
# See https://ddnexus.github.io/pagy/docs/extras/limit
# require 'pagy/extras/limit'
# Pagy::DEFAULT[:limit_extra] = true                  # default true
# Pagy::DEFAULT[:limit_max]   = 100                   # default 100

# Overflow extra: Allow for easy handling of overflowing pages
# See https://ddnexus.github.io/pagy/docs/extras/overflow
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page                 # default  (other options: :last_page and :empty_page)

# Support extra: Extra support for features like: incremental, infinite, auto-scroll pagination
# See https://ddnexus.github.io/pagy/docs/extras/support
# require 'pagy/extras/support'

# Trim extra: Remove the page=1 param from links
# See https://ddnexus.github.io/pagy/docs/extras/trim
# require 'pagy/extras/trim'
# after requiring the extra trim extra is disabled by default and can be enabled for specific requests
# Pagy::DEFAULT[:trim_extra] = false                  # default true

# Standalone extra: Use pagy in non Rack environments/gems
# See https://ddnexus.github.io/pagy/docs/extras/standalone
# require 'pagy/extras/standalone'
# Pagy::DEFAULT[:url] = 'http://www.example.com/subdir'  # required