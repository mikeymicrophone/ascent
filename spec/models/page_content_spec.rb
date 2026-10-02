# frozen_string_literal: true

require "rails_helper"

RSpec.describe PageContent do
  describe ".load" do
    it "loads the approval voting page copy" do
      page = described_class.load("approval_voting")

      expect(page.fetch(:hero)).to include(:kicker, :title, :lead, :actions)
      expect(page.fetch(:sections)).to all(include(:type))
      expect(page.dig(:hero, :actions)).to all(include(:text, :path, :style))
    end
  end
end
