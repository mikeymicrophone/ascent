# Records named by a title, such as topics, issues, approaches, policies and official codes.
module Titled
  extend ActiveSupport::Concern

  included do
    alias_attribute :name, :title

    # Records whose title contains a search, as a list's search box finds them.
    scope :titled_like, ->(query) { where("#{table_name}.title ILIKE ?", "%#{sanitize_sql_like(query.strip)}%") }
  end
end
