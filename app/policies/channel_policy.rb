# frozen_string_literal: true

class ChannelPolicy < ApplicationRecordPolicy
  def index?
    reviewer?
  end

  def update?
    reviewer?
  end
end
