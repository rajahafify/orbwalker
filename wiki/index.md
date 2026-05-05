# Wiki Index

**Summary**: Entry point for the Orbwalker repo wiki. This maps the current project goal, the main technical pages, and the maintenance pages that should stay current.

**Sources**: `docs/game_design_document.md`, `docs/system_architecture.md`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `todo.md`, `project.godot`, `scripts/core/run_state.gd`

**Last updated**: 2026-05-05

---

## Overview

- [[architecture]] - Current and planned runtime architecture
- [[setup]] - How to open, run, and validate the project
- [[file-map]] - Folder and file responsibility map
- [[main-menu-assets]] - Main menu art package and asset map

## Current Goal

- First playable prototype vertical slice: a 3-level run with board combat, shop flow, boss rewards, initial content, temporary balance, and Milestone 11 meta progression. The current major project focus is Milestone 12 first playable build readiness, starting with reference-faithful mobile combat UI readability before export packaging. Deeper economy/combat tuning should wait until post-meta and post-build-readiness evidence exists. (source: `todo.md`, `docs/test_plan.md`, `docs/game_design_document.md`, `docs/architecture_review_tasks.md`, `docs/milestone_10_balance_tasks.md`)

## Features

- [[features]] - Implemented gameplay, UI, and content features
- [[log-notes]] - Human annotations for local Run Log files, such as player skill context not stored in the exported payload
- [[milestone-9-combat-ui-replication-plan]] - Approved combat UI replication plan for Milestone 9 close-match pass
- `docs/combat_feedback_revamp_tasks.md` - Combat feedback readability revamp tracker for result numbers, source-to-target timing, mastery activation, and enemy attack feedback
- `docs/milestone_10_balance_tasks.md` - Milestone 10 short-term playtest balance tracker for Run Log evidence, baseline runs, temporary balance levers, economy/survivability tuning, content access, and closeout. M10-01 added the passive Run Log API in `RunState` with opt-in JSON/text/Markdown files under gitignored `logs/`.

## Decisions

- [[decisions]] - Long-lived architecture and implementation decisions

## Maintenance

- [[known-issues]] - Current bugs, risks, and validation gaps
- [[open-questions]] - Open design and implementation questions
- `docs/architecture_review_tasks.md` - Architecture review task tracker
