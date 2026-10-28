# Overall approval and baseline

> We get two options. But we have 322 million.

## The idea

A race mountain asks "of these candidates, whom do you approve?" The overall mountain asks a question that comes before any ballot: **of everyone, whom do you like, and where do you draw the line?**

A voter rates any person, 0 to 500, whether or not that person is running for anything, and sets one **overall baseline**. Everyone above the line is someone the voter approves of in general. It is a standing reference, independent of the current field, and it can include people outside politics: athletes, artists, business leaders, clergy, scientists, historical figures and fictional characters.

The payoff comes when a real race arrives. Ascent can show where the actual field falls against the voter's own line. "Neither nominee clears your line, and eleven people you rate above it aren't running" is the moment this feature exists to create.

## Principles

- **Same scale, same rule.** Ratings are 0 to 500 and approval is strictly above the baseline, exactly as in races, so one mental model covers both.
- **Overall never writes to a race.** An overall rating can suggest a race rating; it never saves one. A race rating never changes an overall rating.
- **Ratings belong to a person, not to a list.** Curated sets of people (ranges, below) are only lenses over the same ratings.
- **Private by default.** Like mountains, a voter's overall ratings are private to them and to admins; only thresholded aggregates are public.

## Data design

### `overall_ratings`

One rating per voter per person.

| column | type | notes |
| --- | --- | --- |
| `voter_id` | bigint, not null | |
| `person_id` | bigint, not null | |
| `rating` | integer, not null | check 0..500 |
| timestamps | | |

Unique index on `[voter_id, person_id]`; index on `person_id` for aggregates.

`overall_rating_archives` mirrors `rating_archives` (`voter_id`, `person_id`, `rating`, `archived_at`, `reason`), written `before_update` the same way `Rating#archive_previous_rating` does today.

### `voter_overall_baselines`

One line per voter.

| column | type | notes |
| --- | --- | --- |
| `voter_id` | bigint, not null | unique |
| `baseline` | integer, not null | check 0..500 |
| timestamps | | |

`voter_overall_baseline_archives` mirrors `voter_race_baseline_archives` (`baseline`, `previous_baseline`, `new_baseline`, `archived_at`, `reason`).

Why a table, not a `voters.overall_baseline` column: it gets the same archive and daily-change-limit behavior as `VoterRaceBaseline` for free. Extract the shared archive and limit logic from `VoterRaceBaseline` into a concern (`Baselined`) and include it in both.

Possible later extension: a nullable `scope` (for example per office type, "my line for a president" versus "my line for a school board member"). Start with one global line.

### People outside politics

`people` is already general (`bio`, `fictional`, `entity_code`). Add:

- `people.death_date` (date, nullable) so historical figures are marked as such.
- `person_spheres` (`person_id`, `sphere`), many per person, with `sphere` checked against a known list: `politics`, `government`, `law`, `military`, `sports`, `entertainment`, `music`, `business`, `technology`, `media`, `faith`, `science`, `activism`, `literature`, `historical`. Fictional people keep the existing `fictional` flag and can also carry a sphere ("fictional politician").
- `people.notable_for` (string, short): the one-line reason the person is in Ascent ("Point guard, Golden State Warriors").

Guardrails: only public figures; no minors; an admin-reviewed request path for anyone who wants to be removed.

### Ranges: curated sets of people

A **range** is a named set of people to rate together: "2028 possibilities", "Supreme Court", "Fictional presidents", "Late-night hosts", "Your state's delegation". The name continues the mountain metaphor: a range is a row of peaks.

`ranges`

| column | type | notes |
| --- | --- | --- |
| `name`, `slug`, `description` | string/text | |
| `curator_type`, `curator_id` | polymorphic, nullable | a `Voter` or an `Organization`; null for editorial ranges |
| `kind` | string | `editorial`, `organization`, `personal` |
| `visibility` | string | `public`, `unlisted`, `private` |
| `entity_code` | string | per `entity_code_plan.md` |

`range_memberships`: `range_id`, `person_id`, `position` (integer, for display order), unique on `[range_id, person_id]`.

Ranges are `Engageable` (follow, favorite, share), so the existing Saved page covers them.

