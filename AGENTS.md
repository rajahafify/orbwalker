\# AGENTS.md



\# LLM Wiki for Development Projects



A project knowledge base maintained by AI coding agents.



This file defines how agents should understand the project, ingest sources, maintain the wiki, answer questions, and make code changes.



The goal is to make project knowledge compound over time instead of being lost across chats, commits, issues, or coding sessions.



\---



\## Core Idea



This repository has three knowledge layers:



```text

raw/           -- immutable source material

wiki/          -- generated markdown knowledge base maintained by agents

AGENTS.md      -- operating rules for agents

```



For existing projects, the current source code is also a source of truth:



```text

src/           -- application/source code

docs/          -- existing human-written documentation

tests/         -- tests and validation

config files   -- setup, dependencies, deployment, tooling

```



The wiki sits between the raw sources and day-to-day work.



Agents should use the wiki to understand the project quickly, but they must verify against source files before changing behavior.



\---



\## Purpose



The wiki is a structured, interlinked knowledge base for understanding, developing, and maintaining this project.



It should contain:



\- Current project overview

\- Setup instructions

\- Architecture notes

\- File and folder map

\- Feature descriptions

\- Important workflows

\- Design decisions

\- Known issues

\- Open questions

\- Source summaries



The human gives tasks, reviews important decisions, and guides direction.



The agent does the maintenance work: summarizing, cross-linking, updating, checking contradictions, and keeping the wiki current.



\---



\## Folder Structure



Recommended structure:



```text

raw/                 -- source documents, specs, notes, transcripts, references

wiki/                -- markdown pages maintained by agents

wiki/index.md        -- table of contents for the wiki

wiki/log.md          -- append-only history of wiki operations

wiki/setup.md        -- setup, install, run, test commands

wiki/architecture.md -- system architecture

wiki/file-map.md     -- important files and folders

wiki/features.md     -- product or system features

wiki/decisions.md    -- design and technical decisions

wiki/known-issues.md -- bugs, limitations, technical debt

wiki/open-questions.md -- unresolved questions

```



Optional folders may exist:



```text

docs/                -- existing project documentation

src/                 -- source code

test/ or tests/      -- tests

scripts/             -- utility scripts

assets/              -- images, media, or generated assets

```



If this is a new project, create the wiki structure as the project takes shape.



If this is an existing project, inspect the repository first, then create or update the wiki based on what already exists.



\---



\## Source of Truth Rules



Use this priority order:



1\. Actual source code and tests

2\. Raw source material in `raw/`

3\. Official docs in `docs/` or `README.md`

4\. Existing wiki pages

5\. Chat/task instructions from the human



Rules:



\- For current behavior, trust code over wiki.

\- For intended design, trust raw specs or explicit human instructions over wiki.

\- If code and wiki disagree, note the contradiction and update the wiki.

\- If sources disagree, document the disagreement instead of silently choosing one.

\- If something cannot be verified, mark it as `needs verification`.



\---



\## Initial Setup for a New Project



When this is a new or mostly empty project:



1\. Read `AGENTS.md`.

2\. Inspect the current repository structure.

3\. Create the `raw/` and `wiki/` folders if missing.

4\. Create the core wiki pages:

&#x20;  - `wiki/index.md`

&#x20;  - `wiki/log.md`

&#x20;  - `wiki/setup.md`

&#x20;  - `wiki/architecture.md`

&#x20;  - `wiki/file-map.md`

&#x20;  - `wiki/features.md`

&#x20;  - `wiki/decisions.md`

&#x20;  - `wiki/known-issues.md`

&#x20;  - `wiki/open-questions.md`

5\. Record the current project goal in `wiki/index.md`.

6\. Record unknowns in `wiki/open-questions.md`.

7\. Append an entry to `wiki/log.md`.



Do not invent architecture, setup commands, or features. If the project is not yet defined, mark details as `needs definition`.



\---



\## Initial Setup for an Existing Project



When this is an existing project:



1\. Read `AGENTS.md`.

2\. Inspect the repository structure.

3\. Identify the main language, framework, package manager, build tools, test tools, and run commands.

