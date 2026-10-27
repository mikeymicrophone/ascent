# frozen_string_literal: true

# Dates shown to visitors, e.g. "November 3, 2026". Use with `to_fs(:display)`.
Date::DATE_FORMATS[:display] = "%B %-d, %Y"
Time::DATE_FORMATS[:display] = "%B %-d, %Y"
