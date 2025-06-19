## CSS

⚠️ **CRITICAL: UNIQUE CSS ARCHITECTURE** ⚠️

### Tailwind CSS
🚨 **STOP! This is NOT standard Tailwind CSS!** 🚨

This project uses a completely different approach than typical Tailwind usage. Read these directions carefully, as they are significantly differentiated from the most typical approach to Tailwind.

**Keywords for AI assistants:** CSS, styling, Tailwind, @apply, semantic classes, four-layer architecture

#### How Tailwind classes are applied
- The markup structures defined in helpers and templates will have descriptive, semantic classnames and ids.  They will not have any Tailwind directly in the code.
- Tailwind classes can be given to those elements using the @apply directive.
- Each class (or compound selector) can have multiple places where CSS rules are added to it.  This will enable us to group related rulesets together, and to apply the same rules to multiple selectors.  This is intended to make the files more readable and maintainable, while also facilitating experiments.
- The first layer of CSS will just concern the layout techniques, which frequently will be flex, but could also use float or relative/absolute positioning.  Some of the responsive design will be applied here.
- The second layer of CSS will concern the spacing and size of elements.  This is where responsive design will be applied.
- The third layer of CSS will concern fonts, colors, and other properties.  These values should generally be stored in CSS variables.  This layer has been split into two directories: one for typography, one for colors.
- The fourth layer of CSS will concern the state of elements, such as hover, focus, and active.
- Tailwind has its own three layers: base, components, and utilities.  These are not what I am referring to here.  We will develop our approach to utilizing these as we progress.

#### How Tailwind files are organized
- Each one of the four layers described above will have its own subdirectory.
- Those subdirectories can contain any number of files.  A file should group together elements that are related to each other.  One of the primary ways they would be related is based on how deeply they are nested in the markup structure.

#### Directory Structure
```
app/assets/tailwind/
├── layout/          # Layout techniques (flex, positioning, responsive)
├── sizing/    # Element spacing, sizing, responsive
├── typography/      # Font properties
├── colors/          # Colors using CSS variables
├── situation/           # Hover, focus, active states
└── application.css    # Imports all layers in order
```

#### Examples

**❌ WRONG - Don't do this:**
```html
<!-- Never put Tailwind classes directly in HTML -->
<nav class="fixed top-0 left-0 right-0 bg-white border-b shadow-sm">
  <div class="flex items-center justify-between max-w-6xl mx-auto px-6 py-4">
    <a href="/" class="text-xl font-bold text-gray-900 hover:text-blue-600">Brand</a>
  </div>
</nav>
```

**✅ CORRECT - Do this:**
```html
<!-- Use semantic classnames -->
<nav class="main-navigation">
  <div class="nav-container">
    <a href="/" class="brand-link">Brand</a>
  </div>
</nav>
```

```css
/* layout/navigation.css */
.main-navigation {
  @apply fixed top-0 left-0 right-0;
}
.nav-container {
  @apply flex items-center justify-between max-w-6xl mx-auto;
}

/* sizing/navigation.css */
.nav-container {
  @apply px-6 py-4;
}

/* colors/navigation.css */
:root {
  --nav-bg: theme('colors.white');
  --brand-color: theme('colors.gray.900');
}
.main-navigation {
  background-color: var(--nav-bg);
  @apply border-b shadow-sm;
}
.brand-link {
  color: var(--brand-color);
}

/* typography/navigation.css */
.brand-link {
  @apply text-xl font-bold;
}

/* situation/navigation.css */
.brand-link:hover {
  @apply text-blue-600;
}
```

#### Key Rules
1. **HTML**: Only semantic classnames (e.g., `main-navigation`, `nav-link`, `brand-link`)
2. **CSS**: Use `@apply` directive for all Tailwind classes
3. **Colors and Fonts**: Define in CSS variables in `variables/colors.css` and `variables/typography.css` files
4. **Organization**: Split related styles across the four layers
5. **Import Order**: application.css imports layers layout→sizing→typography→colors→situation
