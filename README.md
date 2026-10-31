# Ascent
## Approval Voting with Expressive Ballot Control

Election Reform is a popular topic, but one that is complex and difficult to test.  This Rails application, Ascent, is designed to make many types of experiments possible.

### Ascend: Multi-Vote Elections (with conditional votes)

Some people believe that the spoiler effect is basically dominating every aspect of our election system.  By removing the spoiler effect, we might have a less dramatic process, and it might lead to a better government.

The primary goal of this project is therefore to familiarize voters with the possibilities created by a multi-vote approach.

### The Scent: Simulating Complex Preferences

When voters have access to multiple votes, and multiple candidates, you can start to see a lot of detail about their preferences.  The candidates can see those preferences, and factor them into a sophisticated approach of the role they can play.

If we can use the Ascent system to simulate how many groups of voters with different preferences can combine to create a result, it may be useful.

### Assent: Coherence in Policy Conceptualization

Since we give voters a way to opine about specific policy proposals, it is a nudge towards emphasizing the powers that each particular office is truly responsible for.  Perhaps, not every municipal public servant will need to weigh in on the latest "culture war".

A pretty interesting side benefit would be if we established a decent way for citizens to understand what is legal for them, as well as what services they can access.

## Database requirements

The pending [jurisdiction schema](doc/jurisdiction_schema.md) uses PostGIS within PostgreSQL. Install the PostGIS server extension and GEOS before applying it. The subsequent [Election and Race split](doc/election_race_schema.md) separates shared voting events from office contests. Models and factories now use these schemas. The migrations do not convert existing data; controllers, routes, views, and seeds still need updates before applying them to the working application.

## Account access

Signup, login, confirmation resend, and password reset share a MICharisma account layout. The design uses plum and cream, Bricolage Grotesque, and Ascent's mountain mark. The form partials live in `app/views/devise/shared`, with scoped `authentication.css` files in the existing Tailwind folders. Accounts remain specific to Ascent.

Google sign-in uses `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`, or Rails credentials at `google.client_id` and `google.client_secret`. Both values must exist when Rails boots for the Google button to appear. Restart Rails after changing them. Verified Google emails link to an existing Ascent voter with that email; otherwise Google sign-in creates a confirmed voter.

Register the exact callback URL in the Google OAuth web client's authorized redirect URIs:

- Local Rails server on port 3000: `http://localhost:3000/voters/auth/google_oauth2/callback`
- Staging: `https://ascent-staging-staging.up.railway.app/voters/auth/google_oauth2/callback`
- Production: the production HTTPS origin followed by `/voters/auth/google_oauth2/callback`.

