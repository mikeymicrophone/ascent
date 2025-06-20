# Mountain Interface Architecture

## Overview
The Mountain Interface is a core visualization component of the approval voting system, displaying candidates as vertical columns with their ratings shown relative to the y-axis. This document outlines the architecture, implementation strategy, and design decisions for the mountain visualization.

## Core Concept

The "mountain" metaphor represents the approval voting landscape where:
- **Candidates** appear as vertical columns (peaks)
- **Ratings** are positioned on the y-axis (0-500 scale)
- **Baseline** appears as a horizontal line (approval threshold)
- **Voter perspective** determines which ratings are displayed

## Architecture & Data Flow

### Domain Models (Existing)

#### Election
- Central context for the mountain view
- Contains multiple candidacies
- Links to voter baselines

#### Candidacy
- Represents a candidate in a specific election
- Links person to election
- Contains ratings from multiple voters

#### Voter
- The perspective from which ratings are viewed
- Has baseline preferences per election
- Can rate each candidacy once

#### Rating
- Individual voter assessment (0-500 scale)
- Links voter to candidacy
- Core data point for mountain positioning

#### VoterElectionBaseline
- Per-election approval threshold
- Determines approval/disapproval visualization
- Displayed as horizontal line on mountain

### Data Relationships

```
Election 1:N Candidacy N:1 Person
    |           |
    |           | 1:N Rating N:1 Voter
    |                           |
    | 1:N VoterElectionBaseline N:1
```

## Implementation Strategy

### RESTful Controller Design

#### MountainsController
```ruby
# RESTful actions (no database persistence)
GET    /mountains                    # index - election selection
GET    /mountains/:election_id       # show - mountain visualization
GET    /mountains/:election_id/edit  # edit - interactive rating interface
PATCH  /mountains/:election_id       # update - batch rating updates
POST   /mountains/:election_id/simulate # simulate - run factories to generate data
```

#### URL Parameters
- `election_id` - Primary resource identifier
- `voter_id` - Query parameter for voter selection
- `baseline_visible` - Toggle baseline display
- `format` - Support for JSON/SVG export

### Phlex Component Architecture

#### View Hierarchy
```
app/views/mountains/
├── mountains.rb              # Module namespace
├── index_view.rb            # Election selection interface
├── show_view.rb             # Main mountain container
├── edit_view.rb             # Interactive rating interface
├── mountain_chart.rb        # Core visualization component
├── candidate_column.rb      # Individual candidate column
├── baseline_indicator.rb    # Horizontal baseline line
├── y_axis_labels.rb        # Vertical scale markers
├── rating_dot.rb           # Individual rating visualization
└── rating_controls.rb      # Interactive rating inputs
```

#### Component Responsibilities

**MountainChart** (Container)
- Establishes coordinate system
- Manages responsive behavior
- Coordinates child components

**CandidateColumn** (Candidate Display)
- Renders candidate information
- Positions rating dot
- Handles party affiliation styling

**BaselineIndicator** (Approval Threshold)
- Displays horizontal baseline line
- Shows approval threshold value
- Provides visual reference

**RatingDot** (Data Point)
- Positioned by rating value
- Visual states (rated/unrated)
- Color coding (approved/disapproved)

## Visual Design System

### Coordinate System

#### Y-Axis (Rating Scale)
```
500px container height
├── 500 (top) - Maximum rating
├── 400 - High approval
├── 300 - Moderate approval  
├── 200 - Neutral/baseline area
├── 100 - Low rating
└── 0 (bottom) - Minimum rating
```

#### X-Axis (Candidates)
```
Responsive column layout
├── 120px base width per candidate
├── 16px gap between columns
├── Horizontal scroll on overflow
└── Minimum 80px width on mobile
```

### Color System

#### Rating States
- **Approved** (above baseline): `text-green-600`, `bg-green-100`
- **Disapproved** (below baseline): `text-red-600`, `bg-red-100`
- **Unrated**: `text-gray-400`, `bg-gray-100`
- **Baseline**: `border-blue-500`, `bg-blue-50`

#### Party Affiliation
- **Democratic**: `bg-blue-500`
- **Republican**: `bg-red-500`
- **Independent**: `bg-gray-500`
- **Green**: `bg-green-500`
- **Other**: `bg-purple-500`

### Typography Scale
- **Candidate names**: `text-sm font-medium`
- **Rating values**: `text-xs`
- **Axis labels**: `text-xs text-gray-600`
- **Title**: `text-lg font-semibold`

## CSS Architecture (Four-Layer System)

### Layer 1: Layout (Positioning & Structure)
```css
/* app/assets/tailwind/layout/mountain.css */
.mountain-chart {
  @apply relative grid grid-cols-1;
  @apply w-full h-96; /* 384px = ~500 scale with padding */
}

.candidate-columns {
  @apply flex gap-4 overflow-x-auto;
}

.candidate-column {
  @apply relative flex-shrink-0 w-24;
  @apply flex flex-col items-center;
}

.rating-area {
  @apply relative w-full;
  height: 320px; /* Actual rating scale area */
}
```

### Layer 2: Sizing (Spacing & Dimensions)
```css
/* app/assets/tailwind/sizing/mountain.css */
.mountain-chart {
  @apply p-4;
}

.candidate-column {
  @apply p-2;
}

.rating-dot {
  @apply w-3 h-3;
  @apply -ml-1.5; /* Center on column */
}

.baseline-line {
  @apply h-0.5 w-full;
}
```

