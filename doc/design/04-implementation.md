# From design to code

Ascent is a Rails 8.1 app. Its views are Phlex components written in Ruby, and its styles are Tailwind used in an unusual way: **markup carries only semantic class names, and Tailwind is applied in CSS files with `@apply`, split into four layers.** A design is easiest to build when it is handed over in those terms.

## Views are Phlex components

| Where | What | Example |
| --- | --- | --- |
| `app/views/components/` | Shared components, called by name through a Phlex kit | `ResourceIndex(collection: @races, pagy: @pagy) { RacePartial(race: it) }` |
| `app/views/components/ui/` | Small controls | `Ui::ResourceActions(resource: race)`, `Ui::ActionIcon(kind: :show)` |
| `app/views/components/forms/` | The Superform form base | `row field(:title).text` |
| `app/views/partials/` | One partial per model: how a record looks wherever it appears | `RacePartial`, `CandidacyPartial` |
| `app/views/<resources>/` | Each resource's pages: `index_view.rb`, `show_view.rb`, `new_view.rb`, `edit_view.rb`, and its form | `Views::Races::ShowView` |
| `app/views/mountains/` | The mountain: `MountainChart`, `CandidateColumn`, `RatingDot`, `BaselineIndicator`, `YAxisLabels`, and the index, show and edit views | |
| `app/views/layouts/application.html.erb` | The one ERB layout: head, navigation, flash, `main` | |

- **Props** are declared with Literal: `prop :race, Race`, `prop :heading, _Nilable(String)`. A component's props are its API, so a design's component inventory should name the inputs each component needs.
- **The page shells** wrap most pages: `ResourceIndex` (heading, New link, one block per record, filters, pager), `ResourceShow` (heading, the record, its actions) and `ResourceFormPage`. Reference data can keep them; the voting screens will want their own views.
- **Shared pieces** already exist: `Navigation`, `BrandMark`, `ActionBar`, `FlashMessages`, `FormErrors`, `Pagination`, `Stat`, `QuickStats`, `ExpandableSection` (the collapsible sections), `ItemPreview` (a few related records with View all), `ChildrenPreview`, `HierarchicalNavigation` (the breadcrumb trail) and `GeographicSummary`.
- **Icons** come from the `icon(:name)` helper (Lucide).
- **Who sees what** is decided by Action Policy, not the view: `allowed_to?` and helpers such as `can_simulate_mountains?` hide controls a visitor cannot use. Design the signed-out, signed-in and admin states of any screen with controls.
- **Interactivity** is Stimulus (`app/javascript/controllers/`): `mountain-editor` (dragging ratings and the baseline), `nav-menu` and `nav-clearance` (the phone menu), `expandable-section`, `dropdown`, `share`, and `butterfly` (debug logging). Pages are server-rendered with Turbo; there is no client-side framework.

## Class names

Every element that needs styling gets a descriptive, dashed class name for what it is, not how it looks: `candidate-column`, `baseline-line`, `rating-dot`, `action-button`, `status-indicator`. Variants add a second class (`action-button action-favorite marked`, `status-indicator status-upcoming`). A component's outer class usually matches its name (`Stat` renders `stat-item`). **Never put Tailwind utilities in markup.**

## The four layers

All styles live in `app/assets/tailwind/`, one folder per layer, and `application.css` imports them in this order:

| Layer | Folder | What goes there |
| --- | --- | --- |
| 1. Layout | `layout/` | Display, flex and grid, positioning, and the responsive changes to them |
| 2. Sizing | `sizing/` | Width, height, padding, margin, gaps, and their responsive changes |
| 3a. Typography | `typography/` | Font family, size, weight, line height, letter spacing, case |
| 3b. Colors | `colors/` | Color, background, borders and shadows, always through CSS variables |
| 4. Situation | `situation/` | Hover, focus, active, marked, disabled, and transitions between them |

Within each folder, files group related areas: `scaffold`, `navigation`, `main`, `components`, `mountain` and `pages`. **The same selector appears once in each layer it needs.** For example, `Stat`:

```ruby
span(class: [ "stat-item", @kind ]) do
  span(class: "stat-value") { @value }
  span(class: "stat-label") { @label }
end
```

```css
/* layout/components.css */
.quick-stats .stat-item { @apply flex items-center rounded-full; }

/* sizing/components.css */
.quick-stats .stat-item { @apply px-3 py-1 gap-1; }

/* typography/components.css */
.stat-value { @apply font-['IBM_Plex_Mono'] font-bold; }
.stat-label { @apply font-['Sora'] font-medium uppercase tracking-wide; }

/* colors/components.css */
.stat-value { color: var(--stat-value); }
.stat-label { color: var(--stat-label); }
```

That is the split as the layers intend it; today `layout/components.css` also carries this rule's padding and background color. A new file in any folder must be imported in `application.css`, in its layer's group.

**Tokens** are CSS variables in `variables/colors.css`: first the brand colors (`--brand-ink`, `--brand-summit` and so on, see [the brand](03-brand.md)), then role variables named for their job, which point at the brand colors (`--btn-primary-bg: var(--brand-ink)`). New colors in a design become new role variables pointing at brand tokens, never hex values in a component's rules. Fonts are named directly in `@apply font-['Sora']`; `variables/fonts.css` names them but is not imported yet.

**Responsive design** is mobile first, with Tailwind's default breakpoints (`sm` 640px, `md` 768px, `lg` 1024px, `xl` 1280px), applied in the layout and sizing layers.

The code does not follow these rules everywhere yet. Some layout files set spacing and colors, and some typography rules are repeated in two files (`.stat-value` is in both `typography/fonts.css` and `typography/components.css`). A redesign is a good time to put each rule back in its layer.

## What a handoff should include

For each screen:

1. **The component tree:** which existing components it reuses, which are new, and the props each new one takes.
2. **Class names** for every styled element, with the variants and states they have.
3. **For each class, its rules split by layer:** layout, sizing, typography, colors, situation. Tailwind utilities are the easiest form, since they go straight into `@apply`.
4. **Tokens:** any new brand color, and the role variables the design uses, with light-theme values (and dark ones, if the redesign adds a dark theme).
5. **States:** signed out, signed in, admin, empty, loading, error, and marked (for the action bar).
6. **Sizes:** phone and desktop at least, and what changes at each breakpoint.
7. **Behavior** a Stimulus controller would need: dragging, toggling, expanding, unsaved-change warnings.
8. **Accessibility:** focus order, keyboard alternatives to dragging, labels for icon-only controls, contrast of 4.5:1 for text.

Mockups as HTML with semantic class names and a separate stylesheet are the closest to how the code is built. Utilities inline in the mockup are fine as long as each element's utilities are grouped by layer, so they can be moved into the four folders.
