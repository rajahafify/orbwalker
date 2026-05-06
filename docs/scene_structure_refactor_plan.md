# Scene Structure Refactor Plan

Date: 2026-05-06  
Status: Proposed documentation-only plan  
Scope: `res://scenes/` folder structure, screen ownership, and shared UI scene composition.

## Context

The first playable game flow is now established: main menu, combat, shop, collection, and final run summary are the player-facing screens. The current `scenes/` folder layout still reflects earlier prototype growth rather than a finalized scene architecture.

Current scene layout:

```text
scenes/
  main.tscn
  board/
    board_surface.tscn
  combat/
    combat_player.tscn
  flow/
    collection.tscn
    final_run_summary.tscn
    shop_player.tscn
  run/
  shop/
  ui/
    elemental_mastery_hud_variants.tscn
```

Observed mismatch:

- `scenes/flow/` currently contains multiple full player-facing screens, not just transitional flow glue.
- `scenes/shop/` exists but does not contain the player-facing shop scene.
- `scenes/run/` exists but does not contain run summary or run-flow scene assets.
- Shared UI surfaces such as the player HUD are still mostly code-built through `PlayerLoadoutHud`, not represented as a reusable scene/partial asset.

## Regression To Record

The shop readability pass introduced a shop-specific `PlayerLoadoutHud` layout override in `scripts/flow/shop_player.gd`. That preserved the same HUD renderer but broke the intended "Rails partial" style contract where combat and shop should mount the same Player HUD section with identical structure and geometry.

The regression was architectural, not a gameplay logic bug:

- Combat uses `CombatLayoutManager` to apply a combat-owned HUD layout override.
- Shop now applies independent `SHOP_PLAYER_HUD_*` geometry constants.
- Both still call `PlayerLoadoutHud`, but the mounted HUD section is no longer identical across combat and shop.
- This creates visual drift and makes future polish fragile because each screen can reshape the shared HUD independently.

Target principle:

- A shared HUD should be a single reusable scene/component boundary.
- Combat and shop may choose where to mount the shared HUD on the screen.
- Combat and shop should not independently redefine the internal Player HUD section layout unless a new shared variant is explicitly added.

## Target Scene Folder Structure

Use scene folders to express product surfaces and reusable composition units, not implementation history.

Recommended structure:

```text
scenes/
  app/
    main_menu.tscn
  screens/
    combat/
      combat_player.tscn
    shop/
      shop_player.tscn
    collection/
      collection.tscn
    run_summary/
      final_run_summary.tscn
  components/
    board/
      board_surface.tscn
    hud/
      player_hud_section.tscn
      elemental_mastery_panel.tscn
    overlays/
      combat_outcome_overlay.tscn
      booster_choice_overlay.tscn
  dev/
    elemental_mastery_hud_variants.tscn
```

Alternative if the team wants fewer folders:

```text
scenes/
  main/
    main_menu.tscn
  combat/
    combat_player.tscn
  shop/
    shop_player.tscn
  collection/
    collection.tscn
  summary/
    final_run_summary.tscn
  shared/
    board_surface.tscn
    player_hud_section.tscn
    elemental_mastery_panel.tscn
  dev/
    elemental_mastery_hud_variants.tscn
```

The first structure is preferred because it separates full screens from reusable components.

## SOLID Ownership Rules

Single Responsibility:

- Full screen scenes own screen composition and screen-specific input flow.
- Component scenes own reusable UI layout and visual structure.
- Runtime services own game rules and state transitions.
- Layout managers may position components, but should not redefine another component's internals.

Open/Closed:

- Adding a new screen should not require changing shared component internals.
- Adding a new HUD variant should be explicit and reusable, not hardcoded inside one screen controller.

Liskov Substitution:

- If combat and shop both consume `player_hud_section`, either surface should be able to mount the component without changing its contract.
- Any variant must preserve the same public signals and data binding contract.

Interface Segregation:

- Screen controllers should receive small component APIs such as `bind_player_hud(...)`, `update_player_data(...)`, and `handle_global_click(...)`.
- Screens should not depend on incidental child-node geometry inside shared components.

Dependency Inversion:

