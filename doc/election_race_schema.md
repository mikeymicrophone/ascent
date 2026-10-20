# Election and Race schema

`SeparateRacesFromElections` follows the jurisdiction migrations. It prepares the schema without changing application models, routes, views, factories, or seeds. It does not create Race records from existing Elections or convert existing references. Apply these migrations to an empty database when the application and seed updates are ready. Existing dependent records require conversion or removal first.

## Ownership

| Election | Race |
| --- | --- |
| Jurisdiction and Year references | Election and Office references |
| Required name and election date | Candidacies, with their ratings and stances |
| Optional kind, such as primary, general, or special | One current baseline per voter, plus baseline history |
| Optional early-voting start and end dates | Race-specific approval totals and results |
| Mock and historical flags | Race-specific description and status |
| Event-wide description and status | |

The existing `elections` table retains Year, status, description, mock and historical flags, and timestamps. It gains a required Jurisdiction reference and name, an optional kind, and optional early-voting dates. Its Office reference is removed. Election date becomes required.

`races` is a new table with required Election and Office references, status defaulting to `upcoming`, an optional description, and timestamps. It has its own status because one Race can be cancelled or completed while other Races in its Election continue. It inherits its calendar and mock/historical context from Election; this schema adds no Race-level overrides.

The schema permits an Election with no Races while its contests are being assembled, or with one Race. Sharing a jurisdiction and date does not merge Elections. There is no uniqueness constraint on that combination, so separate events can occur on the same day. Primary and general events are separate Elections, with their own Races.

## Candidacies and baselines

`candidacies.race_id` replaces `candidacies.election_id`. Person, candidacy status, party affiliation, announcement date, and platform summary remain on Candidacy. Ratings, rating archives, and stances retain their Candidacy references. Their Race and Election context will come through Candidacy when the models are updated.

`voter_election_baselines` becomes `voter_race_baselines`, and `voter_election_baseline_archives` becomes `voter_race_baseline_archives`. Both receive required Race references in place of Election references. A unique index permits one current baseline per voter and Race. The same voter can set different baselines for different Races within one Election. Archive records can repeat for the same voter and Race.

Approval aggregation, winner selection, and Office's current-office-holder lookup belong to Race in the subsequent model changes. This migration does not move those Ruby methods or change the existing rating-above-baseline rule.

## Calendar boundaries

The early-voting fields store jurisdiction-local dates, not daily opening hours. Either date may remain unknown. When both are present, the start must be on or before the end. Neither may be later than Election date. Equality with Election date is allowed; the constraint does not impose an extra statutory cutoff.

The migration does not add registration deadlines, party eligibility, a general rules document, or per-Race calendar overrides.

## Remaining application decisions

- Enforce that each Race's Office represents its Election's Jurisdiction when the models are updated. These foreign keys ensure that referenced records exist; they do not enforce that cross-record match.
- Define the Race status vocabulary and its relationship to Election status. The schema stores the statuses independently and does not propagate changes between them.
- Define multi-seat and tied-result behavior before changing the existing single-winner calculation. This migration adds no seat count or tie-breaking rule.
- Implement residency and eligibility classification, including historical participation snapshots, before presenting separate in-district and outside-district totals. This schema does not classify existing opinions or treat them as verified local votes.

The application rename, query changes, UI grouping, and seed updates remain follow-up work. The development database has not been migrated.
