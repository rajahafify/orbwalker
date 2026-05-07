# Itch.io Readiness Task Tracker

Purpose: track the remaining work needed to move the current `itch.io demo / alpha page` readiness rating from `7/10` to `10/10`. When every readiness task in this tracker is `done`, the project is considered ready to publish an honest alpha/demo build on itch.io.

Source launch snapshot: `launch-milestone.md`

Status values: `not started`, `in progress`, `blocked`, `done`, `deferred`.

Branch naming rule: each readiness task should be worked on a focused branch named `codex/itch-number-name`, for example `codex/itch-01-combat-readability`.

Completion rule: do not mark a task `done` unless its validation evidence is recorded in `docs/test_plan.md` or explicitly accepted by the human after manual QA. Use Godot MCP for Godot runtime validation and do not use headless Godot.

## Overall Publish Gate

The itch.io alpha/demo is publish-ready when:

- A first-time player can download or install the build, start a run, understand the main actions without external help, complete or die in a run, and want to retry.
- The full loop works: Main Menu -> Combat -> Victory -> Shop -> Boss/Reward -> Death or Victory -> Run Summary -> Main Menu.
- Combat is readable on mobile and PC for board state, enemy HP/intent, timer, player HP, action feedback, and current phase.
- Shop decisions are understandable without explanation: buy, afford, sold out, sell, reroll, and continue.
- Defeat/victory/result screens feel intentional and consistent with the rest of the game.
- The build launches cleanly with correct title/icon/version and no accidental debug-only player path.
- The itch.io page presents the game honestly as an alpha/demo with curated screenshots, controls, and known scope.

## ITCH-01: Combat Readability Pass

- Branch: `codex/itch-01-combat-readability`
- Status: `not started`
- Owner/scope: Combat screen readability for the player-facing `res://scenes/combat.tscn` flow.
- Goal: Make combat readable at a glance on mobile and PC without changing combat math, resolver outcomes, or accepted resolve timing.
- Current rationale: `todo.md` identifies mobile-first combat UI readability as the active Milestone 12 blocker. The launch snapshot identifies combat hierarchy as the highest-leverage improvement for itch readiness.
- Acceptance:
  - Board cells and orb identities are immediately readable.
  - Enemy HP, enemy name, enemy block/intent, timer/phase state, player HP, and gold are readable without zooming.
  - Current phase/action state is obvious during ready, dragging, resolve, victory, and defeat.
  - Combat board remains visually central during active play.
  - No incoherent overlap in portrait mobile layout or desktop window layout.
  - Touch/mouse drag behavior remains unchanged, including board-local touch coordinate behavior.
- Validation:
  - Godot MCP: `get_project_info`, `play_scene` for combat/main flow, `get_scene_tree` or focused probes for key nodes, and `get_godot_errors`.
  - Manual screenshot review on mobile portrait and desktop-sized viewport.
  - Manual drag/resolve smoke: one normal attack turn, one victory, one defeat or forced defeat.
- Docs/wiki impact:
  - Update `docs/test_plan.md`.
  - Update `wiki/features.md` or `wiki/known-issues.md` only if durable behavior, layout responsibility, or known risk changes.

## ITCH-02: First-Run Clarity And Onboarding

- Branch: `codex/itch-02-first-run-clarity`
- Status: `not started`
- Owner/scope: First-time player guidance across main menu, first combat, first shop, and run summary.
- Goal: A new player should understand the basic loop without reading an external explanation.
- Acceptance:
  - The first run teaches or clearly signals drag-to-match.
  - The player can infer that Fire/Ice/Earth damage enemies, Heart heals, Armor blocks, and Gold buys.
  - Enemy intent and player HP danger are explained or visually obvious before the first serious mistake.
  - First shop explains buy/sell/reroll/continue at the point of use.
  - Guidance is concise and does not bury the screen in tutorial text.
- Validation:
  - Godot MCP scene smoke for main, combat, shop, and run summary.
  - Fresh first-run manual QA from new-run state.
  - Optional external-player observation: player reaches the first shop without verbal instruction.
- Docs/wiki impact:
  - Update `docs/test_plan.md`.
  - Update `wiki/features.md` if new onboarding/tutorial behavior is added.

## ITCH-03: Full Run Loop Stability

- Branch: `codex/itch-03-run-loop-stability`
- Status: `not started`
- Owner/scope: End-to-end first playable loop stability and route confidence.
- Goal: The public alpha/demo should not break during normal play from launch through death/victory and return to menu.
- Acceptance:
  - Start Run enters combat reliably.
  - Normal victory routes to shop correctly.
  - Shop Continue routes to the next fight correctly.
  - Boss reward or boss completion routes correctly.
  - Defeat routes to run summary or the intended defeat surface.
  - Final victory routes to run summary.
  - Main Menu return and Start New Run work from summary.
  - No blocker crash, lock, stuck overlay, or missing route on the tested loop.
- Validation:
  - Godot MCP smoke for `res://scenes/main_menu.tscn`, `res://scenes/combat.tscn`, `res://scenes/shop.tscn`, and `res://scenes/run_summary.tscn`.
  - Focused RunState route probe or equivalent debug `/skip` validation.
  - Manual end-to-end run using real inputs, with at least one death path and one victory/summary path if practical.
  - `get_godot_errors` after the loop.
