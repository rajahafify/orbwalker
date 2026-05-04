# Combat Feedback Revamp Task Tracker

Purpose: track the combat-feedback readability revamp with explicit status, ownership, validation gates, and documentation impact. This is a player-facing Milestone 9 follow-up that should make combat explain what happened, why it happened, and how much it mattered before Milestone 10 balance work depends on playtest feedback.

Status values: `not started`, `in progress`, `blocked`, `done`, `deferred`.

## Design Target

Player feedback says combat feedback is currently weak outside the combo count. The player can see some effects such as beams, but cannot reliably read damage numbers, healing, armor gain, gold gain, enemy attack results, or how the character is improving.

Target visible sequence:

`match clears -> source/mastery activates -> effect travels -> target impact -> number/result appears -> HUD value changes`

For enemy turns:

`enemy intent -> enemy windup -> block or hit result -> number/result appears -> player HP/armor changes`

The first implementation should prioritize readable result numbers and timing over elaborate final art. Escalating VFX tiers are desirable, but temporary thresholds and simple generated/texture VFX are acceptable until the balance pass sets real ranges.

## CFR-01: Combat Feedback Baseline And Event Inventory

- Status: `done`
- Owner/scope: Read-only inventory of current combat presentation events, turn-log payloads, VFX calls, HUD update timing, mastery feedback timing, enemy attack replay, and available source values for damage/heal/armor/gold.
- Progress: Read-only inventory completed on `codex/cfr-01-inventory`; no combat math, resolver behavior, RunState routing, or runtime source files were changed.
- Blockers: None.
- Next action: Start CFR-02 from the existing `turn_log` payload and existing replay/VFX hooks; do not recompute combat values.
- Validation: No runtime validation required for this inventory pass. Evidence was gathered by inspecting `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_resolve_presenter.gd`, `scripts/combat/combat_vfx_manager.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/combat/combat_turn_logger.gd`, `scripts/combat/combat_hud_snapshot_builder.gd`, `scripts/ui/player_loadout_hud.gd`, and `scenes/combat/combat_player.tscn`.
- Docs/wiki impact: This tracker records the read-only baseline. No wiki update was made because CFR-01 only documents implementation evidence and does not change runtime behavior.

### CFR-01 Current Payload Sources

- Elemental damage by type is already in `turn_log`: `fire_damage`, `ice_damage`, `earth_damage`, plus `fire_base`, `ice_base`, `earth_base`, `total_elemental_damage_before_flat`, and `total_elemental_damage` from `scripts/combat/combat_state_machine.gd`.
- Healing, armor, and gold are already in `turn_log`: `healed`, `heart_base`, `armor_gained`, `armor_base`, `prep_armor_added`, `gold_gained`, and `gold_base`.
- Enemy block against player damage is already in `turn_log`: `enemy_blocked` and `enemy_damage_taken`.
- Enemy attack results are already in `turn_log.enemy_attack_resolution`: `incoming`, `blocked_by_armor`, `hp_damage`, `remaining_hp`, and `remaining_armor`.
- Mastery contribution values are presentation-side, not durable `turn_log` fields: `_show_match_mastery_feedback()` accumulates `_combat_mastery_preview_totals[orb_id]`, and `PlayerLoadoutHud.set_combat_mastery_feedback()` renders `+N DAMAGE/HEAL/ARMOR/GOLD`.

### CFR-01 Timing Findings

- Current board presentation preserves the accepted order through `CombatResolvePresenter`: match flash, clear animation, clear visual commit, combo/mastery preview, gravity, refill.
- Combat math runs after board resolve presentation in `_resolve_combat_turn_from_board()`.
- HUD currently updates too early for the revamp target: `_combat.resolve_player_turn(resolve_result)` is followed immediately by `_update_hud()`, before `_replay_turn_resolution_from_log(turn_log)`.
- VFX impact timing already exists in `_replay_turn_resolution_from_log()`: elemental impacts/beams, then heart, armor, and gold impacts/beams, each paced by `TURN_REPLAY_STEP_SECONDS` and `combat_speed`.
- There is no numeric result label system yet. `_replay_turn_resolution_from_log()` only uses values as gates for impact/beam playback.
- Enemy attack feedback is logged and used for SFX, but it has no replay VFX/result number path yet.
- `_emit_turn_feedback_vfx(_turn_log)` exists as a stub and can be considered a future presentation hook.

