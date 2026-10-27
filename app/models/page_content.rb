# frozen_string_literal: true

class PageContent
  CONTENT_DIR = Rails.root.join("config", "content")

  def self.load(name)
    YAML.safe_load_file(CONTENT_DIR.join("#{name}.yml"), aliases: true).deep_symbolize_keys
  end
end
