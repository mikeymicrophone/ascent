# Law Model Discussion

## Purpose

This document captures the current design discussion about how to model law for a product that helps people understand what they can and cannot do.

The goal is **not** to build a perfect liability engine.

The goal is to build a **good guide**:

- source-backed
- explainable
- portable across jurisdictions
- practical for scenario-based navigation

## Product Goal

The system is meant to answer questions closer to:

- Can I use force here?
- Can I carry this?
- Can I detain someone?
- Can I remove someone from my property?

It is **not** meant to guarantee legal outcomes.

That distinction matters because it changes the architecture.

If the system were trying to predict liability, it would need much deeper modeling of:

- case law
- burdens of proof
- procedural posture
- jurisdiction-specific exceptions
- fact disputes

For a guide product, that level of completeness is unnecessary and probably counterproductive.

## Core Design Principle

Separate the system into:

1. a **source-law layer**
2. a **guide layer**

The source-law layer preserves legal text and structure.

The guide layer turns that material into scenario-oriented questions, warnings, and outcomes.

This keeps the legal source authoritative and the user-facing guidance editable.

## Why A Source Layer Still Matters

Even if the product is only a guide, it still needs:

- traceability
- provenance
- updateability
- a way to explain where guidance came from

Without a source layer, the guide becomes disconnected from the actual law and cannot be maintained responsibly.

## Proposed Source Namespace: `LU`

The proposal was to namespace source-law models under `LU`, meaning **Legal Unit**.

This solves a practical naming problem. Terms like `Unit`, `Reference`, `Definition`, and `Edition` are too generic to leave in the global model namespace.

The `LU` namespace is a concession to namespacing, but a useful one.

## Basic Source Structure

The proposed source-law models are:

- `LU::Corpus`
- `LU::Edition`
- `LU::Unit`
- `LU::Reference`
- `LU::Definition`
- `LU::Projection`
- optionally `LU::CitationAlias`

### `LU::Corpus`

Represents a legal body.

Examples:

- United States Code
- California Penal Code
- Louisiana Revised Statutes

### `LU::Edition`

Represents a dated or published version of a corpus.

This matters because the code changes over time, and the system should be able to say which version it is using.

### `LU::Unit`

This is the canonical source-text node.

It is the backbone of the system.

Rather than creating separate models for:

- title
- chapter
- article
- section
- subdivision
- paragraph
- clause

the system should use **one model** with flexible fields such as:

- `official_kind`
- `normalized_kind`
- `designator`
- `heading`
- `body`
- `citation`
- `position`
- `path`
- `status`

This makes the structure portable across states without needing a custom ontology for every jurisdiction.

### `LU::Reference`

Represents cross-references between legal units.

Examples:

- exception references
- penalty references
- definition references
- general cross-references

### `LU::Definition`

Represents defined terms and scope.

This may be useful later, even if it is not critical for initial ingestion.

### `LU::Projection`

Represents a derived representation of a legal unit.

This is where rough decision trees or element breakdowns can live.

Important: projections are **not** canonical law. They are computed artifacts.

### `LU::CitationAlias`

Represents alternate citation forms.

This is important for states where the same legal provision may be cited in multiple ways.

## Canonical Rule

The most important modeling decision is:

**`LU::Unit` is canonical.**

The guide tree is not canonical.

The “if-if” representation is not canonical.

A projection may be useful, but it should always remain secondary to the source text.

## Why Not Build Only A Decision Tree

A pure decision tree is attractive, but too lossy.

It collapses:

- statutory hierarchy
- legal references
- effective dates
- repealed text
- citation structure

into one interaction model.

That makes ingestion fragile and later maintenance difficult.

The tree should be treated as a **view**, not as the underlying legal data model.

## Why Not Model Full Liability

The system does not need to make final legal determinations.

Instead, it should produce practical outputs such as:

- generally allowed
- generally prohibited
- fact-sensitive
- exception-heavy
- unclear from code alone
- seek counsel

This is much more honest and much more useful for a guide product.

## Guide Layer

On top of the `LU` layer, the product should likely have a separate guide-oriented layer.

A likely structure would be:

- `Guide::Topic`
- `Guide::Node`
- `Guide::Edge`
- `Guide::Source`

### `Guide::Topic`

A scenario domain such as:

- use of force
- carrying weapons
- entry onto property
- detention
- recording communications

### `Guide::Node`

A question, outcome, warning, or note.

Example kinds:

- `question`
- `outcome`
- `warning`
- `note`

### `Guide::Edge`

Represents branches between guide nodes.

Example labels:

- yes
- no
- depends
- unclear

### `Guide::Source`

Links guide nodes back to one or more `LU::Unit` records.

This preserves accountability between the source material and the user-facing guide.

## Product Writing Rule

Every guide statement should be one of:

- a direct paraphrase
- a simplification
- a warning about uncertainty

The guide should never sound more certain than the source material supports.

## Why Federal Law Is A Good Starting Testbed

Federal law was identified as a useful starting point for debugging the structure.

Not because it is the end target, but because it is structurally cleaner and easier to ingest as a first pass.

In particular, federal law helps test whether the source model can handle:

- hierarchy
- citations
- dated editions
- cross-references
- codified structure

The recommended first testbed was a limited slice of federal law rather than an entire national corpus.

## Why The Model Must Be Broader Than “One Penal Code”

One of the key conclusions from the 50-state discussion was that the model should not assume:

- one criminal code per jurisdiction
- one citation scheme per jurisdiction
- one hierarchy shape per jurisdiction

States differ in packaging and citation style.

The model therefore needs to support:

- multiple corpora per jurisdiction
- official and normalized unit kinds
- non-numeric designators
- citation aliases
- cross-corpus references

This does not mean honoring every state’s fantasies in full detail. It means covering the majority of real publication structures without hard-coding one state’s editorial shape into the model.

## 50-State Portability Assumptions

The design should assume:

- hierarchy is common
- references are common
- definitions are common
- editorial labels vary
- citation formats vary
- criminal rules often spill outside a single “penal code”

The following design choices were identified as especially important for portability:

- `official_kind` and `normalized_kind` on `LU::Unit`
- `designator` as a string, not an integer
- explicit `LU::Edition`
- optional `LU::CitationAlias`
- typed `LU::Reference`

These choices allow the structure to capture the lion’s share of law without overfitting to one state.

## Practical V1

A good first version of the source layer is:

- `LU::Corpus`
- `LU::Edition`
- `LU::Unit`
- `LU::Reference`
- `LU::Projection`
- optional `LU::CitationAlias`

A good first version of the guide layer is:

- `Guide::Topic`
- `Guide::Node`
- `Guide::Edge`
- `Guide::Source`

That is enough to:

- ingest a body of law
- preserve its structure
- attach references
- create a scenario tree
- trace guide outputs back to source material

## Recommended Development Order

1. Build the `LU` source-law backbone.
2. Ingest one limited legal corpus.
3. Confirm hierarchy and citations work.
4. Build one narrow guide topic.
5. Link guide nodes back to source units.
6. Only then expand jurisdictional scope.

## Summary

The discussion converged on the following view:

- The product is a guide, not a perfect legal reasoning system.
- It still needs a disciplined source-law layer.
- `LU::Unit` should be the canonical representation of legal text.
- Scenario trees belong in a separate guide layer.
- Federal law is a useful structural testbed.
- The model should be broad enough to support most state publication patterns without trying to mirror every jurisdiction’s editorial idiosyncrasies.

In short:

**preserve the law as source, derive the guide as product**
