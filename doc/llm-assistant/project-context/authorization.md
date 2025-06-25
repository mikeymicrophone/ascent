# Authorization System

## Overview

The Ascent application uses [ActionPolicy](https://actionpolicy.evilmartians.io/) for authorization. The system is designed to accommodate future user types while currently supporting only `Voter` authentication through Devise.

## Current Configuration

### Authorization Context

The application is configured with `:voter` as the authorization context in `ApplicationController`:

```ruby
include ActionPolicy::Controller
authorize :voter, through: :current_voter
```

This setup allows policies to access the current voter through the `voter` method within policy classes.

### User Types

**Current:** 
- `Voter` - Authenticated users who can participate in elections and rating systems

**Future Planned:**
- `Candidate` - Users who can be rated and participate as candidates
- `Staffer` - Administrative users with elevated permissions
- Additional user types as needed

## Policies

### Base Policy

`ApplicationPolicy` serves as the base class for all authorization policies, inheriting from `ActionPolicy::Base`.

### Implemented Policies

#### GoverningBodyPolicy

**Purpose:** Demonstrates authorization restrictions for governing bodies.

**Rules:**
- Voters can view (`index?`/`show?`) governing bodies
- Voters can create (`create?`/`new?`) governing bodies  
- Voters can edit (`edit?`/`update?`) governing bodies
- **Voters cannot delete (`destroy?`) governing bodies** ← Key restriction

**Implementation:**
```ruby
class GoverningBodyPolicy < ApplicationPolicy
  def destroy?
    false  # Voters cannot delete governing bodies
  end
  
  # Other actions default to true
end
```

## UI Integration

### ResourceActions Component

The `Views::Components::Ui::ResourceActions` component automatically respects authorization rules:

**Location:** `app/views/components/ui/resource_actions.rb`

**Authorization Check:**
```ruby
def can_destroy?
  begin
    authorized_to?(:destroy?, @resource)
  rescue ActionPolicy::UnknownPolicy
    # If no policy exists for this resource, allow destruction by default
    true
  end
end
```

**Behavior:**
- If a policy exists: Respects the policy's `destroy?` method
- If no policy exists: Defaults to allowing destruction (maintains backward compatibility)
- Destroy button only renders if `can_destroy?` returns `true`

### Graceful Degradation

The system is designed to work with resources that don't have policies yet:

1. **With Policy:** Honors the policy's authorization rules
2. **Without Policy:** Defaults to permissive behavior (allows all actions)
3. **Error Handling:** Catches `ActionPolicy::UnknownPolicy` exceptions gracefully

## Implementation Status

### Completed
- ✅ ActionPolicy gem installed and configured
- ✅ Authorization context set to `:voter`
- ✅ `GoverningBodyPolicy` created with deletion restriction
- ✅ `ResourceActions` component updated with authorization checks
- ✅ Backward compatibility maintained for resources without policies

### Testing Strategy

The authorization system can be tested by:

1. **Governing Bodies:** Delete button should be hidden for all governing body resources
2. **Other Resources:** Delete button should still appear (no policies exist yet)
3. **Future Policies:** Can be added incrementally without breaking existing functionality

## Future Expansion

### Adding New User Types

When adding new user types (Candidate, Staffer, etc.):

1. Create the corresponding Devise model
2. Update `ApplicationController` to handle multiple authorization contexts
3. Create specific policies for each user type
4. Update the UI components to handle different user permissions

### Creating New Policies

For each new resource policy:

1. Inherit from `ApplicationPolicy`
2. Define action methods (`index?`, `show?`, `create?`, `edit?`, `destroy?`)
3. Use the `voter` context to make authorization decisions
4. Test the policy with both positive and negative cases

### Example Policy Template

```ruby
class ExampleResourcePolicy < ApplicationPolicy
  def index?
    true  # All voters can view the index
  end

  def show?
    true  # All voters can view individual resources
  end

  def create?
    voter.present?  # Only authenticated voters can create
  end

  def edit?
    create?  # Same as create permissions
  end

  def destroy?
    false  # Voters cannot delete (modify as needed)
  end
end
```

## Best Practices

1. **Default Permissive:** Start with allowing actions, then restrict as needed
2. **Explicit Policies:** Create policies for resources that need restrictions
3. **Backward Compatibility:** Ensure new policies don't break existing functionality
4. **Test Coverage:** Write tests for both allowed and denied actions
5. **User Experience:** Provide clear feedback when actions are restricted

## Related Files

- `app/controllers/application_controller.rb` - Authorization configuration
- `app/policies/application_policy.rb` - Base policy class
- `app/policies/governing_body_policy.rb` - Example policy implementation
- `app/views/components/ui/resource_actions.rb` - UI authorization integration
- `lib/generators/phlex_scaffold/templates/` - Scaffold templates use ResourceActions