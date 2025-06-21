# Phlex Component Yielding Patterns

## Overview

When creating Phlex components that accept content blocks, use the proper yielding pattern to ensure blocks execute in the correct context. This is crucial for components that need to render other components or access view helpers from the calling view.

## The Problem: instance_eval vs yield

### ❌ Wrong: Using instance_eval

```ruby
class Views::Components::WrapperComponent < Views::ApplicationView
  def initialize(title:, &block)
    @title = title
    @content_block = block
  end

  def view_template(&)
    div(class: "wrapper") do
      h3 { @title }
      if @content_block
        instance_eval(&@content_block)  # ❌ Executes in component's context
      end
    end
  end
end
```

**Problem**: The block executes in the component's context, so it can't access methods like `Views::Components::OtherComponent(...)` or view helpers from the calling view.

### ✅ Correct: Using yield

```ruby
class Views::Components::WrapperComponent < Views::ApplicationView
  def initialize(title:)
    @title = title
  end

  def view_template(&block)
    div(class: "wrapper") do
      h3 { @title }
      yield if block  # ✅ Executes in calling view's context
    end
  end
end
```

**Solution**: The block executes in the calling view's context, allowing access to all view methods and other components.

## Real Example: ExpandableSection Component

Our `ExpandableSection` component demonstrates this pattern:

```ruby
class Views::Components::ExpandableSection < Views::ApplicationView
  def initialize(title:, count: nil, expanded: false)
    @title = title
    @count = count
    @expanded = expanded
  end

  def view_template(&block)
    div(class: "expandable-section", data: { controller: "expandable-section" }) do
      # Header with toggle button
      button(class: "expandable-header", data: { ... }) do
        div(class: "expandable-title") do
          span { @title }
          span(class: "expandable-count") { "(#{@count})" } if @count
        end
        div(class: "expandable-icon") do
          span(data: { expandable_section_target: "icon" }) { "▶" }
        end
      end
      
      # Content area that yields to the calling view
      div(class: "expandable-content", data: { ... }) do
        yield if block  # ✅ This allows nested components to work
      end
    end
  end
end
```

## Usage in Views

```ruby
# In a view partial
def render_expandable_cities
  Views::Components::ExpandableSection(
    title: "Cities",
    count: @state.cities.count
  ) do
    # This block executes in the view's context, so it can access:
    Views::Components::ItemPreview(
      items: @state.cities,
      limit: 5,
      # ... other args
    ) do |city|
      link_to city.name, city, class: "link city"
    end
  end
end
```

## Key Points

1. **Don't store blocks in instance variables** - Pass them directly to `view_template`
2. **Use `yield` instead of `instance_eval`** - This preserves the calling context
3. **Accept blocks in `view_template(&block)`** - Not in `initialize`
4. **Check for block presence** - Use `yield if block` to avoid errors

## Nested Component Patterns

When components need to render other components, the yielding pattern enables composition:

```ruby
# Parent component yields to child component
Views::Components::ExpandableSection(...) do
  Views::Components::ItemPreview(...) do |item|
    # This inner block also executes in the original view context
    link_to item.name, item, class: "link"
  end
end
```

## Reference

For more details on Phlex yielding patterns, see the official documentation:
[Phlex Components: Yielding](https://www.phlex.fun/components/yielding.html)

## Common Pitfalls

- **Symptom**: "undefined method" errors when calling other components in blocks
- **Cause**: Using `instance_eval` instead of `yield`
- **Solution**: Convert to the proper yielding pattern shown above
- **Result**: Blocks execute in the correct context with access to all view methods