4\. Read existing documentation and important configuration files.

5\. Inspect source code entry points and major modules.

6\. Create or update the `wiki/` folder.

7\. Create missing core wiki pages.

8\. Update:

&#x20;  - `wiki/setup.md`

&#x20;  - `wiki/architecture.md`

&#x20;  - `wiki/file-map.md`

&#x20;  - `wiki/features.md`

&#x20;  - `wiki/known-issues.md`

&#x20;  - `wiki/open-questions.md`

9\. Update `wiki/index.md`.

10\. Append an entry to `wiki/log.md`.



Do not refactor code or change behavior during initial ingestion.



\---



\## Common Files to Inspect



Inspect files that exist in the repository, such as:



```text

README.md

CHANGELOG.md

CONTRIBUTING.md

LICENSE

package.json

pnpm-lock.yaml

yarn.lock

package-lock.json

Gemfile

Gemfile.lock

requirements.txt

pyproject.toml

poetry.lock

Cargo.toml

Cargo.lock

go.mod

go.sum

composer.json

composer.lock

pom.xml

build.gradle

Dockerfile

docker-compose.yml

Makefile

Taskfile.yml

justfile

.env.example

tsconfig.json

vite.config.\*

next.config.\*

nuxt.config.\*

tailwind.config.\*

eslint.config.\*

.prettierrc

.github/workflows/

```



Only record commands that are actually present or clearly documented.



\---



\## Ingest Workflow



When the human asks you to ingest a source, document, folder, or repository:



1\. Read `AGENTS.md`.

2\. Identify the source being ingested.

3\. Read the relevant source fully enough to understand it.

4\. Extract key facts, decisions, systems, entities, workflows, and open questions.

5\. Create or update relevant pages in `wiki/`.

6\. Add wiki-links using `\[\[page-name]]`.

7\. Update `wiki/index.md`.

8\. Append an entry to `wiki/log.md`.



A single source may update many wiki pages. That is normal.



Do not modify files in `raw/` unless explicitly requested.



\---



\## Codebase Ingestion Workflow



When ingesting code:



1\. Identify app entry points.

2\. Identify major modules, folders, and responsibilities.

3\. Identify important runtime flows.

4\. Identify setup, run, build, test, lint, and deploy commands.

5\. Identify important dependencies.

6\. Map features to source files.

7\. Record known bugs, risks, or unclear areas.

8\. Update the wiki.



Do not change application behavior during ingestion.



\---



\## Page Format



Every wiki page should use this structure:



```markdown

\# Page Title



\*\*Summary\*\*: One to two sentences describing this page.



\*\*Sources\*\*: Source files, raw documents, or code paths this page draws from.



\*\*Last updated\*\*: YYYY-MM-DD



\---



\## Overview



Main explanation in clear, plain language.



\## Details



Important facts, rules, flows, or notes.



\## Important Files



\- `path/to/file.ext` - why it matters



\## Open Questions



\- Question or uncertainty



\## Related Pages



\- \[\[related-page]]

```



Use only sections that make sense for the page.



\---



\## Citation Rules



Every factual claim about the project should reference a source.



Use this style:



```text

This app uses Vite for development. (source: package.json)

```



For code behavior:



```text

Authentication is handled in the login controller. (source: src/controllers/login\_controller.ts)

```



For design intent:



```text

The MVP should support offline drafts. (source: raw/mvp-spec.md)

```



If unverified:



```text

The app may require Redis for background jobs. (needs verification)

```



If sources conflict:



```text

README.md says the app uses npm, but package-lock is missing and pnpm-lock.yaml exists. This needs confirmation.

```



\---



\## Wiki-Link Rules



Use Obsidian-style wiki links:



```text

\[\[authentication]]

\[\[database-schema]]

\[\[deployment]]

```



Rules:



\- Use lowercase page names.

\- Use hyphens between words.

\- Prefer one concept per page.

\- Link related concepts when mentioned.

\- Avoid creating duplicate pages for the same concept.



\---



\## Index Rules



`wiki/index.md` is the map of the wiki.



