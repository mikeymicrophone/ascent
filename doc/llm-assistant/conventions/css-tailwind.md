## CSS

### Tailwind CSS
Read these directions carefully, as they are significantly differentiated from the most typical approach to Tailwind.

#### How Tailwind classes are applied
- The markup structures defined in helpers and templates will have descriptive, semantic classnames and ids.  They will not have any Tailwind directly in the code.
- Tailwind classes can be given to those elements using the @apply directive.
- Each class (or compound selector) can have multiple places where CSS rules are added to it.  This will enable us to group related rulesets together, and to apply the same rules to multiple selectors.  This is intended to make the files more readable and maintainable, while also facilitating experiments.
- The first layer of CSS will just concern the layout techniques, which frequently will be flex, but could also use float or relative/absolute positioning.  Some of the responsive design will be applied here.
- The second layer of CSS will concern the spacing and size of elements.  This is where responsive design will be applied.
- The third layer of CSS will concern fonts, colors, and other properties.  These values should generally be stored in CSS variables.
- The fourth layer of CSS will concern the state of elements, such as hover, focus, and active.
- Tailwind has its own three layers: base, components, and utilities.  These are not what I am referring to here.  We will develop our approach to utilizing these as we progress.