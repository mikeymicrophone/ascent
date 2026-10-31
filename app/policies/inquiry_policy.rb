# frozen_string_literal: true

class InquiryPolicy < ApplicationPolicy
  def new?
    true
  end

  def create?
    true
  end
end
