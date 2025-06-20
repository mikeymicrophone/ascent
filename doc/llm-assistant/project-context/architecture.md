# Architecture Overview

## Core Election Models Hierarchy

The Ascent platform is built around a hierarchical model structure that represents elections across different types of jurisdictions. The foundation consists of jurisdictions, positions, offices, elections, and candidacies.

### Jurisdiction Models (Polymorphic Approach)

Rather than using Single Table Inheritance, we use separate models for each jurisdiction type with polymorphic associations:

#### Country
- `name` - Full country name
- `code` - ISO country code (e.g., "US", "CA")
- `description` - Additional context about the country

#### State
- `name` - State/province name
- `code` - State abbreviation (e.g., "CA", "NY")
- `description` - Additional context
- `country_id` - References Country

#### City
- `name` - City name
- `code` - City code if applicable
- `description` - Additional context
- `state_id` - References State

#### Town
- `name` - Town name
- `code` - Town code if applicable
- `description` - Additional context
- `state_id` - References State

#### Organization
- `name` - Organization name
- `description` - Organization purpose and context
- `organization_type` - Type of organization (nonprofit, corporation, club, etc.)

### Position Model

Represents common political roles that can exist across different jurisdictions:

- `title` - Position title (e.g., "Mayor", "Governor", "President")
- `description` - Detailed description of the role and responsibilities
- `is_executive` - Boolean indicating if this is an executive position
- `term_length_years` - Standard term length for this position

### Office Model (Polymorphic Association)

Links a Position to any type of Jurisdiction:

- `position_id` - References Position
- `jurisdiction_type` - Polymorphic type (Country, State, City, Town, Organization)
- `jurisdiction_id` - Polymorphic ID referencing the specific jurisdiction
- `is_active` - Boolean indicating if this office is currently active
- `notes` - Additional context about this specific office

### Year Model

Represents election years with relevant metadata:

- `year` - The election year (integer)
- `is_even_year` - Boolean for even-year elections
- `is_presidential_year` - Boolean for US presidential election years
- `description` - Context about significant elections in this year

### Election Model

Represents specific elections linking an Office to a Year:

- `office_id` - References Office
- `year_id` - References Year
- `election_date` - Specific date of the election
- `status` - Election status (upcoming, active, completed, cancelled)
- `description` - Context about this specific election
- `is_mock` - Boolean indicating if this is a mock/practice election
- `is_historical` - Boolean indicating if this is a historical simulation

### Person Model

Represents individuals who can be candidates or voters:

- `first_name` - Person's first name
- `last_name` - Person's last name
- `middle_name` - Person's middle name (optional)
- `email` - Email address for contact and authentication
- `birth_date` - Date of birth
- `bio` - Biographical information

### Candidacy Model

Links a Person to an Election as a candidate:

- `person_id` - References Person
- `election_id` - References Election
- `status` - Candidacy status (announced, active, withdrawn, disqualified)
- `announcement_date` - Date the candidacy was announced
- `party_affiliation` - Political party affiliation (optional)
- `platform_summary` - Brief summary of the candidate's platform

### Voter Model (Devise Authentication)

Represents authenticated users who can rate candidates and participate in elections:

- `email` - Email address for authentication (Devise)
- `first_name` - Voter's first name
- `last_name` - Voter's last name
- `birth_date` - Date of birth for eligibility verification
- `is_verified` - Boolean indicating if voter identity is verified
- Devise modules: database_authenticatable, registerable, recoverable, rememberable, validatable

### Registration Model

Tracks voter jurisdiction history to handle voter mobility:

- `voter_id` - References Voter
- `jurisdiction_type` - Polymorphic type (Country, State, City)
- `jurisdiction_id` - Polymorphic ID referencing the specific jurisdiction
- `registered_at` - Date/time of registration
- `status` - Registration status (active, inactive, moved, suspended)
- `notes` - Additional context about this registration

### Rating Model

Represents voter ratings of candidates on the 0-500 "mountain" scale:

