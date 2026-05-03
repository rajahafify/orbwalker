# AGENTS.md

Project operating rules for AI agents working in `D:\godot\matchatro`.

## Project Context

Matchatro, currently titled Orbwalker in Godot project metadata, is a Godot 4.6 game prototype. Treat this repository as an existing project with active source, docs, wiki, milestone tracking, and project-local Codex agent config.

Important project surfaces:

- `project.godot` - Godot project configuration, main scene, autoloads, and plugin enablement.
- `todo.md` - milestone scope and status tracker.
- `docs/test_plan.md` - QA checklist and validation notes.
- `docs/game_design_document.md` - product/design intent.
- `docs/system_architecture.md` - human-written architecture notes.
- `wiki/` - agent-maintained knowledge base.
- `.codex/config.toml` and `.codex/agents/` - project-local Codex model and role configuration.

## Source Of Truth

Use this priority order:

1. Actual source code, scenes, resources, and tests.
2. Raw source material in `raw/`.
3. Human-written docs in `docs/` and root project files.
4. Agent-maintained wiki pages.
5. Chat/task instructions from the human.

Rules:

- For current behavior, trust source files over wiki or docs.
- For intended design, trust raw specs, design docs, or explicit human instructions over wiki.
- If code, docs, wiki, and task instructions disagree, call out the contradiction and update the wiki when useful.
- If something cannot be verified, mark it as `needs verification`.

## Default Multi-Agent Workflow

Use the multi-agent workflow by default for milestone-style implementation prompts such as `Work on milestone 1`, unless the human explicitly asks to keep work in the main thread.

Role split:

- `default` uses `gpt-5.5` with low reasoning for orchestration, task generation, integration, documentation, summary, and handoff.
- `explorer` uses `gpt-5.5` for exploration tasks, planning research, behavior checks, risk review, and source/wiki contradiction checks.
- `worker` uses `gpt-5.3-codex` for bounded implementation, focused file edits, assigned docs/wiki updates, and validation follow-through.

Code editing rule:

- In multi-agent mode, source/runtime code edits are done only by `worker`.
- `default` may edit documentation, wiki, `AGENTS.md`, and `.codex/` orchestration files, but must not directly edit gameplay/runtime files such as `scripts/`, `scenes/`, `resources/`, `addons/`, `tools/`, `project.godot`, `.gd`, `.tscn`, `.tres`, or `.res` files.
- `explorer` must not edit any files.
- If a worker cannot be spawned, `default` must stop and report the blocker before making source/runtime code edits, unless the human explicitly authorizes main-thread implementation.

When spawning subagents, pass explicit model overrides. Do not rely on the role name or `.codex/agents/*.toml` alone to select the model:

- Spawn `explorer` with `agent_type = "explorer"`, `model = "gpt-5.5"`, and `reasoning_effort = "medium"`.
- Spawn `worker` with `agent_type = "worker"`, `model = "gpt-5.3-codex"`, and `reasoning_effort = "high"`.
- Keep orchestration and final handoff in the main/default agent using `gpt-5.5` with low reasoning.

Default milestone flow, step by step:

1. `default` reads `todo.md`, `docs/test_plan.md`, relevant wiki pages, and the human request.
2. `default` generates concrete tasks and separates exploration, planning, implementation, validation, and documentation work.
3. `explorer` handles exploration tasks: relevant files, current behavior, risks, stale docs, and source/wiki contradictions.
4. `explorer` handles planning research tasks when the plan depends on codebase facts, milestone scope, validation surfaces, or implementation risks.
5. `default` turns explorer findings into an ordered implementation plan with explicit worker ownership.
6. `worker` handles source/runtime code edits with explicit file or module ownership.
7. `default` reviews worker results, coordinates or records validation, resolves docs/wiki updates, and summarizes remaining uncertainty.

Do not skip phases in multi-agent mode. If a phase is unnecessary, state why before moving to the next phase.

Worker rules:

- Tell workers they are not alone in the codebase.
- Tell workers not to revert edits made by others.
- Give each worker a clear ownership area or file/module scope.
- Assign all source/runtime code edits to workers in multi-agent mode.
- Do not assign overlapping worker write scopes unless the human explicitly accepts the merge risk.
- Require workers to report changed file paths and validation performed.

Explorer rules:

- Explorers should not edit files.
- Explorer findings are evidence, not final authority; verify against source before changing behavior.
- Use explorers for sidecar research that can run in parallel with default-agent orchestration or unrelated local work.

## Development Workflow

For every coding task:

1. Check `git status --short --branch`.
2. Read related wiki pages before editing.
3. Inspect relevant source files, scenes, resources, and docs.
4. Make the smallest working change that satisfies the request.
5. Preserve existing project patterns and avoid unrelated refactors.
6. Run relevant validation, using Godot MCP for Godot behavior.
7. Update docs/wiki when behavior, setup, file responsibilities, or durable project knowledge changes.
8. Append `wiki/log.md` when the wiki changes.
9. Summarize what changed, what was tested, what was not tested, and remaining uncertainty.

