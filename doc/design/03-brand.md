# The brand

The current brand is new (October 2026) and deliberately small: a mark, a palette, four typefaces and one icon set. The redesign can refine any of it. What has to survive is the idea: a mountain, a climb, and an approval.

## Name and domain

**Ascent**, with a capital A. The domain is **ascent.ing**, which reads as "ascenting": assenting (approving) and ascending (climbing) at once. The development site is dev.ascent.ing. See [the product](01-product.md) for the meaning behind the name.

## The mark

Two peaks in a rounded square, with a gold check above them (`app/views/components/brand_mark.rb`, `public/icon.svg`):

- a far peak in `--brand-ink-soft` (#2e4a73), behind a near peak in `--brand-ink` (#1c2c46);
- a snowcap in `--brand-snow` (#ffffff) on the near peak;
- a check in `--brand-summit` (#b5862a) rising from the far peak's shoulder: the approval at the top of the climb.

In the navigation it sits beside the wordmark "Ascent" set in Calistoga. On hover the check deepens to `--brand-summit-deep`. The favicon puts the mark on a `--brand-paper` square with 9/40 rounded corners. The mark is drawn on a 40-unit grid as four paths; redraw it rather than scaling a screenshot.

## Palette

The brand colors live in `app/assets/tailwind/variables/colors.css`. Every other color variable is named for its job (`--btn-primary-bg`, `--action-marked-border`) and points at one of these or at a Tailwind color.

| Token | Hex | Role |
| --- | --- | --- |
| `--brand-ink` | #1c2c46 | Alpine ink: text, structure, primary buttons |
| `--brand-ink-soft` | #2e4a73 | Secondary ink, primary-button hover, the far peak |
| `--brand-link` | #28518c | Links and focus rings |
| `--brand-summit` | #b5862a | Summit gold: what a visitor has marked; borders, icons and the check |
| `--brand-summit-deep` | #7d5c17 | Gold text on light grounds |
| `--brand-summit-soft` | #f7efdc | Background of a marked action |
| `--brand-summit-wash` | #efe1bf | Hover on a marked action |
| `--brand-glacier` | #e9f0f6 | Quiet surfaces, hover, active navigation |
| `--brand-mist` | #d3dde7 | Borders on cards and the navigation |
| `--brand-paper` | #fbfaf6 | Page background |
| `--brand-snow` | #ffffff | Cards, the snowcap |

**Contrast.** Ink, ink-soft and link pass 4.5:1 on every light ground above (6.1 to 14.0). Summit-deep passes on all of them too (4.7 to 6.1). **Summit gold itself is only about 3:1**, so use it for borders, icons, the check and large text, never for body text; marked labels use summit-deep.

**Status and entity colors** still come straight from Tailwind's palette (green for active, blue for upcoming, amber for historical, and so on, plus a color per entity type such as country, state or office). They predate the brand and are the first thing a redesign should bring into it.

**Parties are not colors.** Ascent is cross-partisan. Do not color candidates or parties red and blue; a party or ballot label is text in a neutral chip.

**Themes.** There is only a light theme. A dark theme would be new work; if the redesign adds one, every token needs a dark value.

## Type

Loaded from Google Fonts in `app/helpers/application_helper.rb`:

| Family | Role | Where today |
| --- | --- | --- |
| **Calistoga** | Brand display | The wordmark, the site title, the Saved heading |
| **Sora** (100 to 800) | Interface | Navigation, page and section headings, buttons, labels |
| **Source Serif 4** (optical sizes, 200 to 900) | Reading text | Body copy, descriptions, explainers |
| **IBM Plex Mono** | Numbers | Ratings, counts and metrics |

Status chips ask for **Kanit**, which is never loaded, so they fall back to the browser's default font. Either load it or move the chips to Sora. An older note in `doc/llm-assistant/project-context/style-guide.md` lists five other fonts; it is out of date.

## Icons

Lucide, through the `phlex-icons-lucide` gem and the `icon(:name)` helper, drawn in the current text color and hidden from screen readers (the text beside an icon carries its meaning). In use: bookmark, bookmark-check, heart, bell, bell-ring, eye, eye-off, share-2, menu, x, chevron-down, chevron-right and funnel. Two hand-drawn icons (simulate and show, in `app/views/components/ui/action_icon.rb`) predate the switch to Lucide and could be replaced with Lucide equivalents.

## Shape and depth

Cards are white on paper with a mist border and soft shadows (`--shadow-subtle` to `--shadow-dramatic`). The project's owner has asked for motion with a sense of three dimensions, for example:

- rotating a row of similar items like the sides of a box as the visitor scrolls;
- a clockwise twist, like turning a faucet, to expand or collapse a section;
- moving the most popular or selected item into the foreground with parallax.

None of these are built yet. Use them where they explain something, such as a candidate rising above the baseline, and respect reduced-motion settings.

## Voice

Plain, civic and exact. Explain the method, never campaign. Name things the way the data does: a race, an office, a candidacy, a baseline. Prefer "approve" and "rating" to "vote" and "score" when the difference matters. Buttons today mix title case ("Save Changes", "View Mountain") and sentence case ("Include primary candidates"); the redesign should pick one.
