# Legal Units (`LU`) Structure

## Goal

Represent the extant penal code as it exists in published form, while making it possible to derive an "if-if" navigation tree from that source text.

This design does **not** assume full legal accuracy or full legal inference. It aims to preserve the code faithfully enough that later layers can generate structured views from it.

## Core Idea

Use a small `LU` namespace with one canonical text model and a few supporting models:

- `LU::Corpus`
- `LU::Edition`
- `LU::Unit`
- `LU::Reference`
- `LU::Definition`
- `LU::Projection`

The important decision is that **`LU::Unit` is canonical**.

The "if-if" tree is not stored as the primary source of truth. It is stored as a derived artifact in `LU::Projection`.

## Why `LU`

The `LU` namespace avoids collisions with broad names like:

- `Unit`
- `Reference`
- `Definition`
- `Edition`

It also leaves room for future legal-specific models without leaking generic terms into the rest of the application.

## Model Overview

### `LU::Corpus`

Represents the legal body being modeled.

Examples:

- `California Penal Code`
- `New York Penal Law`

Suggested attributes:

- `name`
- `slug`
- `jurisdiction`
- `source_url`
- `notes`

Suggested associations:

- `has_many :editions`

### `LU::Edition`

Represents a versioned snapshot of the corpus at a particular point in time.

This matters because the extant code changes. The application should be able to answer "what was the code as of this edition?" without rewriting all existing units in place.

Suggested attributes:

- `corpus_id`
- `label`
- `effective_on`
- `published_on`
- `source_digest`
- `source_metadata` `jsonb`

Suggested associations:

- `belongs_to :corpus`
- `has_many :units`
- `has_many :references`

### `LU::Unit`

Represents a node in the published legal hierarchy.

This is the backbone of the system. Rather than creating separate tables for `Title`, `Chapter`, `Section`, `Subdivision`, `Paragraph`, and `Clause`, use one table with a `kind` field.

Suggested attributes:

- `edition_id`
- `parent_id`
- `kind`
- `number`
- `heading`
- `body`
- `citation`
- `position`
- `path`
- `status`
- `starts_on`
- `ends_on`
- `text_metadata` `jsonb`

Examples of `kind`:

- `title`
- `part`
- `chapter`
- `article`
- `section`
- `subdivision`
- `paragraph`
- `clause`
- `note`

Examples of `status`:

- `active`
- `repealed`
- `reserved`
- `historical`

Suggested associations:

- `belongs_to :edition`
- `belongs_to :parent, class_name: "LU::Unit", optional: true`
- `has_many :children, class_name: "LU::Unit", foreign_key: :parent_id`
- `has_many :outgoing_references, class_name: "LU::Reference", foreign_key: :source_unit_id`
- `has_many :definitions`
- `has_many :projections`

This model should preserve:

- hierarchy
- order
- citation format
- exact body text
- effective/repealed state

### `LU::Reference`

Represents an explicit textual reference from one legal unit to another.

Examples:

- "except as provided in Section 197"
- "punishable under Section 243"

Suggested attributes:

- `edition_id`
- `source_unit_id`
- `target_unit_id`
- `raw_citation`
- `reference_type`
- `text_span_start`
- `text_span_end`
- `metadata` `jsonb`

Examples of `reference_type`:

- `cross_reference`
- `exception_reference`
- `definition_reference`
- `penalty_reference`
- `procedure_reference`

Suggested associations:

- `belongs_to :edition`
- `belongs_to :source_unit, class_name: "LU::Unit"`
- `belongs_to :target_unit, class_name: "LU::Unit", optional: true`

`target_unit_id` should be optional because some references may be parsed before they are resolved.

### `LU::Definition`

Represents a defined term and its scope.

This should be added when the application begins extracting definitional structure from the code, but it is worth reserving now because legal definitions are central to interpretation.

Suggested attributes:

- `unit_id`
- `defined_unit_id`
- `term`
- `meaning`
- `scope_type`
- `metadata` `jsonb`

Examples of `scope_type`:

- `local`
- `chapter`
- `title`
- `global`

Suggested associations:

- `belongs_to :unit, class_name: "LU::Unit"`
- `belongs_to :defined_unit, class_name: "LU::Unit", optional: true`

### `LU::Projection`

Represents a derived, non-canonical view of a legal unit.

This is where the application can store the "if-if" tree, element breakdowns, or other structured renderings of source text.

Suggested attributes:

- `unit_id`
- `projection_type`
- `format`
- `content` `jsonb`
- `generator`
- `confidence`
- `metadata` `jsonb`

Examples of `projection_type`:

- `decision_tree`
- `elements`
- `plain_language`
- `outline`

Examples of `format`:

- `json`
- `markdown`

Suggested associations:

- `belongs_to :unit, class_name: "LU::Unit"`

## Canonical vs Derived Data

The design depends on a strict split:

- `LU::Unit` stores the code as published.
- `LU::Projection` stores computed interpretations of that code.

This prevents the system from treating a generated decision tree as if it were the statute itself.

That distinction matters for:

- provenance
- debugging
- future re-generation
- user trust

