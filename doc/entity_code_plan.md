# Entity codes and seed manifests for Ascent

Ascent's seeds are moving onto the MICharisma Inc entity-code design shared with AthleteAce: every seeded record carries a structured, catalog-relative code, and reference data is replayed from `micharisma-seeds/v1` manifests. The design and its decision record live in AthleteAce: [entity-codes-and-seed-library-proposal.md](https://github.com/mikeymicrophone/AthleteAce/blob/codex/yaml-seasonal-seeding/docs/entity-codes-and-seed-library-proposal.md), [entity-code-decisions.md](https://github.com/mikeymicrophone/AthleteAce/blob/codex/yaml-seasonal-seeding/docs/entity-code-decisions.md), and the [Ascent adapter sketch](https://github.com/mikeymicrophone/AthleteAce/blob/codex/yaml-seasonal-seeding/docs/ascent-seed-adapter-sketch.md). This document records how those ideas map onto Ascent's schema and the decisions made for Ascent on October 20, 2026.

## Elections, races, and the design's "Election"

The design was written before Ascent separated races from elections. Its "Election" is one contest for one office, which is an Ascent **Race**. An Ascent **Election** is a dated voting event in one jurisdiction; Ascent keeps one Election per jurisdiction per contest, and each event has its own code.

| Ascent record | Code | Example |
| --- | --- | --- |
| Election (event in one jurisdiction) | `ELECTION-{jurisdiction path}-{contest key}` | `ELECTION-USA-NY-ASSEMBLY-AD_125-2026_GENERAL` |
| Race (contest for one office) | `RACE-{office path}-{contest key}` | `RACE-USA-NY-COUNTY_ERIE-SHERIFF-2026_GENERAL` |
| Candidacy | `CANDIDACY-{office path}-{contest key}-{username}` | `CANDIDACY-USA-NY-ASSEMBLY-AD_125-2026_GENERAL-{username}` |
| JurisdictionBoundary (the design's district map edition) | `BOUNDARY-{jurisdiction path}-MAP_{year}` | `BOUNDARY-USA-NY-ASSEMBLY-AD_125-MAP_2024` |

- **Jurisdiction path:** each place's code without its type marker. `STATE-USA-NY` has the path `USA-NY`; `DISTRICT-USA-NY-ASSEMBLY-AD_125` has `USA-NY-ASSEMBLY-AD_125`.
- **Office path:** the jurisdiction path, plus a position token when the jurisdiction holds more than one office (`USA-NY-GOVERNOR`, `USA-NY-COUNTY_ERIE-SHERIFF`). A district that elects one seat needs none.
- **Contest key:** year and Election kind, such as `2026_GENERAL` or `2026_SPECIAL`. A special election is its own Election even when it shares a date and jurisdiction with a general one, so the converter needs source-backed rules for marking specials (Florida's SD 21 special, Virginia's HD 20 special, and Virginia's "- Special" local offices).
- Certification status (`certified`, `tentative`, `unofficial`) stays out of every code, as the decision record requires.

Other codes follow the design: `COUNTRY-USA`, `STATE-USA-NY`, `COUNTY-USA-NY-ERIE`, `MUNICIPALITY-USA-CT-HARTFORD`, `DISTRICT-USA-NY-ASSEMBLY-AD_125`, `POSITION-STATE_SENATOR`, `OFFICE-{office path}`, and `PERSON-{username}`. Local office path shapes should be settled on real rows during conversion.

Codes use uppercase letters, digits, dashes, and underscores, so a Person's code uppercases its lowercase username (`PERSON-KELLES_ANNA_NY_AD_125`). Years are not coded: `YEAR-2024` names the year itself.

## Storage

- **`entity_code` columns** hold each record's preferred code, catalog-relative (the `MIC-ASC-` prefix comes from configuration), with a unique index on each coded table.
- **`entity_codes`** (ported from AthleteAce's `EntityCode`) registers every issued code, preferred and alias, against its record's current preferred code. Registering preferred codes as well as aliases gives one uniqueness check across all types in the catalog and one place to resolve any code.

## Person usernames

Candidates receive provisional usernames, generated as `{surname}_{given}_{state}_{seat}`. Examples: `kuhn_dawn_ny_ad_7`, `lalota_nicholas_ny_cd_1`, and `healey_ma_governor` (the ballot prints only the surname). The rules:

- Lowercase letters, digits, and underscores. Middle names, nicknames, and suffixes are omitted; accents are converted to plain letters and punctuation is removed.
- The seat is the office's seat code (`ad_125`), the position token for statewide offices, or place plus position for local offices.
- Collisions take `_2`, `_3`, and so on; a shared name never merges two people. Once issued, a username is committed in the manifest and reused on every replay.
- `username_status` is `provisional` until an update request replaces the username, for example with a verified Instagram handle. The Person keeps its identity; the old Person and Candidacy codes become aliases.

Open before the first replacement: how handles containing periods are encoded, and how conflicting update requests are resolved.

## Ballot lines and endorsements

Decided October 21, 2026. A printed ballot line is an official fact; an endorsement is voluntary support. They are separate records, linked where they overlap.

- **BallotLine:** one per printed line on a Candidacy, recording the label exactly as the source prints it. Its kind is `party`, `designation` (Massachusetts labels such as "Gulf War Veteran"), `petition` (Connecticut's "Petitioning Candidate"), `write_in`, or `unclassified`; only a party line references a Party. `unclassified` marks a printed label whose kind has not been established from the state's list of parties, which is how the current row seeder records every label other than write-ins and petitions until conversion classifies them. A fusion candidate keeps one Candidacy, the single thing voters approve, with several BallotLines. BallotLines are refreshed from official sources and carry no codes of their own, consistent with the decision record's exclusion of coded `BallotLine` entities.
- **Endorsement:** an endorser (a Party or Person today; Organization once it is modeled) supporting a Candidacy, with the strength and dates planned in the approval-voting PRD's multi-endorsement party tools. A party can endorse several candidates in one race, and can endorse where it has no line, such as Florida's nonpartisan judicial races.
- **The link:** a party's BallotLine also counts as that party's endorsement. It appears as an Endorsement of kind `ballot_line`, created and refreshed with its BallotLine, so a party's endorsements include its fusion lines. Endorsements of other kinds are never changed by a seed refresh of the official lines.
- **Party:** a ballot-qualified party within a state, coded `PARTY-{state path}-{party}` (for example `PARTY-USA-NY-WORKING_FAMILIES`). The same name in two states is two Parties.

## Phases

1. **Foundation (done October 20, 2026).**
   - `lib/micharisma_seeders` is a submodule of [micharisma_seeders](https://github.com/mikeymicrophone/micharisma_seeders), pinned to `main`. It is excluded from `autoload_lib`, and `MICharisma` is an inflection acronym. AthleteAce pins a later commit on `codex/published-seed-schemas` that adds schema-export tooling.
   - `AddEntityCodes` adds `entity_code` to countries, states, counties, municipalities, districts, positions, offices, elections, races, people, and candidacies; creates `entity_codes`; and adds `people.username`, `people.username_status`, and `offices.seat_code`.
2. **Importer (done October 21, 2026).**
   - `Seeds::LibraryImporter` is ported from AthleteAce as Ascent's persistence adapter for the coded types above. It resolves references by code or alias, retries records until their dependencies exist, creates missing records, adopts uncoded records created by the reference seeders through natural keys (for example a Position's title), preserves differing existing values and reports them as conflicts, and registers preferred codes and aliases. `bin/rails seed_library:validate` and `seed_library:import` read `db/seeds/ascent_seed_data/manifests`, or the folder named by `SEED_LIBRARY_ROOT`.
   - A jurisdiction reference names the owning place's code (`jurisdiction: DISTRICT-USA-NY-ASSEMBLY-AD_125`); a place imported without a Jurisdiction gets one nested under its parent (a District's parent comes from its `state` scope).
   - BallotLines have no codes, so a manifest lists them on their Candidacy as `ballot_lines`, each with a `label` and optional `kind` and `party` code. Lines are added, never removed; a differing existing line is reported.
   - `AddBallotLinesAndEndorsements` creates `parties`, `ballot_lines`, and `endorsements`, adds `candidacies.participation` (`active`, `inactive`, `off_ballot`) and `races.certification_status` (`certified`, `tentative`, `unofficial`), and removes `candidacies.party_affiliation`, refusing to run while any candidacy still has a value there. Views show `Candidacy#ballot_labels`; the candidacy form edits participation instead of a party string.
   - The [Kelles manifest](../spec/fixtures/seed_library/kelles_2024.yml) imports as one Candidacy with two BallotLines and two `ballot_line` Endorsements, and re-importing it changes nothing.
   - Entity-sequence lookups are refused with a clear error until Phase 3 installs their recipes.
3. **Converter and New York pilot.** Convert the raw ballot rows in `ascent_seed_data/races/2026/` into manifests: one Candidacy per person per race with a BallotLine for each printed line, a Party for each state's party labels (designations, petitions, and write-ins are BallotLine kinds, not Parties), mark specials, issue provisional usernames, and write a judgments report (name discrepancies through a source-spelling disambiguation file, disputed candidates included as off-ballot but approvable, unmapped fields, missing evidence). Install the sequence recipes below if the converter's manifests use them. Pilot on New York's statewide races plus competitive Assembly, Senate, and House races.
4. **Full conversion.** Convert all five states. The reference seed layer imports manifests, and `BallotLineSeeder` becomes the converter's row reader, renamed so it is not confused with the BallotLine model.
5. **Later.** Username update requests, public `/entities/:code` addresses that resolve aliases, fan lookup, and per-attribute update rules.

## Sequence registry

`10_01` (Person) and `10_02` (Office) are the approved starting assignments. Proposed: `10_03` Election (jurisdiction from scope, contest key in the code), `10_04` Candidacy (race from scope), and `10_05` Race (office and election from scope).