### Aggregates (computed, not stored at first)

Per person, over `overall_ratings` joined to `voter_overall_baselines`:

- raters, approvers, approval share (approvers divided by raters), median rating
- the same split by the rater's current state, from `residences`
- shown only when raters at least a threshold (25 to start), so a small group's ratings can't be inferred

If these get expensive, add a nightly `person_approval_summaries` table (`person_id`, `jurisdiction_id` nullable, `raters`, `approvers`, `median_rating`, `computed_at`).

Fictional people are left out of real-people leaderboards by default (`Person.real`).

## How it meets races

- **Prefill.** On a race mountain, any candidate the voter has rated overall gets that rating as a suggested starting point (the same unsaved path `mountain_drafts` uses). The race baseline suggests the overall baseline.
- **Drift.** When race and overall ratings differ a lot, say so: "You rate her 80 lower in this race than overall." That makes the difference between liking a person and wanting them in an office visible.
- **Your line against the ballot.** For any race: who clears your overall line, who doesn't, and the highest-rated people in your ranges who aren't running.
- **Draft signal.** The aggregate "most approved people who aren't running", by state, is a non-partisan, shareable output.

## Connections to planned work

- Combining mountains from thought leaders and groups: a public figure or organization can publish an overall mountain and a range, and followers can compare against it.
- Sharing a mountain through verified links and QR codes: the overall mountain is the most shareable one, because it isn't tied to one ballot.
- Rating on several dimensions (character, aptitude, process and so on): overall ratings are the natural home for character; race ratings for fit to the office.
- Daily baseline-change limits: these come for free through the shared concern.

## Open questions

- One global overall line, or one per kind of office from the start?
- Can voters propose new people, or only admins add them at first?
- Should overall ratings decay or prompt a refresh after a year?
- Do aggregates count every rater, or only verified residents, as `counted_as` does for races?

## A cast that drives adoption

People sign up to rate people they already have opinions about. The cast should span the spectrum and leave politics behind, so no one reads the launch as partisan. Each group has a job.

**Calibration anchors**: near-universal goodwill, so a new voter learns what "400" feels like.
Dolly Parton, Simone Biles, Keanu Reeves, Fred Rogers (historical), Jimmy Carter (historical), Serena Williams, Shohei Ohtani

**The line matters**: people opinions split on, where the baseline visibly does the work. Balanced across the spectrum.
Donald Trump, Barack Obama, Elon Musk, Alexandria Ocasio-Cortez, JD Vance, Gavin Newsom, Ron DeSantis, Bernie Sanders, Zohran Mamdani, Tucker Carlson, Rachel Maddow

**Crossovers**: non-politicians people already ask "would you vote for them?" about. Pure overall-mountain territory.
Oprah Winfrey, Dwayne Johnson, Mark Cuban, Taylor Swift, Joe Rogan, MrBeast, Stephen A. Smith, Matthew McConaughey, Jon Stewart

**Independents and heterodox figures**: approval voting's own story, people who do better when support isn't split.
Mitt Romney, Liz Cheney, John Fetterman, Thomas Massie, Andrew Yang, Tulsi Gabbard, Joe Manchin

**Fictional politicians**: the safest, most fun first mountain, and a natural way into mock elections.
Josiah Bartlet, Leslie Knope, Selina Meyer, Frank Underwood, Laura Roslin, Mr. Smith (Jefferson Smith), Lisa Simpson

**Historical figures**: for civic educators. "Rate the founders" is a lesson plan.
Abraham Lincoln, George Washington, Franklin D. Roosevelt, Ronald Reagan, Martin Luther King Jr., Susan B. Anthony, Shirley Chisholm, Theodore Roosevelt

**Beyond politics**: spheres that pull in audiences who would never open a civics app.
Pope Leo XIV, LeBron James, Caitlin Clark, Bad Bunny, Warren Buffett, Jensen Huang, Neil deGrasse Tyson, Travis Kelce

**Local heroes**: one range per state (governor, senators, the beloved coach, the local news anchor), so the first share in every state is about home.

Launch ranges that pair these: "Would you vote for them?" (crossovers), "Fictional presidents", "The founders", "2028 possibilities", "Your state".