Do not commit unless the human explicitly asks.

## Godot Validation

Use `godot-mcp` for Godot tasks. Do not use headless Godot.

Preferred validation surfaces and tools:

- `res://scenes/main.tscn` - startup/main-menu flow.
- `res://scenes/combat/combat_player.tscn` - player-facing combat scene.
- `res://scenes/flow/shop_player.tscn` - player-facing shop flow.
- `res://scenes/flow/final_run_summary.tscn` - final victory summary flow.
- Focused `execute_editor_script` probes for board resolver, combat envelope, RunState routing, and content contracts.
- `get_project_info`
- `get_godot_errors`
- `play_scene`
- `stop_running_scene`
- `get_scene_tree`
- `execute_editor_script`
- runtime node/property inspection where needed

Validation rules:

- If `get_godot_errors` looks stale, reload or inspect the relevant script/scene and rerun the check.
- Prefer small typed `execute_editor_script` probes over large ad hoc scripts.
- `res://scenes/combat/board_debug.tscn` has been removed; do not use it as a validation surface.
- If MCP tools are unavailable, state that clearly and record what was not tested.
- Do not claim runtime validation happened unless it actually ran.

## Wiki Workflow

The wiki is a working knowledge base, not the source of truth for current behavior.

Read first:

- `wiki/index.md`
- Relevant pages linked from the index.
- `wiki/setup.md`, `wiki/file-map.md`, `wiki/features.md`, `wiki/known-issues.md`, and `wiki/open-questions.md` when they match the task.

Update the wiki when:

- A feature changes or is added.
- A system, module, file responsibility, setup step, dependency, API, schema, interface, or validation workflow changes.
- A bug reveals a durable edge case.
- A design or technical decision is made.
- A repeated explanation would be useful later.

Do not update the wiki for:

- Small formatting-only changes.
- Temporary experiments that are reverted.
- Comment-only changes.
- Pure refactors that do not change behavior or understanding.

Wiki page rules:

- Use Obsidian-style links like `[[features]]`.
- Prefer lowercase hyphenated page names.
- Cite factual claims with source paths, for example `(source: scripts/core/run_state.gd)`.
- Mark unverified claims with `(needs verification)`.
- Keep `wiki/log.md` append-only. Do not rewrite old log entries except to fix formatting.

## Question Answering

When answering project questions:

1. Read `wiki/index.md`.
2. Read relevant wiki pages.
3. Inspect source files if the answer depends on current behavior.
4. Answer directly with concrete file references.
5. Say when the answer is not in the wiki.
6. Update the wiki and append `wiki/log.md` only if the answer adds durable project knowledge.

## Documentation And Milestones

Keep these files synchronized when milestone work changes behavior or accepted scope:

- `todo.md`
- `docs/test_plan.md`
- relevant `wiki/` pages
- `wiki/log.md`

For milestone work, use `todo.md` for scope and status, `docs/test_plan.md` for QA state, and wiki pages for durable implementation knowledge. Do not mark checklist items complete without real validation or explicit human confirmation.

## Coding Style

Prefer:

- Clear names.
- Small functions.
- Simple data structures.
- Explicit state.
- Existing project patterns.
- Minimal dependencies.

Avoid:

- Large rewrites.
- Hidden side effects.
- Unnecessary abstractions.
- Mixing unrelated changes.
- Adding dependencies without a strong reason.
- Changing public behavior without being asked.

Use `apply_patch` for manual edits. In this PowerShell environment, use `;` instead of `&&`.

## Safety Rules

Do not:

- Delete user data.
- Modify files in `raw/` unless explicitly requested.
- Commit secrets, API keys, tokens, or credentials.
- Rewrite configuration without checking how it is used.
- Make destructive changes unless explicitly requested.
- Replace working code with speculative architecture.
- Revert user changes unless explicitly asked.

Before adding a dependency:

1. Check whether the project already has a suitable dependency.
2. Prefer standard library or existing utilities.
3. Confirm the dependency is necessary.
4. Record the reason in `wiki/decisions.md`.
5. Update setup/install docs if needed.

## Git And Branches

- Check live branch and worktree state before repo maintenance.
- This repo commonly uses `codex/milestone-*` branch names; verify exact branch names before switching, rebasing, or merging.
- Prefer fast-forward or linear history operations when branch topology allows.
- Do not use destructive commands like `git reset --hard` or `git checkout --` unless the human explicitly requests them.
- Commit only when requested. When committing, keep the commit focused on the requested work.

## Completion Criteria

A task is complete when:

- The requested work is done.
- Relevant source files were inspected.
- Relevant validation was run, or the untested scope is clearly stated.
- Wiki/docs were updated if durable project knowledge changed.
- `wiki/log.md` has a new entry if the wiki changed.
- Remaining uncertainty is recorded or called out.
- Final response states what changed, what was tested, and what remains uncertain.
