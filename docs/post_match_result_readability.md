# Post-match result readability

Documented May 23, 2026.

The standard post-match combat result overlay now uses a larger result card and bigger typography so victory and defeat states read clearly on mobile portrait screens. The standard card is wider and taller in design space, with expanded internal spacing, a larger result title, a larger summary body, and a wider/taller action button for `Continue` or `Run Summary`.

This pass intentionally affects only the standard victory/defeat result card. Boss relic reward selection keeps its separate modal layout and button sizing.

Validation: Godot MCP launched the main scene and stopped it cleanly after the layout change.