Every projection should be traceable back to a single `LU::Unit` or a known set of units.

## Structural Shape

The published code is best represented as a hierarchy, but legal meaning is not purely hierarchical. A section may refer sideways or outward to definitions, penalties, or exceptions in other sections.

So the full structure is:

- a **tree** for text containment
- a **graph** for legal references
- a **projection layer** for "if-if" navigation

In short:

**hierarchy for text, graph for meaning, projection for interaction**

## Suggested Rails Layout

```ruby
# app/models/lu.rb
module LU
  def self.table_name_prefix
    "lu_"
  end
end
```

```ruby
# app/models/lu/corpus.rb
module LU
  class Corpus < ApplicationRecord
    has_many :editions, class_name: "LU::Edition", dependent: :destroy
  end
end
```

```ruby
# app/models/lu/edition.rb
module LU
  class Edition < ApplicationRecord
    belongs_to :corpus, class_name: "LU::Corpus"
    has_many :units, class_name: "LU::Unit", dependent: :destroy
    has_many :references, class_name: "LU::Reference", dependent: :destroy
  end
end
```

```ruby
# app/models/lu/unit.rb
module LU
  class Unit < ApplicationRecord
    belongs_to :edition, class_name: "LU::Edition"
    belongs_to :parent, class_name: "LU::Unit", optional: true

    has_many :children,
      class_name: "LU::Unit",
      foreign_key: :parent_id,
      dependent: :destroy

    has_many :outgoing_references,
      class_name: "LU::Reference",
      foreign_key: :source_unit_id,
      dependent: :destroy

    has_many :definitions, class_name: "LU::Definition", dependent: :destroy
    has_many :projections, class_name: "LU::Projection", dependent: :destroy
  end
end
```

```ruby
# app/models/lu/reference.rb
module LU
  class Reference < ApplicationRecord
    belongs_to :edition, class_name: "LU::Edition"
    belongs_to :source_unit, class_name: "LU::Unit"
    belongs_to :target_unit, class_name: "LU::Unit", optional: true
  end
end
```

```ruby
# app/models/lu/definition.rb
module LU
  class Definition < ApplicationRecord
    belongs_to :unit, class_name: "LU::Unit"
    belongs_to :defined_unit, class_name: "LU::Unit", optional: true
  end
end
```

```ruby
# app/models/lu/projection.rb
module LU
  class Projection < ApplicationRecord
    belongs_to :unit, class_name: "LU::Unit"
  end
end
```

## Recommended Database Constraints

For a first implementation, the following constraints and indexes are probably enough:

- unique index on `[:edition_id, :citation]`
- unique index on `[:parent_id, :position]`
- index on `edition_id`
- index on `kind`
- index on `status`
- index on `path`
- index on `reference_type`
- GIN index on `content` for `lu_projections.content`

If `path` is stored as a slash-delimited or dot-delimited ancestry path, it can support quick subtree retrieval without adding a dedicated tree gem immediately.

## Example `LU::Unit` Records

For a statute like battery, the hierarchy could look roughly like:

- Title 8
- Chapter 9
- Section 242

The section node might look like:

```json
{
  "kind": "section",
  "number": "242",
  "citation": "Penal Code 242",
  "heading": null,
  "body": "A battery is any willful and unlawful use of force or violence upon the person of another.",
  "status": "active",
  "position": 1,
  "path": "title:8/chapter:9/section:242"
}
```

If that section later has subordinate clauses or editor's notes, those can simply be child units with their own `kind`, `position`, and `body`.

## Example `LU::Projection` Content

The "if-if" view should be stored as derived JSON.

Example:

```json
{
  "kind": "decision_tree",
  "label": "Battery",
  "source_citation": "Penal Code 242",
  "children": [
    {
      "if": "willful use of force or violence",
      "children": [
        {
          "if": "upon the person of another",
          "then": "battery"
        }
      ]
    }
  ],
  "related": {
    "exceptions": [],
    "penalties": ["Penal Code 243"],
    "definitions": []
  }
}
```

This is deliberately modest. It does not claim to model all legal defenses or doctrine. It simply captures one structured rendering of the source section.

## Why Not Separate Models for Every Legal Shape

It is tempting to introduce tables like:

- `LU::Section`
- `LU::Clause`
- `LU::Exception`
- `LU::Penalty`

That tends to hard-code assumptions too early.

The published code is irregular:

- some sections have nested subdivisions and some do not
- some penalties live inline and some are cross-referenced
- some exceptions are textual fragments and some are standalone sections
- some definitions apply locally and some globally

One flexible `LU::Unit` handles those cases better than many narrowly specialized tables.

## Lean V1

If implementation begins immediately, the smallest useful first version is:

- `LU::Corpus`
- `LU::Edition`
- `LU::Unit`
- `LU::Reference`
- `LU::Projection`

`LU::Definition` can arrive once term extraction becomes important.

## Working Principle

When in doubt:

1. Preserve the statute in `LU::Unit`.
2. Link outward meaning with `LU::Reference`.
3. Generate user-facing trees in `LU::Projection`.

That keeps the text authoritative and the interactive tree replaceable.