- `voter_id` - References Voter
- `candidacy_id` - References Candidacy
- `rating` - Integer rating from 0-500
- Automatic archiving on updates for historical analysis

### VoterElectionBaseline Model

Manages per-election baseline thresholds for each voter:

- `voter_id` - References Voter
- `election_id` - References Election
- `baseline` - Integer baseline threshold from 0-500 (determines approval for all candidacies in election)
- Updated on separate schedule from ratings to prevent manipulation

### RatingArchive Model

Historical archive of all rating changes for transparency and analysis:

- `voter_id` - References Voter
- `candidacy_id` - References Candidacy
- `rating` - Historical rating value (0-500)
- `archived_at` - Timestamp when this rating was archived
- `reason` - Description of what changed

## Key Architectural Decisions

### Polymorphic Jurisdictions
Using separate models for each jurisdiction type with polymorphic associations allows for:
- Type-specific behavior and validations
- Clear hierarchical relationships (State belongs to Country, City belongs to State)
- Flexibility to add new jurisdiction types without schema changes
- Avoidance of STI complexity and null field issues

### Hierarchical Design
The model hierarchy flows from broad to specific:
- Jurisdictions (Country → State → City/Town, plus Organizations)
- Positions (generic roles like "Mayor")
- Offices (Position within a specific Jurisdiction)
- Elections (Office in a specific Year)
- Candidacies (Person running in a specific Election)
- Voters (Authenticated users with Registration history)
- Ratings (Voter preferences for Candidacies with archival)
- VoterElectionBaselines (Per-election baseline thresholds)

### Mock and Historical Elections
The Election model supports both mock elections for education and historical simulations for research, aligning with the platform's educational mission described in the PRD.

### Approval Voting Implementation
The Rating system implements the core approval voting mechanism:
- **0-500 Scale**: Each voter rates candidates on a 0-500 scale representing their preference intensity
- **Per-Election Baselines**: Voters set one baseline per election (0-500) that determines which candidates they "approve"
- **Vote Allocation**: Candidates rated at or above the voter's election baseline receive the voter's approval
- **Separate Update Schedules**: Baselines updated independently from ratings to prevent last-minute manipulation
- **Historical Tracking**: All rating changes are archived for transparency and analysis
- **Eligibility Enforcement**: Voters can only rate candidates in elections where they're jurisdictionally eligible

### Voter Mobility Support
The Registration system handles real-world voter mobility:
- **Registration History**: Complete timeline of voter jurisdiction changes
- **Single Active Registration**: Voters can only have one active registration at a time
- **Eligibility Rules**: Hierarchical eligibility (city voters can vote in state/country elections)
- **Status Tracking**: Active, inactive, moved, suspended registration statuses

### Custom Generator Enhancement

### Current Generator Capabilities
The project includes a custom `PhlexScaffoldGenerator` (`lib/generators/phlex_scaffold/`) that generates:
- Controllers using local variables and Phlex view rendering
- Phlex views (Index, Show, New, Edit) in proper namespace structure
- Form and Partial components with Tailwind styling
- Model and route generation

### Planned Enhancements

**Testing Integration**
- RSpec controller and model specs with realistic test scenarios
- FactoryBot factories with descriptive, politically-relevant data
- System tests for complete CRUD workflows

**Convention Alignment**
- Service object generation for complex business logic
- View helper generation for markup encapsulation  
- Enhanced error handling and flash message patterns

**CSS/Styling Improvements**
- Semantic CSS class generation instead of direct Tailwind
- Corresponding CSS files with @apply directives
- Better component organization (UI vs domain separation)

**Documentation Generation**
- Inline code documentation
- README updates for new resources
- Generator options for election-specific scaffolds (mock, historical, binding)

This generator system will accelerate development while ensuring all generated code follows project conventions and produces emotionally satisfying, production-ready code.

## Extensibility
This foundation allows for future features like:
- Voter registration and authentication
- Ballot creation and voting interfaces
- Results calculation and visualization
- Polling and preference expression tools