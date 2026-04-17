# Permission Model Draft

## Purpose

This draft describes a **derived permission layer** for the product.

The product is not meant to adjudicate cases.

It is meant to explain questions closer to:

- can I do this?
- when is this allowed?
- when is this prohibited?
- what conditions or exceptions matter?
- when is the answer unclear from code alone?

That means the model should be optimized for:

- source-backed explanation
- scenario-oriented navigation
- portable structure
- restrained statements of certainty

It should not be optimized for:

- litigated case outcomes
- burden-shifting analysis
- final liability determinations

## Position In The Overall Architecture

The recommended structure is:

1. `LU`
2. `Guide`
3. `Rule`

### `LU`

The source-law layer.

This preserves:

- legal text
- citations
- hierarchy
- dated editions
- references

### `Guide`

The user-facing guidance layer.

This presents:

- questions
- warnings
- simplified explanations
- navigable scenario trees

### `Rule`

The derived permission layer.

This expresses:

- allowed
- prohibited
- allowed subject to conditions
- prohibited unless an exception applies
- unclear from code alone

This layer is derived from source law, but it is not itself canonical law.

## Core Rule

The product should model **permissions and constraints**, not simulated verdicts.

That means the central questions are:

- what action is being discussed?
- who is the actor?
- what object or target is involved?
- where does it happen?
- what conditions must be true?
- what exceptions change the answer?

## Proposed Namespace

The strongest name is probably `Rule`.

Suggested models:

- `Rule::Topic`
- `Rule::Statement`
- `Rule::Condition`
- `Rule::Exception`
- `Rule::Scope`
- `Rule::SourceLink`
- optionally `Rule::DefinitionBinding`

## Model Draft

### `Rule::Topic`

Represents the practical domain being explained.

Examples:

- use of force
- carrying weapons
- detention
- removal from property
- recording communications

Suggested fields:

- `slug`
- `title`
- `description`
- `status`

This is the top-level domain for explanation.

### `Rule::Statement`

Represents one derived statement about permission or prohibition.

Examples:

- force is generally prohibited
- force is allowed in self-defense under limited conditions
- carrying is prohibited in certain places
- recording is allowed with consent

Suggested fields:

- `topic_id`
- `slug`
- `title`
- `effect`
- `actor_label`
- `action_label`
- `object_label`
- `summary`
- `position`
- `status`

Suggested `effect` values:

- `allowed`
- `prohibited`
- `conditional`
- `exception_limited`
- `unclear`

This should be the central derived record.

### `Rule::Condition`

Represents a condition that must be true for a statement to apply.

Examples:

- threat must be imminent
- actor must be licensed
- object must remain concealed
- location must not be restricted

Suggested fields:

- `statement_id`
- `slug`
- `label`
- `kind`
- `position`
- `notes`

Suggested `kind` values:

- `required`
- `clarifying`
- `disqualifying`

### `Rule::Exception`

Represents a carveout that changes the ordinary rule.

Examples:

- peace officer exception
- emergency exception
- property-owner exception
- licensing exception

Suggested fields:

- `statement_id`
- `slug`
- `label`
- `summary`
- `position`

The product should keep exceptions explicit, because they are often what users actually need help finding.

### `Rule::Scope`

Represents context that limits where or to whom a statement applies.

Examples:

- private property
- dwelling
- vehicle
- school zone
- public place
- licensed actor

Suggested fields:

- `statement_id`
- `scope_kind`
- `value`
- `position`

Suggested `scope_kind` values:

- `actor`
- `location`
- `object`
- `jurisdiction`
- `time`

### `Rule::SourceLink`

Represents traceability back to source law.

Every important derived statement should link back to one or more `LU::Unit` records.

This is what keeps the explanation accountable.

### `Rule::DefinitionBinding` (optional)

Represents that a statement, condition, or scope depends on a legally defined term.

Examples:

- dwelling
- deadly weapon
- consent
- unlawful force

This can wait until later.

## Relationship Sketch

The broad shape should be:

- `Rule::Topic has_many :statements`
- `Rule::Statement has_many :conditions`
- `Rule::Statement has_many :exceptions`
- `Rule::Statement has_many :scopes`
- `Rule::Statement has_many :source_links`

## Writing Rule

Each derived statement should fit one of these forms:

- allowed
- prohibited
- allowed if
- prohibited unless
- unclear from code alone

The system should avoid sounding more definite than the source material supports.

It should prefer language like:

- generally allowed
- generally prohibited
- allowed if these conditions are met
- exception may apply
- fact-sensitive
- unclear from code alone

## Example: Use Of Force

### Topic

`Rule::Topic`

- slug: `use_of_force`
- title: `Use of Force`

### Statements

`Rule::Statement`

- `general_prohibition_on_force`
  - effect: `prohibited`
  - summary: force against another person is generally prohibited

- `self_defense_permission`
  - effect: `conditional`
  - summary: force may be allowed in self-defense under limited conditions

### Conditions For `self_defense_permission`

- threat is unlawful
- threat is imminent
- force is necessary
- force is proportional

### Possible Exception Or Scope Records

- location: dwelling
- actor: lawful occupant
- exception: no-retreat rule may alter the analysis

### User-Facing Output

The product should not say:

- you would win
- you are definitely not liable

It should say:

- force is generally prohibited
- force may be allowed in self-defense if the threat is imminent and the response is necessary and proportional
- some jurisdictions add location-based exceptions or retreat rules

That is much closer to the actual product goal.

## Practical V1

A good first version is:

- `Rule::Topic`
- `Rule::Statement`
- `Rule::Condition`
- `Rule::SourceLink`

Add next:

- `Rule::Exception`
- `Rule::Scope`

That is enough to explain what is allowed without drifting into a fake adjudication engine.

## Recommended Development Order

1. Build the `LU` source backbone.
2. Ingest one narrow legal corpus.
3. Create one `Rule::Topic`.
4. Create a small set of `Rule::Statement` records.
5. Attach conditions and source links.
6. Build a user-facing `Guide` flow on top.

## Summary

The product should not center disputed liability.

It should center **permission, prohibition, conditions, exceptions, and uncertainty**.

In short:

- `LU` preserves the law
- `Rule` derives what is allowed
- `Guide` explains it to the user
