module OrderedVoterContent
  extend ActiveSupport::Concern

  included do
    belongs_to :voter

    validates :active, inclusion: { in: [ true, false ] }
    validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    scope :active, -> { where(active: true) }
    scope :ordered, -> { order(:position, :id) }

    before_create :append_to_collection
  end

  def move!(direction)
    offset = { "up" => -1, "down" => 1 }.fetch(direction)
    voter.with_lock do
      items = self.class.where(voter: voter).ordered.to_a
      index = items.index { it.id == id }
      target = index + offset
      next unless target.between?(0, items.length - 1)

      previous_position = items[index].position
      update!(position: items[target].position)
      items[target].update!(position: previous_position)
    end
  end

  private

  def append_to_collection
    voter.with_lock do
      self.position = self.class.where(voter: voter).maximum(:position).to_i + 1
    end
  end
end
