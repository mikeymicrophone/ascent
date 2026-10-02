# Stance Shift Implementation Plan

## Status

This document describes a proposed implementation.

It does not indicate that the migrations, models, forms, or campaign interface have been built.

## Objective

Ascent should let a candidacy express not only a general position on an issue, but one or more concrete intentions about:

- what the law should say
- how strongly an existing rule should be enforced
- how much discretion the enforcing institution should retain

The structured unit for one intention is a `Shift`.

A `Stance` can contain many shifts because a coherent platform may combine several movements. A candidate may want to narrow a code, increase enforcement of what remains, and preserve broad case-level discretion.

## Current Application Shape

The application currently has a `Stance` model with this relationship:

```text
Candidacy -> Stance -> Approach -> Issue
```

`Stance` belongs directly to `Candidacy` and `Approach`. It reaches `Issue` through `Approach`.

There is no `IssueStance` model or `issue_stances` table. The architecture document currently mentions an `issue_id` on `Stance`, but the model and database do not contain that column.

The application also has:

- `OfficialCode`, representing a legal implementation attached to a `Policy`
- `Rule::Statement`, representing a derived, legible statement about permission or prohibition
- `Rule::Condition` and `Rule::SourceLink`

The first implementation should preserve the existing `Stance` name and association structure. A separate `IssueStance` should not be introduced unless the product later needs one issue-level record to group several approach-specific stances.

## Product Decisions

### A stance is the campaign position

`Stance` remains the candidacy's overall position on an Approach.

It owns the shared campaign material:

- explanation
- priority
- general evidence
- relationship to the candidacy and Approach

### A shift is one structured intention

Each `Shift` answers:

> For this target, which dimension should move from the candidate's assessed current state to the desired state?

A shift may represent:

- a code intention
- a change in enforcement appetite
- a change in enforcement discretion

### A stance can combine shift types

The shift types are independent. A stance may contain:

- only a code shift
- only an enforcement shift
- several code shifts
- several enforcement shifts
- both code and enforcement shifts

Absence of a shift means **not stated**. It must not be interpreted as support for the status quo, a midpoint value, or no change.

### Current values are candidate assessments

Any current enforcement value is an attributed candidate assessment. It is not an Ascent finding and is not observed enforcement data.

The product should display:

> Candidate's assessment of current intensity: 100-200

not:

> Current enforcement: 150

Current assessments are optional. Candidates may indicate that they are unable to assess the present level while still specifying a desired posture.

### Ranges preserve uncertainty

Enforcement values may be:

- a point, represented by equal lower and upper bounds
- a range
- omitted when unknown or not stated

The application must preserve the range. It must not silently replace a range with its midpoint.

Range width represents the candidate's expressed precision, not credibility. Evidence and confidence remain separate questions.

### Holding the current position is valid

The structure must not assume that every legitimate intention changes policy. A shift may indicate `hold` or preserve an existing code or enforcement posture.

## Scope

### Included

- candidate intentions about code
- candidate intentions about enforcement appetite
- candidate intentions about enforcement discretion
- optional candidate assessments of current enforcement
- point and range values on a 0-500 scale
- optional variations by conduct, circumstance, place, jurisdiction, population, or institution
- shift-specific explanations and evidence

### Deferred

- observed enforcement rates or outcomes
- scoring whether a candidate's assessment is correct
- detailed modeling of police, prosecutorial, and agency workflows
- plea bargaining, charging leverage, adjudication, and punishment mechanics
- complete source-law ingestion
- a general simulation of institutional influence

## Relationship Shape

```text
Candidacy
└── Stance
    ├── Approach
    │   └── Issue
    └── Shifts
        ├── CodeShift
        │   └── OfficialCode, when one already exists
        ├── EnforcementShift
        │   └── Rule::Statement
        └── ShiftScopes
```

The recommended Rails implementation uses `Shift` as a common record with delegated detail types. This avoids one sparse table containing incompatible code-state and enforcement-range columns.

## Model Contracts

### `Stance`

Add:

- `has_many :shifts, dependent: :destroy`

Do not add `issue_id` in this implementation. Continue obtaining the issue through `Approach`.

### `Shift`

Purpose:

- common campaign metadata for one structured intention

Suggested columns:

- `stance_id`, references, null: false
- `shiftable_type`, string, null: false
- `shiftable_id`, bigint, null: false
- `explanation`, text
- `evidence_links`, text
- `confidence`, integer
- `position`, integer, null: false, default: 0
- timestamps

Suggested associations:

- `belongs_to :stance`
- `delegated_type :shiftable, types: %w[CodeShift EnforcementShift], dependent: :destroy`
- `has_many :scopes, class_name: "ShiftScope", dependent: :destroy`

Suggested confidence values:

- `low`
- `medium`
- `high`

Confidence is optional and describes the candidate's confidence in a current assessment. It does not describe Ascent's confidence in the candidate.

Suggested validations:

- `position` is zero or greater
- `shiftable_type` is one of the supported delegated types

