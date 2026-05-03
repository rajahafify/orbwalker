# Temporary Transition Delay Handoff

Date: 2026-05-03

## Current Diagnosis

Temporary FlowTrace instrumentation shows the visible `Start Run -> Combat` stall is dominated by `PackedScene.instantiate()` for `res://scenes/combat/combat_player.tscn`.

Latest user runtime capture:

- `ResourceLoader.load(res://scenes/combat/combat_player.tscn)`: about `213ms`
- `PackedScene.instantiate()`: about `2471ms`
- Scene attach/root swap: about `81ms`
- Combat `_ready()` and first usable frame after attach: about `90ms`
- Music startup happens after scene entry and costs about `23ms`

Earlier traces showed both `Start Run -> Combat` and `Combat -> Shop` spent roughly `2.3s-2.7s` before the destination root entered the tree. The manual instantiate/attach split has only been captured for `Start Run -> Combat` so far, so do not assume the shop route has the same internal cause until it is split and captured too.

## Instrumentation Added

Temporary FlowTrace markers are currently wired through:

- `scripts/core/run_state.gd`
- `scripts/core/main_boot.gd`
- `scripts/combat/combat_player_controller.gd`
- `scripts/flow/shop_player.gd`

The traced transition helper splits route time into:

- `transition_manual_start`
- `before_resource_load`
- `after_resource_load`
- `before_scene_instantiate`
- `after_scene_instantiate`
- `before_scene_attach`
- destination `_enter_tree()` / `_ready_start`
- `after_scene_attach`
- first usable frame markers

This is diagnostic instrumentation, not the intended final transition architecture.

## Next Diagnostic Step

Use Godot MCP/editor-side probes, not headless Godot, to isolate which part of `combat_player.tscn` makes instantiation slow.

Suggested focused probes:

- Instantiate `res://scenes/combat/combat_player.tscn`
- Instantiate `res://scenes/board/board_surface.tscn`
- Load or duplicate `res://resources/visual/first_pass_theme.tres`
- Construct `res://scripts/combat/combat_player_controller.gd` with `.new()`
- Construct board/presentation helper scripts used by combat startup, especially board view/surface paths

Interpretation:

- If `combat_player.tscn` is slow but child scenes and scripts are fast, inspect the scene file for heavy node/resource/subresource construction.
- If `board_surface.tscn` is slow, focus the next fix on board scene construction and board rendering resources.
- If `combat_player_controller.gd.new()` or helper script construction is slow, inspect script member initializers, preloads, and large default object graphs.
- If isolated instantiation is fast in probes but slow during route changes, capture a route-level probe around old-scene teardown and editor/runtime scheduling.

## Reproduction

1. Run `res://scenes/main.tscn` in the Godot editor.
2. Click Start Run.
3. Inspect Godot output for `[FlowTrace]` lines on route `start_run_to_combat`.
4. For shop routing, win a combat, press Continue, and inspect route `combat_to_shop`.
5. For shop back to combat, press Continue in shop and inspect route `shop_to_combat`.

The acceptance target for this temporary diagnostic step is a trace that makes the missing `2s+` route time attributable to resource load, packed-scene instantiate, scene attach/swap, or later scene startup.

## Caveats

- Manual scene swapping queues the old current scene for free after attaching the new scene, so the old and new scenes can briefly coexist during the transition frame.
- Some non-target redirects still use Godot's standard `change_scene_to_file(...)`.
- Existing integer-division warnings in Godot output predate this diagnostic work and are not currently tied to the transition stall.
- Do not optimize audio for this issue unless new traces contradict the current evidence.