- Docs/wiki impact:
  - Update `docs/test_plan.md`.
  - Update `wiki/known-issues.md` for any remaining non-blocking route risks.

## ITCH-04: Shop Decision Clarity

- Branch: `codex/itch-04-shop-clarity`
- Status: `not started`
- Owner/scope: Player-facing shop readability and decision flow in `res://scenes/shop.tscn`.
- Goal: The shop should be understandable without external explanation.
- Acceptance:
  - It is obvious what can be bought, what is unaffordable, what is sold out, and what Continue does.
  - Buy, sell, reroll, booster, relic, and continue actions have clear visual feedback.
  - Player loadout sell flow is discoverable and does not leave stale selection/popover state.
  - Disabled and sold-out states are readable but not visually dominant.
  - The shared bottom HUD does not overlap shop actions or obscure important info.
- Validation:
  - Godot MCP shop scene smoke and focused layout probe.
  - Manual shop transaction click-through: buy equipment, attempt unaffordable buy, sell equipment, reroll, continue.
  - Manual screenshot review after purchase/sold-out state.
- Docs/wiki impact:
  - Update `docs/test_plan.md`.
  - Update `wiki/features.md` if shop behavior or layout responsibility changes.

## ITCH-05: Result Screen Polish

- Branch: `codex/itch-05-result-screen-polish`
- Status: `not started`
- Owner/scope: Victory, defeat, and final run summary presentation.
- Goal: Result screens should feel intentional and close enough to the main menu quality that they do not break confidence.
- Acceptance:
  - Combat victory overlay clearly shows reward, gold gained, and next action.
  - Defeat communicates why the player died and what happened in the run.
  - Final run summary is readable and visually consistent with the current fantasy presentation.
  - Primary actions are obvious: Continue, Start New Run, Main Menu.
  - Result screens do not feel like debug placeholders.
- Validation:
  - Godot MCP smoke for combat victory/defeat surfaces and run summary scene.
  - Manual screenshot review for victory, defeat, and final summary.
  - Manual route check from each result action.
- Docs/wiki impact:
  - Update `docs/test_plan.md`.
  - Update `wiki/features.md` if result behavior changes.

## ITCH-06: Public Build Packaging

- Branch: `codex/itch-06-public-build-packaging`
- Status: `not started`
- Owner/scope: Export configuration, build output, title/icon/version, and accidental debug exposure.
- Goal: Produce a clean itch.io alpha/demo build that a player can run without developer setup.
- Acceptance:
  - Exported build launches directly into the intended main menu.
  - Project title, visible version, app icon, and package naming are intentional for the alpha/demo.
  - Debug-only controls or probes are either hidden, disabled, or intentionally documented.
  - Build artifacts are ignored or handled according to repo policy.
  - Install/run instructions are short and accurate.
- Validation:
  - Fresh export/build.
  - Install/run smoke on the target platform for the itch upload.
  - Verify no blocker errors after launch and Start Run.
  - Record build filename/version and platform in `docs/test_plan.md`.
- Docs/wiki impact:
  - Update `docs/test_plan.md`.
  - Update `wiki/setup.md` if export or install steps change.
  - Update `wiki/known-issues.md` for any public-build caveats.

## ITCH-07: Itch.io Page And Screenshot Pack

- Branch: `codex/itch-07-page-screenshot-pack`
- Status: `not started`
- Owner/scope: Store/page copy, screenshot curation, controls, scope wording, and public caveats.
- Goal: Publish with a page that is attractive, honest, and clear about alpha/demo status.
- Acceptance:
  - Page headline and short description explain the hook in one sentence.
  - Page clearly labels the build as alpha/demo.
  - Controls are listed.
  - 4-6 curated screenshots show main menu, combat, shop, victory/reward, and defeat/summary without unreadable clutter.
  - Known limitations are stated without undermining confidence.
  - Download/install instructions match the exported build.
- Validation:
  - Screenshot review at full size and thumbnail size.
  - Page copy review before publishing.
  - Final smoke test using the exact uploaded build.
- Docs/wiki impact:
  - Update `launch-milestone.md` if launch ratings change.
  - Update `docs/test_plan.md` with final release candidate evidence.
  - Append `wiki/log.md` if the wiki changes.

## ITCH-08: Final Release Candidate QA

- Branch: `codex/itch-08-final-rc-qa`
- Status: `not started`
- Owner/scope: Final pre-publish acceptance pass across the exact build and page materials.
- Goal: Confirm the public alpha/demo is ready to publish.
- Acceptance:
  - All previous ITCH tasks are `done` or explicitly deferred with human acceptance.
  - Exact release candidate build has passed launch, Start Run, first combat, shop, one route forward, death or victory summary, and return to main menu.
  - No known blocker crash or severe first-session confusion remains.
  - `launch-milestone.md` rates itch.io demo/alpha readiness at `10/10`.
  - Human gives explicit publish approval.
- Validation:
  - Godot MCP smoke on relevant scenes before export if source changed.
  - Exact exported build manual QA.
  - `get_godot_errors` or equivalent post-run error check where applicable.
  - Final checklist recorded in `docs/test_plan.md`.
- Docs/wiki impact:
  - Update `launch-milestone.md`.
  - Update `docs/test_plan.md`.
  - Update `wiki/log.md` if wiki pages changed.