### `CodeShift`

Purpose:

- describe the candidate's intended treatment of a code provision

Suggested columns:

- `official_code_id`, references, null: true
- `direction`, integer, null: false
- `proposed_code_label`, string
- timestamps

Suggested directions:

- `enact`
- `expand`
- `preserve`
- `narrow`
- `repeal`

Rules:

- `expand`, `preserve`, `narrow`, and `repeal` require an `OfficialCode`
- `enact` may omit `OfficialCode` because the proposed provision may not exist yet
- an `enact` shift without an `OfficialCode` requires `proposed_code_label`
- the detailed intended language remains in the parent Shift's explanation until a dedicated proposal-text model is justified

Longer term, source-law ingestion may replace or supplement the `OfficialCode` reference with `LU::Unit`. That should not block the first campaign implementation.

### `EnforcementShift`

Purpose:

- describe an intended change to enforcement appetite or enforcement discretion for one legible rule

Suggested columns:

- `rule_statement_id`, references, null: false, foreign key to `rule_statements`
- `dimension`, integer, null: false
- `movement`, integer, null: false
- `current_low`, integer
- `current_high`, integer
- `desired_low`, integer
- `desired_high`, integer
- timestamps

Suggested dimensions:

- `appetite`
- `discretion`

Suggested movements:

- `decrease`
- `hold`
- `increase`
- `set_target`

`movement` preserves a qualitative intention when a candidate cannot responsibly assign a current or desired number. When complete ranges are present, Ascent may also derive a directional relationship, but it should preserve the candidate's declared movement.

Rules:

- every supplied value is within `0..500`
- a lower bound cannot exceed its upper bound
- current bounds are both present or both absent
- desired bounds are both present or both absent
- `movement` is always required
- a desired range may be omitted when `movement` communicates a qualitative intention without false numerical precision
- an exact score uses equal lower and upper bounds
- current bounds are always treated as a candidate assessment
- the application does not calculate a midpoint for storage or display

Enforcement appetite and enforcement discretion use separate records, even when they concern the same `Rule::Statement`. This allows either dimension to change independently and gives each shift its own explanation, evidence, confidence, and scopes.

### `ShiftScope`

Purpose:

- limit one Shift to the conduct, circumstances, places, jurisdictions, populations, or institutions named by the candidate

Suggested columns:

- `shift_id`, references, null: false
- `scope_kind`, integer, null: false
- `label`, string, null: false
- `notes`, text
- `position`, integer, null: false, default: 0
- timestamps

Suggested scope kinds:

- `conduct`
- `circumstance`
- `location`
- `jurisdiction`
- `population`
- `institution`

V1 combination rule:

- multiple scopes on one Shift are conjunctive
- separate Shifts represent alternatives

For example, population `first-time defendants` plus conduct `offense X` means that both scopes apply. Two independent populations should use separate Shifts unless a later scope-group model adds explicit OR behavior.

Population scopes must come from an explicit candidate statement or cited source. Ascent must not infer sensitive demographic attributes from names, appearance, addresses, or neighborhoods.

## Scale Semantics

### Enforcement appetite

The appetite scale runs from 0 to 500.

The endpoints describe intended institutional priority, not the percentage of all real-world violations detected or punished.

Suggested anchors:

- `0`: categorical non-enforcement
- `125`: presumptive non-enforcement, subject to exceptional cases
- `250`: ordinary selective enforcement
- `375`: prioritized enforcement
- `500`: maximum lawful institutional priority for every credible known violation

Scores above 400 should be unusual. They describe rules for which every credible known violation is expected to receive an institutional response, limited by law, evidence, and case-specific judgment. Homicide is the working example; most statutory provisions would fall below this band.

### Enforcement discretion

The product decision is clear: discretion matters independently from appetite, and candidates should be able to state an intended level.

The exact 0-500 anchors for discretion remain unresolved. Before enabling the discretion slider, define whether the endpoints mean:

- no case-level discretion to broad professional autonomy
- tightly rule-bound enforcement to presumptive institutional autonomy
- another phrasing that works consistently for police, prosecutors, and agencies

The schema may support the same numeric range immediately, but the form should not collect discretion scores until the anchors are approved.

## Database Constraints And Indexes

Use database constraints where the rule can be expressed safely in PostgreSQL.

Recommended constraints include:

- `shifts.position >= 0`
- `shift_scopes.position >= 0`
- enforcement values between 0 and 500
- paired presence for low and high bounds
- lower bounds less than or equal to upper bounds

Recommended indexes include:

- `shifts.stance_id`
- composite index on `shifts.shiftable_type, shifts.shiftable_id`
- `code_shifts.official_code_id`
- `enforcement_shifts.rule_statement_id`
- `shift_scopes.shift_id`
- composite ordering indexes on `shifts.stance_id, shifts.position` and `shift_scopes.shift_id, shift_scopes.position`