### Layer 3: Typography & Colors
```css
/* app/assets/tailwind/typography/mountain.css */
.candidate-name {
  @apply text-sm font-medium text-center;
  @apply mt-2;
}

.rating-label {
  @apply text-xs text-gray-600;
}

/* app/assets/tailwind/colors/mountain.css */
.rating-dot {
  &.approved {
    @apply bg-green-500 border-green-600;
  }
  
  &.disapproved {
    @apply bg-red-500 border-red-600;
  }
  
  &.unrated {
    @apply bg-gray-300 border-gray-400;
  }
}
```

### Layer 4: State (Interactions & Variants)
```css
/* app/assets/tailwind/situation/mountain.css */
.rating-dot {
  @apply transition-all duration-200;
  
  &:hover {
    @apply scale-125 shadow-lg;
  }
}

.candidate-column {
  &:hover {
    @apply bg-gray-50 rounded;
  }
}
```

## Data Processing Pipeline

### Controller Data Preparation
```ruby
def show
  @election = Election.find(params[:id])
  @voter = find_voter
  @baseline = find_baseline
  @mountain_data = build_mountain_data
end

def simulate
  @election = Election.find(params[:id])
  (5..15).sample.times { FactoryBot.create(:candidacy, election: @election) }
  @election.candidacies.each { |candidacy| FactoryBot.create(:rating, candidacy: candidacy, voter: @current_voter) }
  FactoryBot.create(:voter_election_baseline, election: @election, voter: @current_voter)
end

private

def build_mountain_data
  @election.candidacies.active.includes(:person, :ratings).map do |candidacy|
    rating = candidacy.ratings.find_by(voter: @voter)
    
    {
      candidacy: candidacy,
      rating_value: rating&.rating || 0,
      has_rating: rating.present?,
      is_approved: rating&.approved?(@baseline&.baseline),
      position_y: calculate_position(rating&.rating || 0)
    }
  end
end

def calculate_position(rating)
  # Convert 0-500 rating to CSS position (inverted for top-origin)
  max_height = 320 # pixels
  (max_height - (rating / 500.0 * max_height)).to_i
end
```

### Component Data Flow
```
Controller → ShowView → MountainChart → CandidateColumn → RatingDot
     ↓            ↓           ↓              ↓             ↓
@mountain_data → data → candidacy_data → rating_info → dot_styles
```

## Responsive Design Strategy

### Breakpoint Behavior

#### Desktop (≥1024px)
- Full width display
- All candidates visible
- Optimal spacing and sizing

#### Tablet (768px - 1023px)
- Horizontal scroll for candidate overflow
- Maintained vertical scale
- Touch-friendly interactions

#### Mobile (≤767px)
- Compressed candidate columns
- Horizontal scroll required
- Simplified labels and styling

### Accessibility Considerations

#### Screen Reader Support
- ARIA labels for chart components
- Descriptive text alternatives
- Logical tab order

#### Keyboard Navigation
- Tab through candidates
- Arrow key navigation within chart
- Enter/Space for interactions

#### Visual Accessibility
- High contrast color ratios
- Clear visual hierarchy
- Scalable text and elements

## Performance Optimization

### Database Queries
```ruby
# Optimized query with includes
@candidacies = @election.candidacies
                        .active
                        .includes(:person, ratings: :voter)
                        .order(:announcement_date)
```

### Rendering Efficiency
- Component memoization for static elements
- Minimal DOM manipulation
- CSS-based positioning (no JavaScript required)

### Caching Strategy
- Fragment caching for static candidate info
- Cache mountain data by election + voter combination
- Expire cache on rating updates

## Testing Strategy

### Component Testing
```ruby
# Test individual Phlex components
RSpec.describe Views::Mountains::CandidateColumn do
  it "renders candidate information correctly"
  it "positions rating dot accurately"
  it "shows approval state correctly"
end
```

### Integration Testing
```ruby
# Test complete mountain rendering
RSpec.describe MountainsController do
  it "displays mountain for election with ratings"
  it "handles voter selection correctly"
  it "shows baseline appropriately"
end
```

### Visual Regression Testing
- Screenshot comparisons for layout
- Cross-browser compatibility
- Mobile responsiveness validation

## Future Enhancements

### Phase 2 Features
- Interactive rating editing
- Real-time collaborative updates
- Animation and transitions
- Multiple voter comparison view

### Phase 3 Features
- Export to SVG/PNG
- Historical rating timelines
- Advanced filtering and sorting
- Embedding in external sites

### Technical Debt Considerations
- JavaScript enhancement for interactivity
- WebSocket support for real-time updates
- API endpoints for headless usage
- Performance monitoring and optimization

## Security and Privacy

### Public Rating Display
- All ratings visible to public (by design)
- No authentication required for viewing
- Voter identity tied to URLs (transparent)

### Data Validation
- Rating bounds enforcement (0-500)
- Voter eligibility verification
- Baseline validation per election

### Input Sanitization
- URL parameter validation
- SQL injection prevention
- XSS protection in displays

This architecture provides a solid foundation for the mountain interface while maintaining consistency with the project's established patterns and allowing for future enhancement and scaling.