- Screens depend on shared component interfaces and RunState/service APIs.
- Shared components depend on data payloads and signals, not on combat/shop controllers.

## Proposed Refactor Tasks

### SS-01: Freeze Current Scene Inventory

Document every current `.tscn`, whether it is a player-facing screen, reusable component, development preview, or legacy/empty folder placeholder.

Acceptance:

- `wiki/file-map.md` and this plan agree on the current scene inventory.
- Empty folders are explicitly marked as pending migration targets or removal candidates.

### SS-02: Create Shared HUD Scene Boundary

Move the code-built Player HUD section structure into a reusable scene such as `res://scenes/components/hud/player_hud_section.tscn`, while keeping `PlayerLoadoutHud` as the data-binding/controller helper if that remains the best boundary.

Acceptance:

- Combat and shop both instance the same HUD scene/component.
- Internal HUD geometry lives in one shared place.
- Screen controllers pass data and listen to signals, but do not define HUD internals.

### SS-03: Restore Combat/Shop HUD Identity

Remove scene-local Player HUD geometry overrides from combat and shop unless they are replaced by explicit shared variants.

Acceptance:

- Combat and shop Player HUD sections render identically for the same state payload at the same design size.
- Any allowed difference is documented as a named shared variant.
- A focused probe compares key child rects for combat and shop HUD instances.

### SS-04: Move Full Screens Into Final Folders

Move finalized full screens into the target folder taxonomy.

Proposed moves:

- `scenes/main.tscn` -> `scenes/app/main_menu.tscn`
- `scenes/combat/combat_player.tscn` -> `scenes/screens/combat/combat_player.tscn`
- `scenes/flow/shop_player.tscn` -> `scenes/screens/shop/shop_player.tscn`
- `scenes/flow/collection.tscn` -> `scenes/screens/collection/collection.tscn`
- `scenes/flow/final_run_summary.tscn` -> `scenes/screens/run_summary/final_run_summary.tscn`
- `scenes/board/board_surface.tscn` -> `scenes/components/board/board_surface.tscn`
- `scenes/ui/elemental_mastery_hud_variants.tscn` -> `scenes/dev/elemental_mastery_hud_variants.tscn`

Acceptance:

- `project.godot` main scene is updated.
- `RunState` route constants are updated.
- Source references to old scene paths are removed or converted through constants.
- Godot MCP scene instantiate probes pass for all player-facing screens.

### SS-05: Remove Or Repurpose Empty Scene Folders

After moves are complete, remove empty `scenes/run/`, `scenes/shop/`, and any other empty folders unless they become real homes in the final taxonomy.

Acceptance:

- `scenes/` contains no misleading empty domain folders.
- `wiki/file-map.md` and `docs/system_architecture.md` match the live layout.

### SS-06: Add Scene Contract Validation

Add a focused validation probe that checks screen/component contracts rather than only loading scenes.

Minimum checks:

- Main menu scene path configured in `project.godot`.
- RunState route constants point to existing scenes.
- Combat, shop, collection, and final summary instantiate.
- Shared `player_hud_section` component instantiates.
- Combat and shop mount the shared HUD component.
- Combat/shop shared HUD child rects match for the same design size, unless using an explicit shared variant.

Acceptance:

- Godot MCP validation covers scene load, route constants, and shared HUD geometry contracts.
- Manual screenshot QA remains separate from structural validation.

## Non-Goals

- Do not change combat math, shop economy, RunState sequencing, content pools, or meta progression.
- Do not redesign the entire UI in the same task as moving scenes.
- Do not move files before all scene path references and route constants are inventoried.
- Do not treat a screen-specific hotfix as a replacement for shared component architecture.

## Open Questions

- Should `player_hud_section.tscn` contain only layout nodes, with `PlayerLoadoutHud` continuing as the controller/helper, or should the script move onto the scene root?
- Should Elemental Mastery remain part of the Player HUD component, or become a separate shared component mounted adjacent to the Player HUD by combat and shop?
- Should overlays such as booster choice and combat outcome become `.tscn` component scenes now, or remain code-built until the screen folder migration is complete?
- Should the final folder use `screens/` and `components/`, or shorter domain folders such as `combat/`, `shop/`, `shared/`, and `dev/`?
