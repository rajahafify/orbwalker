# Current Work Task Tracker

Purpose: track the immediate work needed to close the current assetgen main-menu integration and Android build handoff before returning to the broader itch.io readiness backlog.

Source trackers: `docs/itch_readiness_tasks.md`, `wiki/main-menu-assets.md`, `todo.md`

Status values: `not started`, `in progress`, `blocked`, `done`, `deferred`.

Completion rule: do not mark a task `done` unless the validation evidence is recorded in `docs/test_plan.md` or explicitly accepted by the human after manual QA. Use Godot MCP for Godot runtime validation and do not use headless Godot.

## Current Snapshot

- Branch: `codex/assetgen-workflow`
- Latest committed work: `8104f70 Integrate approved main menu assets`
- Main-menu assetgen background, UI slices, semantic icons, and title logo are integrated for the main menu.
- Fresh Android debug APK was exported to `D:\godot\matchatro\Orbwalker.apk` on 2026-05-16 after switching from the Steam Godot binary to the desktop Godot console binary.
- Android device install/test is still pending because no `adb` device was connected during the latest build attempt.
- The working tree currently has many untracked Godot `.import` cache sidecars under `assets/`; these should not be committed as source progress.

## Immediate Tasks

| ID | Task | Owner Scope | Status | Completion Evidence |
| --- | --- | --- | --- | --- |
| CW-01 | Clean generated `.import` cache noise under `assets/` or add an ignore rule if this keeps recurring. | Repo hygiene | `not started` | `git status --short --branch` shows no untracked `assets/**/*.import` cache noise. |
| CW-02 | Install the fresh APK on a connected Android device. | Android packaging | `blocked` | `adb devices` lists a device and `adb install -r D:\godot\matchatro\Orbwalker.apk` succeeds. |
| CW-03 | Run Android smoke on the exact installed APK. | Android QA | `blocked` | Manual or logged evidence covers launch, new main-menu art visible, Start Run, drag/match, victory/shop route, and return path. |
| CW-04 | Record Android build and smoke evidence in `docs/test_plan.md`. | Documentation | `not started` | `docs/test_plan.md` includes APK timestamp/hash, install result, smoke path, and remaining caveats. |
| CW-05 | Decide whether this debug APK is acceptable for internal sharing or whether a public-release packaging pass is required first. | Release decision | `not started` | Human decision recorded here or in `docs/itch_readiness_tasks.md`. |
| CW-06 | If public sharing is next, start ITCH-06 Public Build Packaging on a focused branch. | Itch readiness | `not started` | ITCH-06 status updated with packaging evidence and export caveats. |
| CW-07 | If full readiness is next, run ITCH-08 Final Release Candidate QA against the exact build. | Final QA | `not started` | ITCH-08 acceptance evidence recorded in `docs/test_plan.md` and human approval captured. |

## Dependencies

- CW-02 and CW-03 require a connected Android device visible to `adb`.
- CW-04 depends on CW-02/CW-03 unless the test-plan update is explicitly limited to build-only evidence.
- CW-06 and CW-07 should not be treated as complete until the exact build artifact has been validated, not merely exported.

## Notes

- The Steam Godot binary in `D:\Program Files (x86)\Steam\steamapps\common\Godot Engine\` uses self-contained `editor_data` and previously returned exit code `0` despite Android export configuration errors. For the latest successful export, the desktop Godot console binary at `C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe` produced the APK successfully.
- The existing `docs/itch_readiness_tasks.md` remains the owner for launch readiness. This tracker is a short active-work layer for the current handoff only.
