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

- Status: `done`
- Owner/scope: Add reusable combat floating result text/bubble presentation for enemy damage, healing, armor gain, gold gain, blocked damage, and player HP damage.
- Progress: Completed on `codex/cfr-02-result-numbers`: `CombatVfxManager.spawn_result_label(...)` creates transient outlined result labels on `VfxLayer`, and combat turn replay now reads existing `turn_log` values for elemental damage, blocked enemy damage, healing, armor gain, gold gain, blocked enemy attacks, and player HP damage. HUD refresh timing remains unchanged for CFR-03.
- Blockers: None for CFR-02 closure. The last `get_godot_errors` call still retained two enum reload diagnostics from the earlier failed helper version after the enum casts were applied and the script was reloaded; focused probes and user visual QA passed, so treat this as stale session state unless it reappears after an editor restart.
- Next action: Start CFR-03 from the existing result-label system and focus on source-to-target timing / HUD update ordering.
- Acceptance:
  - Fire/Ice/Earth/Earth-style elemental damage can show numeric damage near the enemy impact.
  - Heart match results can show `+N HP` near the player/HUD.
  - Armor match results can show `+N Armor` or equivalent near the player/HUD.
  - Gold match results can show `+N Gold` near the gold counter or top HUD.
  - Enemy attacks can show `Blocked`, `0`, or HP damage near the player depending on outcome.
  - Text remains readable on portrait mobile and does not overlap permanently with the board, enemy HP, mastery cards, or player HUD.
- Validation: `git diff --check` passed. Godot MCP rerun on 2026-05-04 reached Godot 4.6.2, opened `combat_player_controller.gd` and `combat_vfx_manager.gd`, instantiated `res://scenes/combat/combat_player.tscn` with `VfxLayer`, spawned all eight result-label kinds through `CombatVfxManager.spawn_result_label(...)`, and launched `play_scene current`. The first runtime smoke found enum reload diagnostics in the new label helper; enum casts were added for label/sprite/beam assignments and the focused spawn probe passed afterward. The user manually validated the full CFR-02 visual QA matrix on 2026-05-04: elemental damage, Heart healing, Armor gain, Gold gain, player damage blocked by enemy, enemy attack blocked by armor, enemy HP damage, label cleanup/no permanent overlap, and `combat_speed` normal/instant behavior all passed. The final `get_godot_errors` read still retained the earlier enum diagnostics, so rerun after editor restart if they reappear.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/features.md`, and `wiki/log.md` were updated with CFR-02 implementation state, Godot MCP evidence, user visual QA acceptance, and the stale final-error-note caveat.

## CFR-03: Source-To-Target Timing Order

- Status: `done`
- Owner/scope: Ensure combat result feedback appears in a readable order after match clear and before/with the corresponding HUD value change.
- Progress: Implemented on `codex/cfr-03-feedback-timing`: combat turn replay now captures pre-turn visible HUD values before combat resolution, keeps those staged values visible while VFX/result labels play, and advances enemy HP/block, player HP/armor, and gold after their matching result label timing point. Enemy HP/block now steps after each elemental damage label instead of waiting for all damage labels to finish, and blocked damage labels use `-N Damage Blocked` for both enemy block and player armor block. The actual combat state still resolves once through `CombatStateMachine`; staged values are presentation-only and cleared before the final HUD refresh.
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
- Validation: `git diff --check` passed. Godot MCP on 2026-05-04 reached Godot 4.6.2, loaded `combat_player_controller.gd`, `player_loadout_hud.gd`, and `combat_vfx_manager.gd`, instantiated `res://scenes/combat/combat_player.tscn` with `VfxLayer`, and launched `play_scene current` successfully. A focused async staged-HUD probe was attempted but rejected by the MCP wrapper because tool-script `run()` cannot be a coroutine; the non-async script-load/scene probe passed. `get_godot_errors` still reports the two known enum reload diagnostics from the earlier CFR-02 helper version, but the new `_staged_hud_values` warning disappeared after replaying the scene. User manual QA passed on 2026-05-04 after the follow-up change: enemy HP/block steps after each Fire/Ice/Earth result label, and both enemy block and player armor block labels read as `-N Damage Blocked`.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/features.md`, and `wiki/log.md` were updated with CFR-03 behavior, validation, and user QA acceptance.

## CFR-04: Mastery Activation And Character Improvement Readability

- Status: `done`
- Owner/scope: Make Elemental Mastery cards visibly act as the source of character improvement and per-turn contribution.
- Progress: Completed on `codex/cfr-04-mastery-effect-readability`: combat mastery cards now add fixed-size activation glow/frame layers behind the existing card text, scale activation intensity from the pooled contribution value, and pulse briefly when `set_combat_mastery_feedback(...)` raises a card's visible contribution. Mastery beams still originate from the active card/icon, and `CombatVfxManager` now adds a stronger source pulse when the beam fires so the player can read the card as the source. A follow-up after screenshot QA carries active pooled feedback totals through HUD rebuilds, so card lights do not clear as a group during staged HUD updates and still release through the per-card replay timing. Mastery Effect SFX now plays at each replay impact/result moment for damage, heal, armor, and gold, reusing existing placeholder `hit`, `heal`, `armor`, and `gold` sounds without adding source-launch audio. This is presentation-only; combat math, match resolver behavior, RunState routing, turn-log payloads, result label text, enemy HP/block stepping, board resolve order, and `combat_speed` modes were not changed.
- Blockers: CFR-01 source inventory; coordinate with existing pooled mastery feedback and release behavior.
- Next action: Start CFR-05 or run CFR-07 readability QA after CFR-05/CFR-06 are implemented.
- Acceptance:
  - Matching an element clearly activates that element's mastery card.
  - Higher-value contributions have stronger but non-obstructive glow/pulse intensity.
  - Pooled mastery feedback does not disappear and reappear mid-replay.
  - The player can tell which element or stat improved during the turn.
- Validation: `git diff --check` passed. Godot MCP reached Godot 4.6.2, opened `player_loadout_hud.gd`, `combat_vfx_manager.gd`, `combat_player_controller.gd`, and `audio_manager.gd`, reloaded edited/related scripts with `reload=0`, instantiated `res://scenes/combat/combat_player.tscn` and confirmed `ElementalMasteryCards`, `VfxLayer`, enemy portrait, player portrait, and board surface exist, probed Fire/Heart/Armor/Gold low/high/reset feedback states, confirmed mastery source pulse and beam spawning through `CombatVfxManager`, and launched `play_scene current`. Follow-up probes confirmed active Fire/Ice/Gold cards survive a mastery panel rebuild and clearing Fire leaves Ice/Gold active, source pulse and beam nodes still spawn together, existing placeholder SFX streams resolve for `hit`, `heal`, `armor`, and `gold`, and Mastery Effect SFX calls live in replay timing rather than the end-of-turn result batch. User visual/listening QA passed on 2026-05-04. The final `get_godot_errors` read still reports the two known enum reload diagnostics from the earlier CFR-02 helper version; the new ternary warning from the first CFR-04 smoke cleared after the helper fix and reload.
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
