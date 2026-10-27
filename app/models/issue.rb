class Issue < ApplicationRecord
  include Engageable

  belongs_to :topic
  has_many :approaches
  has_many :stances, through: :approaches

  alias_attribute :name, :title

  scope :by_topic, ->(topic_id) { where(topic_id: topic_id) if topic_id.present? }
end
