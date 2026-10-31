# frozen_string_literal: true

class ErrorsController < ApplicationController
  # Public error pages, with no record to authorize.
  skip_verify_authorized

  ERRORS = {
    404 => :not_found,
    500 => :internal_server_error
  }.freeze

  def show
    status = request.path_info.delete_prefix("/").to_i
    status = 500 unless ERRORS.key?(status)

    render Views::Errors::ShowView.new(
      page: PageContent.load("errors").fetch(ERRORS.fetch(status))
    ), status: status
  end
end