The requirement that a publishable Stance contain at least one Shift belongs in a publication validation or service rather than a database constraint. Draft Stances need to exist before their child shifts are complete.

## Candidate Form

The Stance form should continue collecting the overall explanation, priority, and evidence.

The Shift editor should then ask:

1. What should change?
   - code
   - enforcement appetite
   - enforcement discretion
2. What code or rule does this concern?
3. What is the desired movement?
4. How precisely can the candidate describe the current and desired levels?
5. Does this Shift apply only to particular conduct, circumstances, places, jurisdictions, populations, or institutions?
6. What explanation and evidence support this Shift?

For numeric enforcement questions, use a two-handled slider with explicit options for:

- point estimate
- range estimate
- unable to assess the current level
- qualitative movement without a numeric estimate

The exact question wording and all scale anchors must remain visible when reviewing the answer.

## Presentation Rules

Every rendered Shift should show:

- shift type
- target
- candidate's declared movement
- current assessment, when supplied
- desired state or range, when supplied
- scopes
- confidence, when supplied
- explanation and evidence

Example:

```text
Enforcement appetite
Rule: Unlicensed performance of activity Y
Candidate's assessment of current intensity: 100-200
Desired appetite: 300
Declared movement: Increase
Scope: First-time violations
```

Do not:

- present a candidate assessment as an established current fact
- replace a range with its midpoint
- infer a missing value as 250
- describe an exact score as more credible than a range
- combine appetite and discretion into one number
- aggregate scoped shifts into a population claim the candidate did not make

## Controller And View Direction

The domain model should be implemented and verified before building the full questionnaire.

A later UI phase can add:

- nested Shift management from a Stance page
- separate Phlex components for code and enforcement details
- a reusable range display
- a reusable scope list
- publication validation feedback

Complex Shift creation should use a small service object so the parent Shift and delegated detail record are created atomically. Update and deletion should likewise preserve the one-to-one delegated record relationship.

## Migration Order

1. Create `code_shifts`.
2. Create `enforcement_shifts`.
3. Create `shifts` with its Stance reference and delegated `shiftable` columns.
4. Create `shift_scopes`.
5. Add model associations to `Stance`, `OfficialCode`, and `Rule::Statement`.
6. Add publication-level validation after draft creation works.

No existing Stance data requires backfilling. Existing records can remain valid drafts with no shifts until campaign material is structured.

## Verification Plan

Follow the repository convention of testing compound behavior rather than repeating Active Record macros.

Model and service specs should cover:

- one Stance containing code, appetite, and discretion shifts
- code enactment without an existing `OfficialCode`
- code changes that require an existing `OfficialCode`
- exact enforcement values represented by equal bounds
- broad and narrow ranges preserved exactly
- omitted current assessment
- qualitative hold without false numerical precision
- invalid values outside `0..500`
- incomplete and reversed ranges
- independent appetite and discretion shifts for one rule
- conjunctive scope behavior
- deletion of a Stance removing its shifts, delegated details, and scopes
- publication rejection when a Stance has no shifts
- display language attributing current values to the candidate

Factories should use descriptive political examples so they also document the domain:

- narrow a licensing provision while increasing enforcement of the remaining rule
- preserve a prohibition while decreasing enforcement appetite
- hold enforcement appetite while broadening discretion
- apply a different appetite to a stated circumstance or population

## Implementation Phases

### Phase 1: Domain foundation

- migrations
- models and constraints
- associations
- factories
- compound model specs

### Phase 2: Authoring workflow

- Shift creation service
- Stance publication validation
- nested management routes and controllers
- code and enforcement forms
- scope editor

### Phase 3: Campaign presentation

- Stance summary with ordered Shifts
- current-versus-desired range visualization
- candidate-assessment attribution
- evidence presentation
- jurisdiction and office-relationship annotations when that separate design is ready

### Phase 4: Initial content

- a small set of curated Rule statements
- one or two representative candidate Stances
- code-only, enforcement-only, and combined examples
- browser verification of authoring and public display

## Estimated Change Surface

The domain foundation is approximately:

- 4 migrations
- 4 new models
- 3 existing model updates
- 4 factories
- 4-6 focused model and service specs

The authoring and presentation work is likely another:

- 1 service object
- 1 nested controller or equivalent RESTful controller set
- 4-7 Phlex views/components
- request and system specs for creation, validation, and display

The exact view count should be confirmed after inspecting the current Stance form and show pages immediately before implementation.

## Decisions Still Required

The relationship model is ready. These choices should be resolved before the corresponding UI is built:

1. Define the named anchors for the 0-500 enforcement-discretion scale.
2. Decide whether `confidence` should use three named levels or a separate range.
3. Decide whether enforcement channel belongs in V1 or remains part of the explanation.
4. Decide whether campaign publication requires Shift-specific evidence or merely encourages it.
5. Decide when `OfficialCode` should yield to the future `LU::Unit` source-law model.

None of these questions requires introducing `IssueStance`. The core implementation can proceed with `Stance has_many :shifts` once this plan is approved.
