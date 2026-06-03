# Combat Feedback Regression Fixes

Date: 2026-06-03

## Scope

This pass addressed review findings in combat feedback and export packaging after the game juice work.

## Changes

- Impact audio fallback now routes through the same result-aware path as elemental impact audio. This keeps player hit and block sounds distinct while respecting the master Game Juice toggle and the `element_impact_audio` child flag.
- Combat turn resolution no longer plays enemy-attack impact audio a second time after the visual replay. The replay labels already trigger the player hit/block cue at the moment of impact.
- Combat Help/back header presses now share the header-action debounce behavior used by Settings. This prevents duplicate dispatch when both scene-level and `TopHeader` signals fire from a single tap.
- Android and Web export presets now include raw music bins but exclude imported `resources/audio/music/*.wav` duplicates, reducing release payload bloat while preserving runtime music routing.

## Validation

- `git diff --check`
- Godot headless suite via `res://scripts/tests/run_all_tests.gd`: 75 suites, 318 cases, 0 failures.