Google rejects `.test` callback hosts under its [redirect URI validation rules](https://developers.google.com/identity/protocols/oauth2/web-server#uri-validation). For local OAuth, run Rails on `localhost` and start sign-in on that same origin, or use a registered public development hostname. Ordinary page previews can still use `https://ascent.test`.

Outbound account email uses PostShiba with `POSTSHIBA_API_KEY`. Production uses the sender `Ascent <no-reply@were.ascent.ing>`, reply-to `support@ascent.ing`, and `https://ascent.ing` for account links. The production key is managed in Doppler's `ascent` project, `prd` configuration, and must also be supplied to the Railway app service. Delivered email and account links need verification after DNS is configured. Automated account tests use the test mailer and mocked Google responses. See [ASC-112](https://linear.app/ascent-approval/issue/ASC-112/configure-transactional-email-for-account-confirmation-and-password).

## Seed Data

The seed repository's [entity catalog](db/seeds/ascent_seed_data/catalog/README.md) lists existing codes by type and state. Its [contributor guide](db/seeds/ascent_seed_data/CONTRIBUTING.md#find-existing-records) documents offline lookup and catalog regeneration.

County geographic identifiers use `fips`, a five-digit string such as `"01001"`. Run `bin/rails db:migrate` before importing the updated county manifests. Replace County `attributes.code` with `attributes.fips` in other seed files; top-level entity codes and Country and State code attributes keep their existing meanings. The migration preserves county values and fills missing FIPS from recorded county Census GEOIDs. It stops if existing values disagree. The boundary importer uses FIPS for county matching and fills missing county FIPS when it records a boundary.

Ascent has two explicit seed layers:

- **Reference data** is the factual geographic and election-calendar foundation. Its YAML is sourced from the Git submodule at `db/seeds/ascent_seed_data`, and `bin/rails db:seed` (including `bin/setup`) loads only this layer.
- **Simulated data** is the intentionally fictitious demo experience: people, voters, generated offices/elections, policies, ratings, and Mountain baselines. It never runs as part of normal setup. Load it explicitly with `bin/rails seed_data:simulated`.

The simulated people and voters live in `db/seeds/simulated/data`, outside the reference-data submodule. Future sourced 2026 races belong in the reference layer; they should not be generated by the simulated election or candidacy seeders.

Manifest imports treat upcoming races as active so they appear in the Mountain index. Reference seeding also activates existing upcoming races. Election calendar statuses remain separate. Completed and cancelled race statuses are preserved.

For a focused person and candidacy preview in development, run `bin/rails seed_data:profile_scenario`. It adds the mock New York Civic Forum 2026, with three fictional candidates sharing six approaches but giving different explanations. Marisol Vega has a generated portrait, a locally generated narrated introduction, and an embedded-player example. Her social handle is illustrative. Repeating the command updates the same scenario. It does not run in production or as part of ordinary setup.

Run this after seeding reference data, with the app served at `https://ascent.test`. The scenario uses the New York State jurisdiction and that hostname for its local images, video, and campaign-page links.

Profile images are `Image` records shared through `ImagePlacement` records for people and candidacies. The migration moves existing person portraits into that library. For seed files, replace the former Person portrait attributes with Image attributes and explicit ImagePlacement references; see the data repository's `CONTRIBUTING.md` and `examples/profile_images.yml`. Admin profile forms can add images or reuse existing ones. Image details are shared; display order and removal belong to each placement.

Image files use Active Storage. Admin forms accept JPEG, PNG, and WebP uploads up to 10 MB. Uploaded files use the configured storage service, and the development scenario attaches its existing generated portrait. Source URLs from seed files remain valid external image links; importing a URL does not download it. Upload or attach the file to use stored variants. The named variants use libvips through `image_processing`: `avatar` crops to 96×96, `thumbnail` fits within 320×320, `portrait` crops to 800×1000, and `large` fits within 1600×1600. The header uses `portrait`; additional photos use `thumbnail` and link to `large`. The Docker image already includes libvips; local development needs it too.

OpenAI portrait generation is implemented in `PortraitGenerator`, but remains disabled pending legal review. `config/initializers/portrait_generation.rb` sets `enabled = false`; an API key alone cannot enable it. The admin style selector and Generate portrait button are disabled, and there is no generation route or background trigger. Do not enable the service or wire a trigger until the legal review is complete and activation is approved.

The prepared styles are pen and ink, an imagined legislative-chamber scene, a voting-booth scene, and a randomized American pastime such as driving, volunteering, or a picnic. The service requires an attached reference image from the person or candidacy and uses the [OpenAI image edits API](https://developers.openai.com/api/reference/resources/images/methods/edit). It expects `OPENAI_API_KEY` only after activation. The configured model is `gpt-image-2.5-sunburst`, requesting one 1024×1536 PNG. Generated files retain the prompt, model, style, chosen pastime, timestamp, and reference image/blob IDs in Active Storage metadata. Profiles label them AI-generated illustrations. Automated tests use mocked provider responses; no live API call is part of setup or verification.

The initial 2026 race collection is one file per U.S. state's gubernatorial general election in `races/2026/governor/`. Each record includes its primary date and a source URL. U.S. territories will be added only after their jurisdictions are represented in the reference geography.

The New York 2026 general-election ballot lines live under `races/2026/new_york/`, split by office level and then by office or county. `conflicts.csv` in that directory records disagreements between sources. A seeder reads every YAML file in a directory, including files in nested directories, so a dataset can stay split without a code change.

For local setup, run `bin/setup` so the submodule is initialized before `db:prepare`.

During the transition, the app still falls back to the legacy `db/seeds/data` directory if the submodule is missing.
To copy the current legacy YAML into the submodule working tree, run:

```bash
bin/rails seed_data:copy_legacy_to_submodule
```
