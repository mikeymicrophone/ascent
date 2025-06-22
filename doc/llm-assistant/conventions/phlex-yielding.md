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

## Advanced Yielding Patterns: Real Examples

### Interface Yielding: Navigation Component

Our `Navigation` component demonstrates **Interface Yielding**, where the component provides a builder interface for flexible composition:

```ruby
class Views::Components::Navigation < Views::ApplicationView
  def view_template(&block)
    if block
      yield(NavigationBuilder.new(self))  # Pass builder to calling code
    else
      render_default_navigation
    end
    
    nav(class: "main-navigation") do
      @sections.each { |section| render_nav_section(section) }
    end
  end

  def add_section(title, &block)
    section = NavigationSection.new(title)
    yield(section) if block
    @sections << section
  end

  class NavigationBuilder
    def section(title, &block)
      @navigation.add_section(title, &block)
    end
  end
end
```

**Usage:**
```ruby
Views::Components::Navigation() do |nav|
  nav.section("Custom Section") do |section|
    section.link("Special Link", custom_path)
    section.link("Another Link", other_path)
  end
end
```

**Key Advantage:** Interface yielding provides **declarative composition** - callers describe what they want using a fluent, domain-specific interface rather than manually building HTML structures. This makes the component more intuitive and prevents structural mistakes.

### Vanishing Yield: Mountain Chart Component

Our `MountainChart` component demonstrates **Vanishing Yield**, where the yield collects configuration before rendering:

```ruby
class Views::Mountains::MountainChart < Views::Components::Base
  def view_template(&block)
    if block
      vanish(&block)  # Collect candidacy data without immediate rendering
    end
    
    div(class: "mountain-chart") do
      # Render collected data after vanish completes
      @candidacies.each do |candidacy_data|
        render Views::Mountains::CandidateColumn.new(candidacy_data)
      end
    end
  end

  def candidacy(candidacy, rating: 0, approved: false)
    # Store data for later rendering
    @candidacies << { candidacy: candidacy, rating: rating, approved: approved }
    nil  # Return nil - this doesn't render immediately
  end

  private

  def vanish(&block)
    yield(self) if block  # Collect configuration calls
  end
end
```

**Usage:**
```ruby
Views::Mountains::MountainChart(election: @election) do |chart|
  chart.candidacy(candidacy_a, rating: 400, approved: true)
  chart.candidacy(candidacy_b, rating: 250, approved: false)
  chart.candidacy(candidacy_c, rating: 350, approved: true)
end
```

**Key Advantage:** Vanishing yield enables **delayed rendering with validation** - the component can collect all configuration first, then validate completeness, apply business rules, or optimize rendering order before generating any HTML. This prevents partially-rendered components when data is incomplete.

## Reference

For more details on Phlex yielding patterns, see the official documentation:
[Phlex Components: Yielding](https://www.phlex.fun/components/yielding.html)

## Common Pitfalls

- **Symptom**: "undefined method" errors when calling other components in blocks
- **Cause**: Using `instance_eval` instead of `yield`
- **Solution**: Convert to the proper yielding pattern shown above
- **Result**: Blocks execute in the correct context with access to all view methods