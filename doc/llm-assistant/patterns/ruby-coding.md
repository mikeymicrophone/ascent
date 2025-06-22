## ActiveRecord

### Scopes
Scopes are used to define reusable query logic. They are defined in the model and can be chained together to create complex queries.
They can also be referenced in other ActiveRecord models' scopes.

### Methods
- method name ends in ? if it returns a boolean
- method name ends in ! if it modifies the object
- method name ends in = if it sets the value of an attribute
- attr_accessor for attributes that do not need to go to the database
- delegates for methods that logically pertain to the model but are on the associated model
- do not prefix with get_ or set_ or render_, just treat barewords as if they can be either variables or methods

### Short-circuiting

Short-circuiting refers to conditional logic that exits early when certain conditions are met, often using patterns like:
- `return unless condition`
- `return nil if object.nil?`
- `object&.method` (safe navigation)
- `condition && action`

The above examples are somewhat acceptable, but only in a situation where we know that nil IS a possibility.

If a check / conditional is needed, it may be worthwhile to encapsulate it in a new method.

Postfixing a conditional is fine (remember that Ruby has `unless` and `until` as well as `if` and `while`).

When a conditional is used to begin a block, this is the approach that I dislike the most.  It is not as readable as the other approaches.

Do not check for `respond_to?` when not needed.  If we develop a display structure that can operate on disparate objects with differently-named attributes, we may be able to wrap them both in a convenience method or alias.
One good example of this is how every model has a `name` method, even if it is not a database column.  We can use this to our advantage.

**General principle**: This is an optimization approach that we will only want once we get to a point where we need it.

There are many places where nil checks and early returns appear in code, but these should be avoided until we have a clear need for them. The codebase will develop a systematic approach to handling these cases as patterns emerge.

**Current approach**: Trust that objects have the methods and data they should have. Let errors surface naturally rather than preemptively guarding against them.

**Future development**: This section will evolve to document the specific patterns and approaches we develop for handling nil cases and early returns as the need arises.

### Examples

#### Number 1: domain logic in models

Don't do this:
```ruby
class Views::Offices::OfficePartial < Views::ApplicationView
  def get_current_office_holder
    # Find the most recent completed election and return the winner
    # Using the completed scope from Election model
    most_recent_completed = @office.elections
                                    .completed
                                    .order(election_date: :desc)
                                    .first

    return nil unless most_recent_completed

    most_recent_completed.approval_winner
  end
end
```

Do this:
```ruby
class Office < ApplicationRecord
  def recent_election
    elections.completed.recent.first
  end

  def current_office_holder
    recent_election&.approval_winner
  end
end
```

#### Number 2: reusable view methods in Phlex components

Don't do this:
```ruby
class Views::Offices::OfficePartial < Views::ApplicationView
  private

  def render_current_office_holder
    current_winner = @office.current_office_holder
    # ... markup logic
  end
end
```

Do this:
```ruby
class Views::Offices::OfficePartial < Views::ApplicationView
  def current_office_holder(office = @office)
    current_winner = office.current_office_holder
    # ... markup logic
  end
end
```

This approach:
- Removes unnecessary `render_` prefix
- Makes methods public for reusability across components  
- Uses default arguments (not named arguments) for easier calling
- Converts instance variables to parameters for flexibility

#### Number 3: blocks that contain a single method

Don't do this:
```ruby
@sections.each do |section|
  nav_section(section)
end
```

Do this:
```ruby
@sections.each { nav_section it }
```

This approach:
- Removes unnecessary `do` and `end` blocks
- Makes code more concise and readable
- reduces the number of variables we have to name