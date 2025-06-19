# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Development Server
- `bin/dev` - Start development server with Foreman (runs Rails server + Tailwind CSS watcher)
- `bin/rails server` - Start Rails server only
- `bin/rails tailwindcss:watch` - Start Tailwind CSS watcher only

### Testing
- `bundle exec rspec` - Run all tests
- `bundle exec rspec spec/path/to/file_spec.rb` - Run specific test file
- `bundle exec rspec spec/path/to/file_spec.rb:line_number` - Run specific test

### Database
- `bin/rails db:create` - Create databases
- `bin/rails db:migrate` - Run migrations
- `bin/rails db:seed` - Seed database
- `bin/rails db:reset` - Drop, create, migrate, and seed

### Code Quality
- `bin/rubocop` - Run Ruby linter (uses Omakase styling)
- `bin/brakeman` - Run security scanner

### Asset Management
- `bin/rails assets:precompile` - Precompile assets for production

## Architecture Overview

### Core Technology Stack
- **Rails 8.0+** with modern Rails conventions
- **Phlex** for view components instead of ERB templates
- **Tailwind CSS** with semantic class approach (NO direct Tailwind in markup)
- **Stimulus** for JavaScript interactions
- **PostgreSQL** with multiple databases (main, jobs, caching, ActionCable)
- **RSpec** with FactoryBot for testing

### View Architecture
The project uses Phlex components instead of traditional ERB views:

```
app/views/
├── components/
│   ├── ui/              # Reusable UI components
│   ├── forms/           # Form-specific components
│   └── layouts/         # Layout components
└── pages/               # Page-specific Phlex views
```

Key Phlex patterns:
- Use initializers to set instance variables from arguments
- Objects can be inferred from local variables or methods
- Template named arguments should match variable names

### CSS Architecture
Unique four-layer Tailwind approach using semantic classnames:

1. **Layout Layer** - Flex, positioning, responsive design
2. **Spacing/Size Layer** - Element spacing, sizing, responsive
3. **Typography/Colors Layer** - Fonts, colors via CSS variables
4. **State Layer** - Hover, focus, active states

**Critical**: Apply Tailwind classes using `@apply` directive, never directly in markup. Use semantic classnames and IDs.

### Testing Strategy
- Write tests before implementation when possible
- Use FactoryBot with highly descriptive data (serves as documentation)
- Use Shoulda Matchers for common Rails validations
- Don't test ActiveRecord macros, focus on compound interactions
- Multiple factory options with descriptive data for domain understanding

### Controller Patterns
- Use service objects for complex business logic
- Define most methods on relevant models
- Use local variables instead of instance variables (Phlex doesn't require @variables)

### JavaScript/Stimulus Conventions
- Encapsulate element condition checks in descriptively-named methods
- Encapsulate element modifications in descriptively-named methods  
- Trigger modifications via CSS (adding/removing classes or data attributes)
- Use wrapped console.log method that respects log levels

## Code Style

### Ruby Style (RuboCop Omakase)
- Minimize parentheses usage as indicator of line complexity
- Call methods directly on results rather than storing in variables for single use
- Create separate methods for complex logic (if/case statements)
- Don't preemptively check for nil or data structure types

### View Helpers
- Make heavy use of view helpers to encapsulate markup structure
- Keep helpers simple and reusable, but don't over-engineer flexibility
- Create helpers even for single-use cases for readability
- Use `safe_join` for arrays when nesting isn't necessary
- Use tag helpers with blocks and concatenation (+ operator)
- All methods in concatenation must use parentheses
- Add `.html_safe` to objects in concatenation when needed

## Important Documentation

**Always reference the comprehensive coding conventions in `doc/llm-assistant/conventions/`:**
- `ruby-rails.md` - Testing, controller, model, view helper, and Phlex conventions
- `javascript-stimulus.md` - Stimulus controller patterns and logging
- `css-tailwind.md` - Four-layer CSS architecture and semantic classname approach
- `database-postgresql.md` - Database conventions and patterns

Additional context available in `doc/llm-assistant/`:
- `tech-stack.md` - Core technology decisions and anti-patterns
- `patterns/` - Service objects, form objects, decorators
- `project-context/` - Architecture, deployment, testing context
- `approval-voting-prd.md` - Product requirements for the voting features

## Project Context

This is a political science/voting application called "Ascent" focused on approval voting systems. The application follows Rails conventions with modern architectural patterns emphasizing component reusability, mobile-first design, and semantic HTML structure.