It should include:



```markdown

\# Wiki Index



\## Overview



\- \[\[architecture]] - High-level system architecture

\- \[\[setup]] - Install, run, test, and build commands

\- \[\[file-map]] - Main folders and responsibilities



\## Features



\- \[\[feature-name]] - One-line feature description



\## Decisions



\- \[\[decisions]] - Technical and product decisions



\## Maintenance



\- \[\[known-issues]] - Bugs, risks, and limitations

\- \[\[open-questions]] - Unresolved questions

```



Update `wiki/index.md` whenever pages are added, renamed, or significantly changed.



\---



\## Log Rules



`wiki/log.md` is append-only.



Add an entry after every ingest, major answer, wiki audit, or code change that updates the wiki.



Use this format:



```markdown

\## \[YYYY-MM-DD] type | Short Title



\- Source: `path/to/source`

\- Changed:

&#x20; - Created `wiki/example.md`

&#x20; - Updated `wiki/index.md`

\- Notes:

&#x20; - Uncertainty or follow-up if any

```



Example types:



```text

ingest

query

audit

code-change

docs

decision

```



Do not rewrite old log entries except to fix formatting.



\---



\## Question Answering Workflow



When the human asks a question about the project:



1\. Read `wiki/index.md`.

2\. Read relevant wiki pages.

3\. Inspect source files if the answer depends on current behavior.

4\. Answer directly.

5\. Cite wiki pages, raw sources, or source files.

6\. If the answer is not in the wiki, say so.

7\. If the answer is valuable, update or create a wiki page.

8\. Append a log entry if the wiki changed.



\---



\## Multi-Agent Workflow



Project-local Codex agent definitions live in `.codex/agents/`.



Use these roles by default for milestone-style implementation prompts such as `Work on milestone 1`, unless the human explicitly asks to keep all work in the main thread:



\- `default` uses `gpt-5.4-mini` for orchestration, task generation, final integration, summary, documentation, and commit/report handoff.

\- `explorer` uses `gpt-5.5` for exploration tasks, planning research, codebase questions, architecture lookup, bug tracing, risk review, and source/wiki contradiction checks.

\- `worker` uses `gpt-5.3-codex-spark` for working tasks: bounded implementation, focused file edits, docs/wiki updates assigned to the worker, and validation follow-through.



Rules:



1\. For milestone-style implementation prompts, the default agent first reads `todo.md`, relevant wiki pages, and `docs/test_plan.md`, then generates a concrete task breakdown before assigning subagent work.

2\. Assign exploration tasks to `explorer`, including finding relevant files, checking current behavior, identifying risks, and verifying source/wiki contradictions.

3\. Assign planning research tasks to `explorer` when the plan depends on codebase facts, milestone scope, validation surfaces, or implementation risks.

4\. Assign working tasks to `worker` with a clear ownership area or file/module scope.

5\. Tell workers they are not alone in the codebase, must not revert edits made by others, and must report changed file paths plus validation performed.

6\. Do not assign two workers overlapping write scopes unless the human explicitly accepts the merge risk.

7\. Keep final summary, documentation reconciliation, wiki/log updates, and user-facing handoff in the default agent.

8\. Treat explorer findings as advisory evidence; verify against source before changing behavior.



Default milestone flow:



1\. `default` generates tasks from `todo.md`, wiki context, `docs/test_plan.md`, and the human request.

2\. `explorer` handles exploration tasks.

3\. `explorer` handles planning research tasks.

4\. `worker` handles working tasks with explicit file/module ownership.

5\. `default` integrates results, resolves documentation, summarizes, and records remaining uncertainty.



\---



\## Development Workflow



For every coding task:



1\. Understand the request.

2\. Read related wiki pages.

3\. Inspect relevant source files.

4\. Make the smallest working change.

5\. Avoid unrelated refactors.

6\. Run relevant tests, lint, type checks, or manual validation.

7\. Update wiki pages if behavior changed.

8\. Update `wiki/index.md` if pages were added or renamed.

9\. Append a `code-change` entry to `wiki/log.md`.

10\. Summarize:

