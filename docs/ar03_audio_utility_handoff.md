# AR-03 Audio Utility Handoff

Purpose: give the next agent a focused starting point for AR-03, the shared WAV/audio utility extraction.

## Current State

- Branch handoff source: `codex/ar-02-low-risk-bug-fixes`.
- AR-01 baseline and retained combat result-envelope probe are available. Rerun `res://scripts/debug/ar01_combat_result_probe.gd` through Godot MCP with `ResourceLoader.CACHE_MODE_IGNORE` and `debug/ar01_combat_result_probe_enabled=true`, then set the flag back to `false`.
- AR-02 is complete. User-confirmed rapid-click QA passed for `Shop -> Main Menu`: the main menu opens once, shop music stops, only main-menu music remains audible, and the missing `debug/audio_diagnostics_enabled` error no longer appears.
- Known non-AR-03 noise: Godot still reports unsourced `GDScript::reload: Integer division. Decimal part will be discarded.` warnings after some scene smokes.

## Problem To Solve

WAV parsing and loop/frame-count helpers are duplicated between:

- `scripts/core/audio_manager.gd`
- `scripts/core/main_boot.gd`

Confirmed duplicated helper areas:

- `_load_pcm16_wav_stream(...)`
- `_load_imported_audio_stream(...)`
- `_configure_wav_loop(...)`
- `_wav_frame_count(...)`
- `_wav_source_frame_count(...)`
- byte-file loading / `FileAccess` handling

The live behavior must not change while extracting this utility.

## Recommended Scope

Keep AR-03 narrow and behavior-preserving:

1. Create one shared helper script under `scripts/core/`, for example `scripts/core/audio_stream_loader.gd`.
2. Move only generic WAV/imported-stream loading, WAV frame counting, and loop configuration into the helper.
3. Keep music ownership and runtime policy in the existing scene/controller scripts:
   - `AudioManager` still owns global music/SFX, generated fallback music, Android/template raw WAV preference, manual restart, and diagnostics.
   - `MainBoot` still owns the desktop/editor local `MainMenuMusicPlayer` path and stops shared `AudioManager` music before local playback.
4. Preserve Android/template behavior:
   - `AudioManager` tries `resources/audio/raw_music/*.wav.bin` first.
   - It then tries `resources/audio/music/*.wav`.
   - It then falls back to generated music.
   - Android/template WAV playback still disables internal WAV looping and relies on manual restart.
5. Preserve desktop/editor behavior:
   - Main menu local player uses `resources/audio/music/main-menu.wav`.
   - Main menu local WAV playback keeps internal WAV looping enabled.
   - Combat/shop continue to route through `AudioManager`.

Avoid broad audio architecture changes, music routing rewrites, new dependencies, generated asset changes, or Android export work unless the user explicitly expands scope.

## Multi-Agent Instructions

Follow `AGENTS.md`.

- Use the multi-agent workflow.
- Use Godot MCP for validation.
- Do not use headless Godot.
- Let an `explorer` do read-only comparison of current helper behavior and validation surfaces.
- Let a `worker` own runtime source edits. A safe worker write scope is:
  - `scripts/core/audio_stream_loader.gd`
  - `scripts/core/audio_manager.gd`
  - `scripts/core/main_boot.gd`
- The main/default agent may update docs/wiki after validation.
- Do not revert user changes or unrelated work.

## Suggested Validation

Use Godot MCP only:

1. `view_script`:
   - `res://scripts/core/audio_stream_loader.gd`
   - `res://scripts/core/audio_manager.gd`
   - `res://scripts/core/main_boot.gd`
2. Focused editor-script probes:
   - Load menu/combat/shop WAV streams through the extracted helper.
   - Confirm loaded streams are `AudioStreamWAV`.
   - Confirm positive frame counts for `resources/audio/music/main-menu.wav`, `combat.wav`, and `shop.wav`.
   - Confirm desktop loop mode is forward with positive `loop_end`.
   - Confirm Android/template policy can still request disabled internal loop through the helper without changing actual platform flags.
   - Confirm generated SFX still builds through `AudioManager.play_sfx("swap")`.
3. Scene smokes:
   - `play_scene main`, inspect `MainMenuMusicPlayer`.
   - `play_scene` or instantiate `res://scenes/combat/combat_player.tscn`.
   - Instantiate or run `res://scenes/flow/shop_player.tscn` with an active-run setup if practical.
4. Rerun retained AR-01 combat result-envelope probe and compare against documented baseline.
5. `get_godot_errors`; call out the known integer-division warnings separately from any new errors.
6. `git diff --check`.

Manual listening remains useful for final acceptance because the highest-risk regression is audible loop/playback behavior, especially Android/template playback.

## Documentation To Update

If AR-03 changes file ownership or durable behavior, update:

- `docs/architecture_review_tasks.md`
- `docs/test_plan.md`
- `wiki/features.md`
- `wiki/file-map.md`
- `wiki/known-issues.md` if any audio risk changes
- `wiki/log.md`

Do not mark Android/on-device listening complete unless it actually runs or the user explicitly confirms it.
