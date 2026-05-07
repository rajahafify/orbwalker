# Setup

**Summary**: Practical setup and validation notes for the current Godot checkout. This page records only the commands and surfaces that are actually present in the repository.

**Sources**: `project.godot`, `AGENTS.md`, `.codex/config.toml`, `.codex/agents/default.toml`, `.codex/agents/explorer.toml`, `.codex/agents/worker.toml`, `docs/system_architecture.md`, `docs/test_plan.md`, `scenes/main_menu.tscn`, `scenes/combat.tscn`, `scenes/shop.tscn`, `scenes/run_summary.tscn`, `addons/gdai-mcp-plugin-godot/plugin.cfg`

**Last updated**: 2026-05-03

---

## Overview

The project is a Godot 4.6 game named `Orbwalker`. The main scene is `res://scenes/main_menu.tscn`, `project.godot` configures `RunState` as an autoload, uses `res://raw/spash.png` for the boot splash image, and enables the bundled GDAI MCP editor plugin. (source: `project.godot`)

## Details

- Open the project in Godot 4.6 and run `res://scenes/main_menu.tscn` as the start scene. (source: `project.godot`)
- Use `res://scenes/combat.tscn` for player-facing combat validation, `res://scenes/shop.tscn` for shop validation, `res://scenes/run_summary.tscn` for final summary validation, and focused Godot MCP editor-script probes for board resolver/combat envelope checks. The old board-debug scene has been removed. (source: `AGENTS.md`, `docs/test_plan.md`)
- The repository contains the player-facing combat and shop scenes plus the final run summary flow scene. Boss relic rewards are selected inside the combat victory overlay; the old boss relic reward and shop placeholder scenes have been removed. (source: `scripts/core/run_state.gd`, `scripts/scenes/combat.gd`, `scenes/shop.tscn`, `scenes/run_summary.tscn`)
- Project-local Codex defaults set the main/default model to `gpt-5.5` with `low` reasoning, the explorer custom agent to `gpt-5.5` with `medium` reasoning, and the worker custom agent to `gpt-5.3-coder` with `high` reasoning; milestone-style implementation prompts use this multi-agent workflow by default, and spawned subagents must be launched with explicit model overrides. (source: `AGENTS.md`, `.codex/config.toml`, `.codex/agents/default.toml`, `.codex/agents/explorer.toml`, `.codex/agents/worker.toml`)
- Closed for current readiness: the repo currently relies on manual QA plus Godot MCP/editor-script checks. Public release-candidate validation is owned by ITCH-06/ITCH-08 in `docs/itch_readiness_tasks.md`.
- AR-01 combat result-envelope regression can be rerun with `res://scripts/debug/ar01_combat_result_probe.gd`. It is disabled by default behind project setting `debug/ar01_combat_result_probe_enabled=false`; enable it only for the probe call, then turn it back off. (source: `scripts/debug/ar01_combat_result_probe.gd`, `docs/test_plan.md`)
- New automated logic tests should live under `scripts/tests/` and use `*_test.gd` filenames. Keep them framework-free for now: expose a static or instance runner that can be called from Godot MCP `execute_editor_script`, return a structured pass/fail report, and use simple assertions or explicit failure collection. Retained probes under `scripts/debug/` are legacy validation helpers, not the preferred location for new tests. (source: `docs/test_plan.md`)
- MIDI music sources can be rendered to Godot-ready WAV files with `python tools/audio/export_midi_to_wav.py`. The script defaults to the local FluidSynth binary at `C:\Users\Home\Downloads\orbwalker\fluidsynth-v2.5.4-win10-x64-cpp11\fluidsynth-v2.5.4-win10-x64-cpp11\bin\fluidsynth.exe` and `raw/GeneralUser GS v1.471.sf2`; override either path with `--fluidsynth` or `--soundfont`. (source: `tools/audio/export_midi_to_wav.py`, `raw/`)
- Android debug export currently uses the Godot 4.6.2 console executable and the `Android` export preset:
  - `& 'C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe' --path 'D:\godot\matchatro' --export-debug Android 'D:\godot\matchatro\Orbwalker.apk'`
  - On this Windows checkout, the command has repeatedly written a valid `Orbwalker.apk` and then failed to terminate cleanly, leaving a `Godot_v4.6.2-stable_win64_console.exe` process plus a Java/Gradle child. Treat this as an export-tool shutdown issue, not proof that the APK failed. Check `Orbwalker.apk` `LastWriteTime`/size, install with `adb install -r D:\godot\matchatro\Orbwalker.apk`, then stop only the stuck console exporter and Java child if needed. Leave the main Godot editor process running. (source: `export_presets.cfg`, `docs/test_plan.md`)

## Important Files

- `project.godot` - main scene, autoloads, display settings, and editor plugin enablement
- `AGENTS.md` - project operating rules, including the multi-agent workflow
- `.codex/config.toml` - project-local Codex default model settings
- `.codex/agents/` - project-local Codex custom agent definitions
- `scenes/main_menu.tscn` - boot scene
- `scripts/debug/ar01_combat_result_probe.gd` - feature-flagged AR-01 combat envelope regression probe
- `scripts/tests/*_test.gd` - preferred convention for new automated logic tests and lightweight callable runners for current MVC models plus combat state-machine invariants
- `docs/test_plan.md` - manual QA checklist
- `docs/system_architecture.md` - architecture and setup context
- `tools/audio/export_midi_to_wav.py` - MIDI-to-WAV export helper for music assets
- `export_presets.cfg` - Android export preset for `Orbwalker.apk`

## Open Questions

- Closed for current readiness: a repo-local scripted build/test command is optional future tooling unless ITCH-06 requires it.
- Transferred to ITCH-06: the Godot Android CLI export hang root-cause/workaround is now part of public build packaging readiness.

## Related Pages

- [[architecture]]
- [[file-map]]
