class Views::Topics::TopicForm < Views::ApplicationView
  def initialize(topic:)
    @topic = topic
  end

  def view_template(&)
    form_with(model: @topic, id: dom_id(@topic, :form)) do |form|
      FormErrors(record: @topic)
      
      div do
        form.label :title
        form.text_field :title,
                                        class: input_classes(@topic.errors[:title])
      end

      div do
        form.label :description
        form.textarea :description,
                                        rows: 4,
                                        class: input_classes(@topic.errors[:description])
      end

      div do
        form.submit class: "primary"
      end
    end
  end

  private

  def input_classes(errors)
    errors.any? ? "error" : ""
  end
end