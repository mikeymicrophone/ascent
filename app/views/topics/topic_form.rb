class Views::Topics::TopicForm < Views::ApplicationView
  def initialize(topic:)
    @topic = topic
  end

  def view_template(&)
    form_with(model: @topic, id: dom_id(@topic, :form)) do |form|
      render_errors if @topic.errors.any?
      
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

  def render_errors
    div(id: "error_explanation") do
      h2 { "#{pluralize(@topic.errors.count, 'error')} prohibited this topic from being saved:" }
      
      ul(class: "list-disc ml-6") do
        @topic.errors.each do |error|
          li { error.full_message }
        end
      end
    end
  end

  def input_classes(errors)
    errors.any? ? "error" : ""
  end

  def checkbox_classes(errors)
    errors.any? ? "error" : ""
  end
end