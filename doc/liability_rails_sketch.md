# Rule Rails Sketch

## Purpose

This document turns the permission-model discussion into a concrete Rails-oriented sketch.

The product goal is to explain what is allowed.

It is not to adjudicate individual cases.

So the Rails shape should center:

- rules
- conditions
- exceptions
- scope
- source traceability

not:

- verdicts
- burdens of proof
- claimant/defendant posture

## Recommended Architecture

The recommended architecture is:

- `LU` for source law
- `Rule` for derived permission statements
- `Guide` for user-facing navigation and explanation

The `Rule` layer is the structured middle layer between raw legal text and the public guide experience.

## Rails Namespace Shape

Suggested file layout:

- `app/models/rule/topic.rb`
- `app/models/rule/statement.rb`
- `app/models/rule/condition.rb`
- `app/models/rule/exception.rb`
- `app/models/rule/scope.rb`
- `app/models/rule/source_link.rb`

Optional later:

- `app/models/rule/definition_binding.rb`

## Table Names

Recommended tables:

- `rule_topics`
- `rule_statements`
- `rule_conditions`
- `rule_exceptions`
- `rule_scopes`
- `rule_source_links`

Future source-law tables:

- `lu_corpora`
- `lu_editions`
- `lu_units`
- `lu_references`
- `lu_projections`

## Recommended V1 Cut

Build first:

- `Rule::Topic`
- `Rule::Statement`
- `Rule::Condition`
- `Rule::SourceLink`

Add next:

- `Rule::Exception`
- `Rule::Scope`

This keeps the first implementation small but still useful.

## Core Model Sketch

### `Rule::Topic`

Purpose:

- top-level domain such as use of force or weapon possession

Suggested columns:

- `slug`, `string`, null: false
- `title`, `string`, null: false
- `description`, `text`
- `status`, `integer`, null: false, default: 0
- timestamps

Suggested enum:

- `status: { draft: 0, active: 1, archived: 2 }`

Suggested associations:

- `has_many :statements`

Suggested validations:

- `slug`, presence, uniqueness
- `title`, presence

### `Rule::Statement`

Purpose:

- one derived statement about permission or prohibition

Examples:

- carrying is generally prohibited here
- carrying is allowed with a license
- force is allowed in self-defense under certain conditions

Suggested columns:

- `topic_id`, references, null: false
- `slug`, `string`, null: false
- `title`, `string`, null: false
- `effect`, `integer`, null: false, default: 0
- `actor_label`, `string`
- `action_label`, `string`
- `object_label`, `string`
- `summary`, `text`, null: false
- `position`, `integer`, null: false, default: 0
- `status`, `integer`, null: false, default: 0
- timestamps

Suggested enums:

- `effect: { allowed: 0, prohibited: 1, conditional: 2, exception_limited: 3, unclear: 4 }`
- `status: { draft: 0, active: 1, archived: 2 }`

Suggested associations:

- `belongs_to :topic`
- `has_many :conditions`
- `has_many :exceptions`
- `has_many :scopes`
- `has_many :source_links, as: :linkable`

This is the main derived record in the permission layer.

### `Rule::Condition`

Purpose:

- one condition that qualifies a statement

Examples:

- actor must be licensed
- threat must be imminent
- response must be necessary
- item must remain concealed

Suggested columns:

- `statement_id`, references, null: false
- `slug`, `string`, null: false
- `label`, `string`, null: false
- `kind`, `integer`, null: false, default: 0
- `position`, `integer`, null: false, default: 0
- `notes`, `text`
- timestamps

Suggested enums:

- `kind: { required: 0, clarifying: 1, disqualifying: 2 }`

Suggested associations:

- `belongs_to :statement`
- `has_many :source_links, as: :linkable`

### `Rule::Exception`

Purpose:

- one explicit carveout to a statement

Examples:

- emergency exception
- peace officer exception
- property-owner exception

Suggested columns:

- `statement_id`, references, null: false
- `slug`, `string`, null: false
- `label`, `string`, null: false
- `summary`, `text`, null: false
- `position`, `integer`, null: false, default: 0
- timestamps

Suggested associations:

- `belongs_to :statement`
- `has_many :source_links, as: :linkable`

### `Rule::Scope`

Purpose:

- one contextual limitation on a statement

Examples:

- location: dwelling
- location: school zone
- actor: licensed person
- object: concealed handgun

Suggested columns:

- `statement_id`, references, null: false
- `scope_kind`, `integer`, null: false, default: 0
- `value`, `string`, null: false
- `position`, `integer`, null: false, default: 0
- timestamps

Suggested enums:

- `scope_kind: { actor: 0, action: 1, object: 2, location: 3, jurisdiction: 4, time: 5 }`

Suggested associations:

- `belongs_to :statement`

### `Rule::SourceLink`

Purpose:

- attach derived rule records back to canonical source-law units

Suggested columns:

- `linkable_type`, `string`, null: false
- `linkable_id`, `bigint`, null: false
- `lu_unit_id`, `bigint`, null: false
- `relationship_kind`, `integer`, null: false, default: 0
- `notes`, `text`
- timestamps

Suggested enums:

- `relationship_kind: { primary_support: 0, secondary_support: 1, cross_reference: 2, caution_source: 3 }`

Suggested indexes:

- composite index on `[:linkable_type, :linkable_id]`
- index on `:lu_unit_id`

## Relationship Sketch

The broad shape should be:

- `Rule::Topic has_many :statements`
- `Rule::Statement has_many :conditions`
- `Rule::Statement has_many :exceptions`
- `Rule::Statement has_many :scopes`
- `Rule::Statement has_many :source_links`

And all meaningful derived content should point back to `LU::Unit`.

## Suggested Active Record Skeletons

```ruby
# app/models/rule/topic.rb
module Rule
  class Topic < ApplicationRecord
    self.table_name = "rule_topics"

    enum :status, { draft: 0, active: 1, archived: 2 }

    has_many :statements, class_name: "Rule::Statement", dependent: :destroy

    validates :slug, presence: true, uniqueness: true
    validates :title, presence: true
  end
end
```

```ruby
# app/models/rule/statement.rb
module Rule
  class Statement < ApplicationRecord
    self.table_name = "rule_statements"

    enum :effect, {
      allowed: 0,
      prohibited: 1,
      conditional: 2,
      exception_limited: 3,
      unclear: 4
    }

    enum :status, { draft: 0, active: 1, archived: 2 }

    belongs_to :topic, class_name: "Rule::Topic"
    has_many :conditions, class_name: "Rule::Condition", dependent: :destroy
    has_many :exceptions, class_name: "Rule::Exception", dependent: :destroy
    has_many :scopes, class_name: "Rule::Scope", dependent: :destroy
    has_many :source_links, as: :linkable, class_name: "Rule::SourceLink", dependent: :destroy
  end
end
```

```ruby
# app/models/rule/condition.rb
module Rule
  class Condition < ApplicationRecord
    self.table_name = "rule_conditions"

    enum :kind, { required: 0, clarifying: 1, disqualifying: 2 }

    belongs_to :statement, class_name: "Rule::Statement"
    has_many :source_links, as: :linkable, class_name: "Rule::SourceLink", dependent: :destroy
  end
end
```

## Migration Order

A sensible migration order is:

1. create `rule_topics`
2. create `rule_statements`
3. create `rule_conditions`
4. create `rule_exceptions`
5. create `rule_scopes`
6. create `rule_source_links`

If you want the tightest V1:

1. create `rule_topics`
2. create `rule_statements`
3. create `rule_conditions`
4. create `rule_source_links`

## Example Migration Sketches

### `create_rule_topics`

```ruby
class CreateRuleTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_topics do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :rule_topics, :slug, unique: true
  end
end
```

### `create_rule_statements`

```ruby
class CreateRuleStatements < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_statements do |t|
      t.references :topic, null: false, foreign_key: { to_table: :rule_topics }
      t.string :slug, null: false
      t.string :title, null: false
      t.integer :effect, null: false, default: 0
      t.string :actor_label
      t.string :action_label
      t.string :object_label
      t.text :summary, null: false
      t.integer :position, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :rule_statements, [:topic_id, :slug], unique: true
  end
end
```

### `create_rule_source_links`

```ruby
class CreateRuleSourceLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_source_links do |t|
      t.string :linkable_type, null: false
      t.bigint :linkable_id, null: false
      t.bigint :lu_unit_id, null: false
      t.integer :relationship_kind, null: false, default: 0
      t.text :notes
      t.timestamps
    end

    add_index :rule_source_links, [:linkable_type, :linkable_id], name: "index_rule_source_links_on_linkable"
    add_index :rule_source_links, :lu_unit_id
  end
end
```

## Integration With `LU`

The `Rule` layer should not copy legal text into derived records except for short summaries.

Instead:

- `Rule::Statement` links to `LU::Unit`
- `Rule::Condition` links to `LU::Unit`
- `Rule::Exception` links to `LU::Unit`

That is how the product stays explainable and updateable.

## Integration With `Guide`

The `Guide` layer should be built on top of `Rule`, not in place of it.

A reasonable bridge is:

- `Guide::Topic` maps to a `Rule::Topic`
- `Guide::Node` presents one or more `Rule::Statement` records
- `Guide` organizes navigation
- `Rule` carries the structured permission content

## Seed Strategy

A good first seed set is:

- one `Rule::Topic` for `use_of_force`
- two `Rule::Statement` records:
  - general prohibition on force
  - self-defense permission
- four `Rule::Condition` records for self-defense:
  - unlawful threat
  - imminence
  - necessity
  - proportionality
- one or two `Rule::Exception` records if needed
- source links back to a narrow source-law slice

That is enough to prove the model shape.

## Service Layer Suggestion

Do not put all derivation logic in the models.

Use services for:

- source ingestion
- rule derivation
- guide-node assembly

Possible service names:

- `LU::IngestEdition`
- `Rule::DeriveStatements`
- `Guide::BuildTopicFlow`

## What To Build Next

If this direction is accepted, the next concrete implementation steps should be:

1. create the `Rule` V1 migrations
2. add the namespaced models
3. seed one topic such as `use_of_force`
4. connect one small source-law slice
5. build one simple page or API response that renders allowed/prohibited/conditional statements

## Summary

The tight Rails implementation path is:

- keep source law in `LU`
- derive permission statements in `Rule`
- present them through `Guide`

That is a much better fit for the product than a liability-style adjudication model.