### CFR-01 Implementation Implications For CFR-02+

- Use `turn_log` as the source for floating result numbers; do not recompute combat values.
- Add result-number presentation near the existing replay impact path, likely around `_replay_turn_resolution_from_log()` and `CombatVfxManager`, rather than changing resolver math or match resolution.
- Defer HUD visual refresh until after the matching impact/result number for CFR-03, but preserve final state and `combat_speed` behavior.
- Keep mastery preview values as presentation preview totals unless a later task explicitly needs them serialized into the turn log.

## CFR-02: Floating Result Number System

- Status: `not started`
- Owner/scope: Add reusable combat floating result text/bubble presentation for enemy damage, healing, armor gain, gold gain, blocked damage, and player HP damage.
- Progress: Not started.
- Blockers: Depends on CFR-01 value/source inventory.
- Next action: Implement a small reusable presenter or VFX-manager method that can spawn readable result labels at board/enemy/player/HUD anchor positions without changing combat math.
- Acceptance:
  - Fire/Ice/Earth/Earth-style elemental damage can show numeric damage near the enemy impact.
  - Heart match results can show `+N HP` near the player/HUD.
  - Armor match results can show `+N Armor` or equivalent near the player/HUD.
  - Gold match results can show `+N Gold` near the gold counter or top HUD.
  - Enemy attacks can show `Blocked`, `0`, or HP damage near the player depending on outcome.
  - Text remains readable on portrait mobile and does not overlap permanently with the board, enemy HP, mastery cards, or player HUD.
- Validation: Godot MCP scene instantiate and focused script probes for result label spawn/cleanup. Manual visual QA is required for real combat readability.
- Docs/wiki impact: Update `docs/test_plan.md`, `wiki/features.md`, and `wiki/log.md` after implementation.

## CFR-03: Source-To-Target Timing Order

- Status: `not started`
- Owner/scope: Ensure combat result feedback appears in a readable order after match clear and before/with the corresponding HUD value change.
- Progress: Not started.
- Blockers: CFR-02 should exist first, or this task must include a minimal result-number implementation.
- Next action: Preserve the accepted resolve order while adding result-number timing:
  - match flash,
  - clear animation,
  - combo tick,
  - mastery/source activation,
  - travel/impact VFX,
  - number/result,
  - then visible HUD value change.
- Acceptance:
  - Result numbers do not appear before their cause is visible.
  - HUD HP/armor/gold/enemy HP changes do not visually jump before the related impact/result read.
  - Existing `combat_speed` modes still work; `instant` may compress or skip animation waits but must not break final state.
  - Existing top-to-bottom same-pass match ordering is preserved.
- Validation: Godot MCP parse/errors and a focused presentation-order probe if practical. Manual drag/cascade visual QA remains required.
- Docs/wiki impact: Update `docs/test_plan.md` with timing acceptance evidence.

## CFR-04: Mastery Activation And Character Improvement Readability

- Status: `not started`
- Owner/scope: Make Elemental Mastery cards visibly act as the source of character improvement and per-turn contribution.
- Progress: Not started.
- Blockers: CFR-01 source inventory; coordinate with existing pooled mastery feedback and release behavior.
- Next action: Improve mastery activation glow/pulse intensity by contribution value, keep pooled `+N DAMAGE`, `+N HEAL`, `+N ARMOR`, or `+N GOLD` text readable through the whole cascade, and connect mastery activation to travel VFX origins when possible.
- Acceptance:
  - Matching an element clearly activates that element's mastery card.
  - Higher-value contributions have stronger but non-obstructive glow/pulse intensity.
  - Pooled mastery feedback does not disappear and reappear mid-replay.
  - The player can tell which element or stat improved during the turn.
