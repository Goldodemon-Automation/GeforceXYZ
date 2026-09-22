# OpenNOW design system — Black UI · grey text · Gold Bright

The interface is monochrome with a single bright accent. This document records the rules and the
files that own them, so a change in one place stays consistent everywhere.

A visual reference for the system — palette, type ramp, controls, and both layout shells — lives in
[`black-white-gold.html`](black-white-gold.html). Open it in a browser; it is a static page with no
build step.

## Palette

| Role | Dark UI | Light UI |
| --- | --- | --- |
| Surfaces | `#0D0D0D`, `#141414`, `#1A1A1A`, `#1F1F1F` | `#FFFFFF`, `#FAFAFA`, `#EDEDED` |
| Primary text (`label`) | `#EDEDED` | `#2E2E2E` |
| Secondary text (`textMuted`) | `#8A8A8A` | `#5F5F5F` |
| Caption text (`textFaint`) | `#5F5F5F` | `#8A8A8A` |
| Dim chrome (`dimChrome`) | `#2E2E2E` | `#2E2E2E` |
| Accent (`focus`, pack accent) | `#FFD34D` | `#8A6D1B` |
| Fault (`coral`) | `#F87171` | `#B3261E` |

Rules:

- Gold bright marks one thing per screen: the primary action, the current selection, or the focused
  surface. Nothing else is coloured.
- Dark grey `#2E2E2E` is chrome only — dividers, inactive glyphs, disabled states. On a black
  surface it is about 1.5:1, so it never carries text. Body copy uses the grey ramp above.
- Healthy state uses the accent. Red is reserved for faults, so red and green never appear in the
  same view (that pairing is also a colourblind trap).
- Store identities are a neutral grey ramp; the store mark glyph, not a brand colour, distinguishes
  them. Brand colours stay in artwork, not in the chrome.
- Game artwork and screenshots keep their own colours. Only the interface is monochrome.

## Typography

| Role | Family | Notes |
| --- | --- | --- |
| Display (`Theme.displayFont`) | Outfit | Headings, game titles, numerals that need presence |
| Body (`Theme.bodyFont`) | Inter | All reading text |
| Technical (`Theme.monoFont`) | Inter | Statistics; use tabular figures rather than a third family |

Both faces ship in `opennow-qt/res/fonts/` as variable fonts and are registered in
`src/app/ApplicationStartup.cpp`.

## Where the tokens live

| File | Owns |
| --- | --- |
| `qml/theme/Theme.qml` | Palette, theme packs, accent resolution, fonts, motion durations |
| `qml/desktop/components/DesktopTokens.qml` | Desktop type ramp, geometry ramp, status colours, formatting helpers |
| `qml/components/GlassPanel.qml` | The base panel: hairline seam, lit top edge, `accented` gold border |
| `qml/components/FocusFrame.qml` | Controller/D-pad focus ring: gold ring plus gold glow |
| `qml/desktop/components/DesktopButton.qml` | Desktop actions; `primary` wears the gold fill |
| `qml/desktop/settings/controls/` | Settings rows, sections, text actions, selectors, toggles, and steppers |
| `qml/desktop/shell/DesktopShell.qml` | Top bar, drawer hosting, page host |

Component files should ask the tokens for colour and size rather than hard-coding values, so a
palette change stays a one-file change.

## Desktop chrome

The desktop layout keeps the palette and copies the shape of the cloud-gaming client this fork
follows:

- One full-width top bar (`DesktopTokens.bar`) carries the menu button, the page name, a centred
  search field, the help button, and the account chip. Content is never inset by navigation.
- Navigation is a drawer (`DesktopTokens.drawer`) that opens below the bar over its own scrim. The
  saved `desktopRailCollapsed` flag still means "closed", and Ctrl B toggles it.
- Settings use a plain topic list with one accent bar on the selected topic, next to a reading-width
  column (`DesktopTokens.readingWidth`) of flat rows. A row is a label, an optional description, and
  a right-aligned control; hairlines (`edgeInk`) separate it from the next row.
- Settings actions are uppercase text, not filled buttons. `primary` keeps one gold fill for the
  single loud action a page may have.
- Home is shelves of 16:9 artwork (`DesktopTokens.shelfAspect`) with a title and a See all action;
  the first shelf opens with the connected-store summary built from live account data.

## Theme packs

The theme store keeps its eight pack ids (`nocturne`, `aurora`, `kraft`, `phosphor`, `bone`,
`cobalt`, `hibiscus`, `chapel`) because saved settings reference them. The ids now map to tonal
variants of the same black/white/gold family — Obsidian, Graphite, Carbon, Pure contrast, Bone,
Pearl, Basalt, Gilt — so switching packs changes surface tone and contrast, not hue.
