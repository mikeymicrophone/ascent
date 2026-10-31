# Ahoy events

Ascent stores visits and events in `Ahoy::Visit` and `Ahoy::Event`. Browser events use the Ahoy JavaScript shipped with `ahoy_matey`; account creation, connections, save outcomes, and publication changes are recorded by Rails controllers.

## Event reference

| Name | Trigger | Additional properties |
| --- | --- | --- |
| `page_viewed` | Initial page load or completed Turbo visit, including result-list pagination | `previous_path`, optional `frame_id` |
| `page_engaged` | Once per view after 20 seconds with the tab visible and focused, or a tracked interaction | `qualification`: `active_time` or `interaction` |
| `navigation_used` | An HTTP or HTTPS link is clicked | `label`, `placement`, `destination`, `destination_host`, `external` |
| `browse_refined` | A filtered page renders, including a reload, or a map shape is selected by pointer or keyboard | Filters: `filter_names`, `query_length`, `result_count`. Map: `method: map_selection`, `destination`, `state_code` |
| `signup_completed` | Email registration persists a voter, or Google creates a voter | `method`, `landing_path`, optional `inviter_id` |
| `rating_changed` | A changed chart drag or slider adjustment ends | `race_id`, `race_mode`, `view`, `candidacy_id`, `input_method`, `rated_count`, `candidate_count`, `off_ballot` |
| `baseline_changed` | A changed chart drag or slider adjustment ends, or a nudge button changes the baseline | `race_id`, `race_mode`, `view`, `input_method`, `direction`, `approval_count_changed` |
| `mountain_save` | A save request starts and then succeeds or fails; a changed draft is explicitly discarded | `outcome`, `race_id`, `race_mode`. Save attempts also have `attempt_id`, `first_save`, `rated_count`, `candidate_count`, and, when a draft exists, `seconds_since_first_edit`. Failures have `error_type`. |
| `mountain_visibility_changed` | A successful transition between public and private | `race_id`, `race_mode`, `previous_visibility`, `visibility` |
| `share_action` | A share control is used, then resolves, is cancelled, or fails | `outcome`, `method`, `referral_id`, `target_type`, `target_id`, `destination`, `placement` |
| `invite_opened` | A valid invite URL is opened, including by an existing voter | `inviter_id`, `already_signed_in` |
| `connection_created` | An invited signup creates a connection, or an existing voter creates a new connection | `connection_id`, `inviter_id`, `source`: `invited_signup`, `leaderboard`, or `influencer` |

All events carry `page_type`, `path`, `signed_in`, and an optional `record_id`. Public influencer pages include the influencer's voter ID as `record_id`. Events also carry a `referral_id` after a shared link is opened during the same Ahoy visit. Ahoy stores visit acquisition and device properties separately.

Pagination promotes result-list frame navigation to a Turbo visit. Tracking waits for `turbo:load` and records that visit once, with its `frame_id`. Lazy candidate-card loads do not count as page visits.

Search events store query length and filter names, without search text. Event paths omit query strings and replace invite and influencer tokens with `:token`. Navigation labels use the visible text or accessible label, limited to 160 characters. Candidate and baseline interaction events describe usage without copying numerical ratings into analytics.

Rating counts and approval changes use candidates on the ballot. An off-ballot rating still generates an event with `off_ballot: true`. Intermediate pointer movements and slider input events do not generate events.

## Save and invitation interpretation

Draft autosaves do not generate `mountain_save` events. A save request generates `attempted` and either `succeeded` or `failed`, paired by `attempt_id`. A discard generates `discarded` without a save attempt. Count distinct successful attempts for saves; exclude discards from the attempt denominator. Saving and making a Mountain public remain separate actions.

The save duration starts when the current server draft was created. It measures the current editing period, not all earlier visits or discarded drafts. A missing save after editing can indicate unfinished work, but does not prove the voter forgot. Returning every value to its saved state automatically removes the draft without a discard event. Use current `MountainDraft` records to establish which Mountains still have unsaved changes.

`signup_completed` means an account was created. Email confirmation is a separate step. Returning Google users and linking Google to an existing email do not count as signups. `connection_created` only records new connections, not repeated presses of Connect.

Share controls append a random `ref` identifier to the outgoing URL. Its `share_action` events and the recipient's subsequent events share that identifier. The server retains the identifier for the current Ahoy visit through browsing, signup, and saving. A new shared link replaces the attribution for that visit.

Share outcomes are `attempted`, `copied`, `completed`, `cancelled`, and `failed`. A failed native share can fall back to clipboard copying with the same referral identifier. Clipboard success and share-sheet completion do not prove delivery. Follow the referral through a recipient visit, account creation, and first successful Mountain save to measure participation.

## Exclusions

Staff accounts that can review are excluded from visits and events. Ahoy excludes detected bots outside the test environment. Public Mountain image requests do not generate browser page-view events.

To exclude your own ordinary-account browser testing, set this cookie in the browser console:

```javascript
document.cookie = "ascent_analytics_exclude=1; path=/; SameSite=Lax"
```

Reload the page after changing the cookie. To resume tracking, delete it:

```javascript
document.cookie = "ascent_analytics_exclude=; Max-Age=0; path=/; SameSite=Lax"
```

Navigation tracking ignores links inside an element with `data-analytics-ignore`. Browser engagement is an approximate attention signal. It pauses while the tab is hidden or the window loses focus, and it does not prove comprehension.

Qualifying interactions are navigation clicks, rating and baseline changes, share controls, filter submissions, and map selections. Merely arriving at or reloading a filtered URL does not qualify as engagement.