- Validation: Godot MCP script checks and manual visual QA on at least one elemental damage match and one Heart/Armor/Gold match.
- Docs/wiki impact: Update `wiki/features.md` and `docs/test_plan.md` if mastery feedback behavior changes.

## CFR-05: Elemental And Resource VFX Tier Hooks

- Status: `not started`
- Owner/scope: Add a data-driven or helper-driven tier selection layer for Fire, Ice, Earth, Heart, Armor, and Gold result VFX.
- Progress: Not started.
- Blockers: CFR-02 and CFR-03 should land first unless the worker implements this as a thin hook with placeholder visuals.
- Next action: Add temporary value thresholds for visual tiers, with thresholds isolated for later balance tuning.
- Initial tier concept:
  - Tier 1: low value, small projectile/pop.
  - Tier 2: medium value, larger projectile/impact.
  - Tier 3: high value, burst or stronger screen-local impact.
  - Tier 4: huge value, signature effect.
- Example Fire placeholder:
  - `1-2`: ember shot.
  - `3-5`: fireball.
  - `6-10`: flame burst.
  - `10+`: meteor-style hit.
- Acceptance:
  - Each orb type can choose a VFX family and tier without changing combat math.
  - Thresholds are easy to tune later.
  - Missing art falls back to readable generated or existing VFX instead of failing silently.
- Validation: Focused helper probe for tier selection and at least one manual visual combat check.
- Docs/wiki impact: Record threshold ownership and fallback behavior in `wiki/features.md` or `wiki/file-map.md` if new files are added.

## CFR-06: Enemy Attack Feedback

- Status: `not started`
- Owner/scope: Add readable enemy-turn feedback for fully blocked attacks, partially blocked attacks, and HP damage.
- Progress: Not started.
- Blockers: CFR-02 result labels should exist first.
- Next action: Inspect enemy intent replay and turn-log values, then add block/hit result presentation without changing enemy math.
- Acceptance:
  - Fully blocked attack shows shield/block feedback and no HP damage read.
  - Partially blocked attack shows armor impact plus remaining HP damage.
  - Unblocked HP damage shows player hit feedback and damage number.
  - Enemy-specific VFX hooks are possible, but generic enemy attack feedback is enough for first pass.
- Validation: Focused combat state probe for blocked/partial/unblocked outcomes plus manual visual QA.
- Docs/wiki impact: Update `docs/test_plan.md` for enemy attack visual acceptance.

## CFR-07: Feedback Readability QA Pass

- Status: `not started`
- Owner/scope: Validate combat feedback readability across common result types and viewport constraints.
- Progress: Not started.
- Blockers: CFR-02 through CFR-06 implementation state.
- Next action: Run Godot MCP checks and manual visual QA for a small matrix:
  - elemental damage,
  - Heart heal,
  - Armor gain,
  - Gold gain,
  - enemy fully blocked attack,
  - enemy HP damage,
  - cascade with multiple groups,
  - `combat_speed` normal and instant.
- Acceptance:
  - The player can identify the source and amount for each major combat result without reading the debug log.
  - Feedback does not permanently obscure board input, enemy HP, mastery cards, or player HUD.
  - No new Godot errors are reported after scene smokes.
- Validation: Godot MCP `get_project_info`, `get_godot_errors`, `play_scene`/scene instantiate for `res://scenes/combat/combat_player.tscn`, focused probes as needed, and manual visual QA notes.
- Docs/wiki impact: Update this tracker, `docs/test_plan.md`, `todo.md` if Milestone 9 task status changes, `wiki/features.md`, and `wiki/log.md`.

## Guardrails

- Do not change combat math, match resolver behavior, RunState routing, shop behavior, content balance, or enemy stats while implementing these tasks.
- Do not start a broad combat-controller refactor. Only extract helpers when they directly support feedback presentation and reduce risk.
- Preserve the accepted visible resolve order: drag finish, match flash, clear animation, combo/mastery preview, gravity, refill.
- Preserve `combat_speed` with `slow`, `normal`, `fast`, and `instant`.
- Use Godot MCP for validation. Do not use headless Godot.
- Keep implementation slices small enough that manual visual QA can isolate regressions.