&#x20;   - What changed

&#x20;   - What was tested

&#x20;   - What was not tested

&#x20;   - Any remaining uncertainty



\---



\## Wiki Maintenance Rules



Update the wiki when:



\- A feature changes

\- A new feature is added

\- A system or module is added

\- A file responsibility changes

\- A setup step changes

\- A dependency changes

\- An API, route, schema, or interface changes

\- A bug reveals an edge case

\- A design or technical decision is made

\- A repeated explanation would be useful later



Do not update the wiki for:



\- Small formatting changes

\- Pure refactors with no behavior change

\- Temporary experiments that are reverted

\- Comment-only changes

\- Naming changes that do not affect understanding



\---



\## Lint / Audit Workflow



When asked to lint or audit the wiki:



1\. Check that all important pages are listed in `wiki/index.md`.

2\. Check that pages follow the page format.

3\. Check for missing sources.

4\. Check for stale claims that conflict with code or newer sources.

5\. Check for orphan pages with no inbound links.

6\. Check for important concepts without pages.

7\. Check for duplicate or overlapping pages.

8\. Check that `wiki/log.md` is append-only and current.

9\. Report findings as a numbered list with suggested fixes.

10\. Apply fixes if requested.



\---



\## Coding Style



Prefer:



\- Clear names

\- Small functions

\- Simple data structures

\- Explicit state

\- Existing project patterns

\- Minimal dependencies



Avoid:



\- Large rewrites

\- Hidden side effects

\- Unnecessary abstractions

\- Mixing unrelated changes

\- Adding dependencies without a strong reason

\- Changing public behavior without being asked



\---



\## Safety Rules



Do not:



\- Delete user data

\- Delete migrations or historical records

\- Modify files in `raw/` unless explicitly requested

\- Commit secrets, API keys, tokens, or credentials

\- Rewrite configuration without checking how it is used

\- Make destructive changes unless explicitly requested

\- Replace working code with speculative architecture



\---



\## Dependency Rules



Before adding a dependency:



1\. Check if the project already has a suitable dependency.

2\. Prefer standard library or existing utilities.

3\. Confirm the dependency is necessary.

4\. Record the reason in `wiki/decisions.md`.

5\. Update setup or install docs if needed.



\---



\## Decision Rules



Record decisions in `wiki/decisions.md` when they affect:



\- Architecture

\- Data model

\- External services

\- Dependencies

\- Public APIs

\- Deployment

\- Security

\- Product behavior

\- Long-term maintenance



Use this format:



```markdown

\## YYYY-MM-DD - Decision Title



\*\*Decision\*\*: What was decided.



\*\*Reason\*\*: Why.



\*\*Alternatives considered\*\*: Other options.



\*\*Consequences\*\*: Tradeoffs or follow-up work.



\*\*Sources\*\*: Relevant files, docs, or discussion.

```



\---



\## New Project Guidance



For a new project, agents should help create structure gradually.



Start with:



```text

wiki/index.md

wiki/setup.md

wiki/architecture.md

wiki/features.md

wiki/decisions.md

wiki/open-questions.md

```



As implementation appears, add:



```text

wiki/file-map.md

wiki/known-issues.md

feature-specific pages

module-specific pages

```



Do not over-document empty systems. Create pages when useful.



\---



\## Existing Project Guidance



For an existing project, agents should document what is real.



Prefer:



\- Existing code behavior

\- Existing commands

\- Existing architecture

\- Existing tests

\- Existing deployment files



Avoid:



\- Idealized architecture

\- Assumed setup steps

\- Made-up conventions

\- Future plans not present in sources



\---



\## Completion Criteria



A task is complete when:



\- The requested work is done

\- Relevant source files were inspected

\- Relevant tests or checks were run where possible

\- Wiki pages were updated if knowledge changed

\- `wiki/index.md` was updated if needed

\- `wiki/log.md` has a new entry if the wiki changed

\- Remaining uncertainty is recorded in `wiki/open-questions.md`

\- The final response is concise and states:

&#x20; - What changed

&#x20; - What was tested

&#x20; - What remains uncertain
