# frozen_string_literal: true

module Views
  module Mountains
    extend Phlex::Kit

    def max_height
      320
    end

    def calculate_label_position(value)
      (max_height - (value.to_f / 500.0 * max_height)).to_i
    end

    # Keep class methods for backward compatibility
    def self.max_height
      320
    end

    def self.calculate_label_position(value)
      (max_height - (value.to_f / 500.0 * max_height)).to_i
    end
  end
end