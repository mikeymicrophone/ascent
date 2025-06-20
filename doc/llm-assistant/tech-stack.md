# Ascent Project - Technology Stack
> Instructions for LLM code assistants working on the Ascent project

## Core Technologies

### Backend Framework
- **Ruby on Rails** - Primary application framework
- Follow Rails conventions and best practices
- Use Rails 7+ features where appropriate
- Prefer convention over configuration

### Frontend Technologies
- **Tailwind CSS** - Utility-first CSS framework for styling
- **Stimulus** - JavaScript framework for progressive enhancement
- **Phlex** - Ruby-based view component system (replaces ERB templates)

### Database
- **PostgreSQL** - Primary database system
- per the emerging convention, a second database is used for background jobs
- a third database is used for caching
- a fourth database is used for ActionCable

## Technology Guidelines

### View Layer - Phlex
- Use Phlex components instead of ERB templates
- Components inherit from Views::ApplicationView
- Kits are used to simplify rendering of components
- Create reusable components in `app/views/components/`
- Follow Phlex naming conventions (PascalCase classes)
- Prefer composition over inheritance for components
- Keep components focused and single-purpose

### Styling - Tailwind CSS

### JavaScript - Stimulus
- Use Stimulus controllers for JavaScript behavior
- Keep controllers small and focused on single responsibilities
- Follow Stimulus naming conventions (kebab-case for data attributes)
- Use Stimulus targets and actions appropriately
- Prefer declarative HTML over imperative JavaScript


## File Organization

### Component Structure
```
app/views/
├── components/
│   ├── ui/              # Reusable UI components
│   ├── forms/           # Form-specific components
│   └── layouts/         # Layout components
└── pages/               # Page-specific Phlex views
```

## Development Priorities

1. **Component Reusability** - Build components that can be reused across the application
2. **Mobile-First Design** - Use Tailwind's responsive utilities starting from mobile
3. **Rails Conventions** - Follow Rails patterns and conventions unless explicitly overridden

## Related Documentation

- [Ruby/Rails Conventions](conventions/ruby-rails.md)
- [Phlex Component Patterns](conventions/phlex-components.md)
- [Tailwind CSS Guidelines](conventions/tailwind-css.md)
- [Stimulus Controller Patterns](conventions/stimulus-javascript.md)
