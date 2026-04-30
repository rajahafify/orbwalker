# Setup

**Summary**: Practical setup and validation notes for the current Godot checkout. This page records only the commands and surfaces that are actually present in the repository.

**Sources**: `project.godot`, `.codex/config.toml`, `.codex/agents/default.toml`, `.codex/agents/explorer.toml`, `.codex/agents/worker.toml`, `docs/system_architecture.md`, `docs/test_plan.md`, `scenes/main.tscn`, `scenes/combat/board_debug.tscn`, `scenes/flow/shop_player.tscn`, `scenes/flow/boss_relic_reward.tscn`, `scenes/flow/run_summary_placeholder.tscn`, `addons/gdai-mcp-plugin-godot/plugin.cfg`

**Last updated**: 2026-04-30

---

## Overview

The project is a Godot 4.6 game named `Orbwalker`. The main scene is `res://scenes/main.tscn`, and `project.godot` configures `RunState` as an autoload and enables the bundled GDAI MCP editor plugin. (source: `project.godot`)

## Details

- Open the project in Godot 4.6 and run `res://scenes/main.tscn` as the start scene. (source: `project.godot`)
- Use `res://scenes/combat/board_debug.tscn` for the main board and combat validation surface. (source: `docs/test_plan.md`, `docs/system_architecture.md`)
- The repository already contains the player-facing combat and shop scenes, plus the boss relic reward and run summary flow scenes. (source: `scripts/core/run_state.gd`, `scenes/flow/shop_player.tscn`, `scenes/flow/boss_relic_reward.tscn`, `scenes/flow/run_summary_placeholder.tscn`, `scenes/flow/shop_placeholder.tscn`)
- Project-local Codex defaults set the main/default model to `gpt-5.4-mini`, the explorer custom agent to `gpt-5.5`, and the worker custom agent to `gpt-5.3-codex-spark`. (source: `.codex/config.toml`, `.codex/agents/default.toml`, `.codex/agents/explorer.toml`, `.codex/agents/worker.toml`)
- The checked sources do not define a separate CLI build or test script. Validation in this repo is currently documented as manual QA plus Godot MCP/editor-script checks. (needs verification)

## Important Files

- `project.godot` - main scene, autoloads, display settings, and editor plugin enablement
- `.codex/config.toml` - project-local Codex default model settings
- `.codex/agents/` - project-local Codex custom agent definitions
- `scenes/main.tscn` - boot scene
- `scenes/combat/board_debug.tscn` - main debug and QA scene
- `docs/test_plan.md` - manual QA checklist
- `docs/system_architecture.md` - architecture and setup context

## Open Questions

- Whether a repo-local scripted build or test command should be added later. (needs verification)

## Related Pages

- [[architecture]]
- [[file-map]]
