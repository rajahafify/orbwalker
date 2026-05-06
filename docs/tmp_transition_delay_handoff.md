# Temporary Transition Delay Handoff

Date: 2026-05-03

## Current Diagnosis

Temporary FlowTrace instrumentation originally showed the visible `Start Run -> Combat` stall was dominated by `PackedScene.instantiate()` for `res://scenes/combat.tscn`.

Original user runtime capture before the fix:

- `ResourceLoader.load(res://scenes/combat.tscn)`: about `213ms`
- `PackedScene.instantiate()`: about `2471ms`
- Scene attach/root swap: about `81ms`
- Combat `_ready()` and first usable frame after attach: about `90ms`
- Music startup happens after scene entry and costs about `23ms`

Follow-up Godot MCP editor probes isolated the instantiate cost to script member construction:

- `res://scenes/ui/board.tscn` instantiate: about `0.1ms`
- `res://resources/visual/first_pass_theme.tres` duplicate: about `0.1ms`
- `res://scripts/ui/visual_registry.gd.new()`: about `847ms`
- `res://scripts/ui/player_loadout_hud.gd.new()`: about `833ms`, because it also constructed a `VisualRegistry`
- `res://scripts/scenes/combat.gd.new()`: about `1687ms`

The expensive work was `VisualRegistry._init()` eagerly processing the large orb sheet into cleaned runtime orb textures. That happened twice during combat controller construction: once directly in `CombatPlayerController` and once inside `PlayerLoadoutHud`.

Current fix status:

- `VisualRegistry._init()` is now cheap; texture groups are built lazily by accessor.
- `PlayerLoadoutHud` can receive the combat controller's `VisualRegistry`, avoiding a duplicate registry.
- `CombatPlayerController` now constructs the registry/HUD in `_ready()` instead of as member initializers.
- Combat orb texture-map construction is deferred until after `combat_first_usable_frame`, so the expensive one-time orb cleanup no longer blocks the first usable frame.

Latest Godot MCP validation after the fix:

- `VisualRegistry.new()`: about `0.013ms`
- `PlayerLoadoutHud.new()`: about `0.008ms`
- `res://scenes/combat.tscn` instantiate: about `67ms`
- Direct `res://scenes/combat.tscn` runtime trace: first usable frame around `149ms`; deferred orb texture map finishes around `1355ms`

Latest user route-level capture from the real `Start Run` button after the fix:

- `ResourceLoader.load(res://scenes/combat.tscn)`: about `206ms`
- `PackedScene.instantiate()`: about `1ms`
- Scene attach/root swap, including combat `_ready()`: about `83ms`
- `combat_first_usable_frame`: about `300ms` after route start
- Deferred `combat_after_texture_map`: about `1438ms` after route start, about `1137ms` after first usable frame

Latest user route-level capture for `Combat -> Shop` after the fix:

- `ResourceLoader.load(res://scenes/shop.tscn)`: about `52ms`
- `PackedScene.instantiate()`: about `0ms`
- Scene attach/root swap, including shop `_ready()`: about `140ms`
- `shop_first_usable_frame`: about `245ms` after route start

These captures confirm the original `2s+` instantiate-time blocker is resolved for `Start Run -> Combat`, and the sampled `Combat -> Shop` route is not showing the earlier multi-second stall.

## Instrumentation Added

Temporary FlowTrace markers are currently wired through:

- `scripts/core/run_state.gd`
- `scripts/scenes/main_menu.gd`
- `scripts/scenes/combat.gd`
- `scripts/scenes/shop.gd`

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

Use Godot MCP/editor-side probes, not headless Godot, to decide whether the remaining deferred orb cleanup should be converted into generated/imported orb assets.

Suggested focused probes:

- If the deferred texture-map hitch is still visible, replace runtime orb-sheet cleanup with preprocessed derived orb textures instead of doing per-pixel cleanup in gameplay
- If the deferred texture-map hitch is not visible, keep the current lazy/deferred runtime path until broader asset-pipeline cleanup

Interpretation:

- If combat appears quickly but briefly uses fallback/color orb rendering before art appears, the remaining issue is the deferred orb asset preprocessing.
- If a later shop route still stalls, split `combat_to_shop` / `shop_to_combat` with the same constructor probes before applying combat-specific fixes there.

## Reproduction

1. Run `res://scenes/main_menu.tscn` in the Godot editor.
2. Click Start Run.
3. Inspect Godot output for `[FlowTrace]` lines on route `start_run_to_combat`.
4. For shop routing, win a combat, press Continue, and inspect route `combat_to_shop`.
5. For shop back to combat, press Continue in shop and inspect route `shop_to_combat`.

The acceptance target for the original temporary diagnostic step was a trace that made the missing `2s+` route time attributable to resource load, packed-scene instantiate, scene attach/swap, or later scene startup. That target has been met and fixed for the sampled `Start Run -> Combat` route.

## Caveats

- Manual scene swapping queues the old current scene for free after attaching the new scene, so the old and new scenes can briefly coexist during the transition frame.
- Some non-target redirects still use Godot's standard `change_scene_to_file(...)`.
- Existing integer-division warnings in Godot output predate this diagnostic work and are not currently tied to the transition stall.
- Do not optimize audio for this issue unless new traces contradict the current evidence.
- The deferred orb texture-map pass is still expensive because it keeps the runtime per-pixel cleanup path; a durable polish fix should move that cleanup into the asset pipeline.
