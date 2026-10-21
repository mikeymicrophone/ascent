# Issues, stances, and campaign communications

A proposed design, not yet implemented. It extends the [entity-code plan](entity_code_plan.md) to the issue library, candidates' stances, and the campaign platforms and communications (video, social media, websites) that show where those stances come from. Coded records let other organizations donate seeds through pull requests to the seed-data repository: a contribution refers to existing candidacies, races, and people by their codes, adds its own records, and is checked before it is merged.

## Current state

- **Topic → Issue → Approach** is the issue library. Each record has only a title and description. The records are written as literals in the simulated seed layer's Ruby seeders, not as data, and have no codes. This matches the entity-code decision record, which treats an Approach as "a descriptive library concept, not a campaign position."
- **Stance** joins a Candidacy to an Approach with an `explanation`, a free-text `priority_level`, and a free-text `evidence_links`. It has no code, no date, no source, and no constraint against two stances on the same Approach. The seeded stances are fictional and attach only to mock elections; their evidence is prose, not links.
- **Stance shifts** ([stance_shift_implementation.md](stance_shift_implementation.md)) are designed but not built. A shift is a precise intention within a stance, such as narrowing a code or changing enforcement. It sits under Stance and is unaffected by this design.
- **Policy, OfficialCode, and the `Rule` models** cover enacted law. `Policy.status` is a string column mapped by an integer enum, so `PolicySeeder` fails with "'active' is not a valid status" and the simulated seed layer stops there.
- **Campaign communications are not modeled.** The approval-voting PRD calls for ratings of videos, texts, websites, and photos; curated multimedia; and guided stance templates. Only `Candidacy.platform_summary` holds platform text today.

## Design

The entity-code design's sourced claim is the model: a subject, a predicate, an object, and evidence (a URL, a publication date, and a supporting passage). Here a stance claims that a candidacy supports an approach, and each piece of evidence ties the stance to something the campaign said.

| Record | Code | Holds |
| --- | --- | --- |
| Topic | `TOPIC-HOUSING` | A broad subject |
| Issue | `ISSUE-HOUSING-AFFORDABILITY` | A problem within a topic |
| Approach | `APPROACH-HOUSING-AFFORDABILITY-INCLUSIONARY_ZONING`, or with a jurisdiction path when tied to one place: `APPROACH-USA-NY-CRYPTO_MINING-TIME_LIMITED_PERMIT_MORATORIUM` | A proposed response, described without reference to any candidate |
| **Channel** | `CHANNEL-YOUTUBE-{handle}` | One account on one platform (YouTube, Instagram, TikTok, X, Bluesky, Facebook, a campaign website), its owner (a Person, Party, or campaign), and whether it is official |
| **Communication** | `COMMUNICATION-{channel path}-{date}-{slug}`, for example `COMMUNICATION-YOUTUBE-{handle}-2026_10_02-DEBATE_OPENING` | One video, post, ad, speech, debate clip, interview, platform page, or mailer: its kind, publication date, canonical URL, platform ID, an archived copy's URL, and the candidacies it features |
| Stance | `STANCE-{candidacy path}-{approach path}` | A candidacy's position on an approach; one per candidacy and approach |
| **StanceEvidence** | `EVIDENCE-{stance path}-{communication path}` | Which communication supports the stance, a short quote or a timestamp within a video, and its relation: `states`, `clarifies`, or `contradicts` |

Decided October 21, 2026: **each piece of evidence is its own coded record.** Ballot lines are listed inside their Candidacy because one official source supplies them. Evidence comes from many contributors over time. If it were listed inside the Stance, two pull requests adding evidence to the same stance would each redefine the Stance, and the importer would reject the differing definitions as contradictory. Separate records referring to the Stance by its code let contributions accumulate.

Further rules:

- **Communication codes** are built from the channel, date, and a short slug because many platform IDs are case-sensitive (YouTube video IDs, for example) while codes are uppercase. The platform ID and canonical URL are attributes, and the canonical URL is the natural key that matches an existing record.
- **A campaign platform** is a Communication of kind `platform`, such as a website's issues page or a PDF, which stances cite like any other communication.
- **Verified channels and usernames:** a channel verified as a person's own can supply their username. A verified Instagram handle replaces a provisional username, and the old Person code becomes an alias.
- **Changing positions:** evidence is dated, and a `contradicts` relation records a later statement that departs from the stance. Whether a reversal becomes a new Stance or an updated one is an open decision.
- **Content ratings are voter data.** Voters' ratings of communications (the PRD's content ratings) are user history, kept apart from seeds like ratings and baselines.

## Donated seeds

- Contributions are manifests in the seed-data repository that refer to existing codes and add Topics, Issues, Approaches, Channels, Communications, Stances, and StanceEvidence.
- The manifest `source` block records the contributing organization, the source URL, and the capture date. Stances and evidence require a source; reference data in general does not, as the entity-code decision record allows.
- The importer creates missing records, never overwrites reviewed values, and reports differences as conflicts for maintainers.
- Pull requests are checked with `seed_library:validate`, which rejects unknown types and fields, contradictory definitions, and code collisions. A published contract of allowed types and fields, ported from AthleteAce's `Seeds::CatalogContract`, would let contributors validate before submitting.
- **Content policy:** links, short quotes, and timestamps only. No rehosted video or full transcripts. A deleted or edited post keeps its archived copy and is marked as removed or edited.
- Simulated stances remain limited to mock elections, so fictional positions are never attached to real candidates.

## Open decisions

1. How a channel is verified as official: a link from the campaign's website, the platform's verification badge, or a maintainer's review.
2. Whether a reversal of position creates a new Stance or is recorded as `contradicts` evidence on the existing one.
3. Who maintains the issue library, and whether it aligns with an outside taxonomy through aliases.
4. Where contributor attribution is stored beyond the manifest: on each record, or in an import ledger like Spindrift's.
5. How long a quote may be, and which archive service supplies archived copies.
6. The `Policy.status` column type: an integer column for the enum, or string-valued enum mappings.

## Phases

1. **Issue library codes.** Add `entity_code` to topics, issues, and approaches; move the Ruby literals into manifests in the seed-data repository; fix `Policy.status`.
2. **Communications and evidence.** Add Channel, Communication, and StanceEvidence; give Stance a code and a uniqueness constraint; allow these types in the importer.
3. **Contribution workflow.** Publish the catalog contract, add a contribution guide to the seed-data repository, and validate pull requests automatically.
4. **Presentation.** Show communications and evidence on candidacy and race pages, and let voters rate communications.
5. **Stance shifts**, as designed in [stance_shift_implementation.md](stance_shift_implementation.md).
