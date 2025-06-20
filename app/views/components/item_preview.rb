class Views::Components::ItemPreview < Views::ApplicationView
  def initialize(parent_object, association_name, limit)
    @parent_object = parent_object
    @association_name = association_name.to_s
    @limit = limit
    @items = parent_object.send(association_name)
  end

  def view_template(&block)
    div(class: container_class) do
      render_items(&block)
      render_view_all_link if should_show_view_all?
    end
  end

  private

  def render_items(&block)
    items_to_show = @items.respond_to?(:limit) ? @items.limit(@limit) : @items.first(@limit)
    items_to_show.each do |item|
      div(class: item_class) do
        yield(item) if block
      end
    end
  end

  def should_show_view_all?
    total_count > @limit
  end

  def render_view_all_link
    div(class: view_all_class) do
      link_to view_all_text, view_all_path, class: "link view-all"
    end
  end

  def total_count
    @items.respond_to?(:count) ? @items.count : @items.size
  end

  # Derive CSS classes from association name
  def container_class
    "#{@association_name}-preview"
  end

  def item_class
    "#{@association_name.singularize}-preview-item"
  end

  def view_all_class
    "#{@association_name}-view-all"
  end

  # Derive text and path from parent object and association
  def view_all_text
    "View all #{total_count} #{@association_name}"
  end

  def view_all_path
    # Use Rails path helpers - pluralize association name for index path
    path_method = "#{@association_name}_path"
    
    # Build path with parent object filter
    parent_class = @parent_object.class.name.downcase
    parent_id_param = "#{parent_class}_id"
    
    if respond_to?(path_method)
      send(path_method, parent_id_param => @parent_object.id)
    else
      # Fallback to the association path without filtering
      send("#{@association_name}_path")
    end
  end
end