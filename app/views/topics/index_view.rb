class Views::Topics::IndexView < Views::ApplicationView
  prop :topics, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @topics, pagy: @pagy) { TopicPartial(topic: it) }
  end
end
