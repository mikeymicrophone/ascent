class Views::Components::ItemPreview < Views::ApplicationView
  def initialize(
    items:,
    limit:,
    container_class:,
    item_class:,
    view_all_class:,
    view_all_text: nil,
    view_all_path: nil,
    &item_renderer
  )
    @items = items
    @limit = limit
    @container_class = container_class
    @item_class = item_class
    @view_all_class = view_all_class
    @view_all_text = view_all_text
    @view_all_path = view_all_path
    @item_renderer = item_renderer
  end

  def view_template(&)
    div(class: @container_class) do
      render_items
      render_view_all_link if should_show_view_all?
    end
  end

  private

  def render_items
    items_to_show = @items.respond_to?(:limit) ? @items.limit(@limit) : @items.first(@limit)
    items_to_show.each do |item|
      div(class: @item_class) do
        @item_renderer.call(item)
      end
    end
  end

  def should_show_view_all?
    @view_all_text && @view_all_path && total_count > @limit
  end

  def render_view_all_link
    div(class: @view_all_class) do
      link_to @view_all_text, @view_all_path, class: "link view-all"
    end
  end

  def total_count
    @items.respond_to?(:count) ? @items.count : @items.size
  end
end