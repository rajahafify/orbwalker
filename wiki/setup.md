# Setup

**Summary**: Practical setup and validation notes for the current Godot checkout. This page records only the commands and surfaces that are actually present in the repository.

**Sources**: `project.godot`, `AGENTS.md`, `.codex/config.toml`, `.codex/agents/default.toml`, `.codex/agents/explorer.toml`, `.codex/agents/worker.toml`, `docs/system_architecture.md`, `docs/test_plan.md`, `scenes/main.tscn`, `scenes/combat/board_debug.tscn`, `scenes/flow/shop_player.tscn`, `scenes/flow/boss_relic_reward.tscn`, `scenes/flow/run_summary_placeholder.tscn`, `addons/gdai-mcp-plugin-godot/plugin.cfg`

**Last updated**: 2026-05-03

---

## Overview

The project is a Godot 4.6 game named `Orbwalker`. The main scene is `res://scenes/main.tscn`, `project.godot` configures `RunState` as an autoload, uses `res://raw/spash.png` for the boot splash image, and enables the bundled GDAI MCP editor plugin. (source: `project.godot`)

## Details

- Open the project in Godot 4.6 and run `res://scenes/main.tscn` as the start scene. (source: `project.godot`)
- Use `res://scenes/combat/board_debug.tscn` for the main board and combat validation surface. (source: `docs/test_plan.md`, `docs/system_architecture.md`)
- The repository already contains the player-facing combat and shop scenes, plus the boss relic reward and run summary flow scenes. (source: `scripts/core/run_state.gd`, `scenes/flow/shop_player.tscn`, `scenes/flow/boss_relic_reward.tscn`, `scenes/flow/run_summary_placeholder.tscn`, `scenes/flow/shop_placeholder.tscn`)
- Project-local Codex defaults set the main/default model to `gpt-5.5` with `low` reasoning, the explorer custom agent to `gpt-5.5` with `medium` reasoning, and the worker custom agent to `gpt-5.3-coder` with `high` reasoning; milestone-style implementation prompts use this multi-agent workflow by default, and spawned subagents must be launched with explicit model overrides. (source: `AGENTS.md`, `.codex/config.toml`, `.codex/agents/default.toml`, `.codex/agents/explorer.toml`, `.codex/agents/worker.toml`)
- The checked sources do not define a separate CLI build or test script. Validation in this repo is currently documented as manual QA plus Godot MCP/editor-script checks. (needs verification)
- AR-01 combat result-envelope regression can be rerun with `res://scripts/debug/ar01_combat_result_probe.gd`. It is disabled by default behind project setting `debug/ar01_combat_result_probe_enabled=false`; enable it only for the probe call, then turn it back off. (source: `scripts/debug/ar01_combat_result_probe.gd`, `docs/test_plan.md`)
- MIDI music sources can be rendered to Godot-ready WAV files with `python tools/audio/export_midi_to_wav.py`. The script defaults to the local FluidSynth binary at `C:\Users\Home\Downloads\orbwalker\fluidsynth-v2.5.4-win10-x64-cpp11\fluidsynth-v2.5.4-win10-x64-cpp11\bin\fluidsynth.exe` and `raw/GeneralUser GS v1.471.sf2`; override either path with `--fluidsynth` or `--soundfont`. (source: `tools/audio/export_midi_to_wav.py`, `raw/`)
- Android debug export currently uses the Godot 4.6.2 console executable and the `Android` export preset:
  - `& 'C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe' --path 'D:\godot\matchatro' --export-debug Android 'D:\godot\matchatro\Orbwalker.apk'`
  - On this Windows checkout, the command has repeatedly written a valid `Orbwalker.apk` and then failed to terminate cleanly, leaving a `Godot_v4.6.2-stable_win64_console.exe` process plus a Java/Gradle child. Treat this as an export-tool shutdown issue, not proof that the APK failed. Check `Orbwalker.apk` `LastWriteTime`/size, install with `adb install -r D:\godot\matchatro\Orbwalker.apk`, then stop only the stuck console exporter and Java child if needed. Leave the main Godot editor process running. (source: `export_presets.cfg`, `docs/test_plan.md`)

## Important Files

- `project.godot` - main scene, autoloads, display settings, and editor plugin enablement
- `AGENTS.md` - project operating rules, including the multi-agent workflow
- `.codex/config.toml` - project-local Codex default model settings
- `.codex/agents/` - project-local Codex custom agent definitions
- `scenes/main.tscn` - boot scene
- `scenes/combat/board_debug.tscn` - main debug and QA scene
- `scripts/debug/ar01_combat_result_probe.gd` - feature-flagged AR-01 combat envelope regression probe
- `docs/test_plan.md` - manual QA checklist
- `docs/system_architecture.md` - architecture and setup context
- `tools/audio/export_midi_to_wav.py` - MIDI-to-WAV export helper for music assets
- `export_presets.cfg` - Android export preset for `Orbwalker.apk`

## Open Questions

- Whether a repo-local scripted build or test command should be added later. (needs verification)
- Whether the Godot Android CLI export hang is caused by the Gradle build process, the enabled editor MCP plugin Android export warning, or Godot 4.6.2 console shutdown on Windows. (needs verification)

## Related Pages

- [[architecture]]
- [[file-map]]
