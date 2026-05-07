# Assetgen Workflow

**Summary**: Governance workflow for AI-generated 2D assets before they are integrated into the game.

**Sources**: `resources/assetgen.workflow.md`

**Last updated**: 2026-05-07

---

## Overview

`resources/assetgen.workflow.md` defines the review and production process for generated 2D assets. It is a Codex multi-agent workflow, not a runtime asset loader or Godot integration script. The workflow keeps creative direction, generation metadata, QA, cleanup, human review, legal review, and final engine integration as separate gates. Each layer is owned by a separate `worker` subagent, while the main/default agent coordinates scope, reviews outputs, and records final status. (source: `resources/assetgen.workflow.md`)

## Details

The proposed asset workspace is organized under an `assets/` folder with separate areas for the art bible, asset briefs, prompt templates and run records, generated candidates and metadata, QA reports, transparency tests, cleanup outputs, approved assets, rejected assets, and engine-integrated copies. This folder structure is not yet the same as the existing `resources/art/first_pass/` runtime art package. (source: `resources/assetgen.workflow.md`, `resources/art/first_pass/`)

The workflow has three layers:

- Creative control: the art bible, asset briefs, prompt templates, style rules, palette rules, transparency requirements, and negative constraints define what may be generated.
- Asset production: candidates are generated from approved briefs, generation settings are recorded, QA checks style and technical fit, alpha/artifact cleanup happens before approval, and final assets are exported to the required size and format. All generated image candidate creation or editing must use the Codex `imagegen` skill, using the built-in `image_gen` tool path unless the human explicitly asks for the skill's CLI fallback. Sprite sheets, animation strips, and frame-normalized animation exports should use the available `game-studio:sprite-pipeline` skill after image candidates exist, for frame sizing, anchors, scale normalization, contact sheets, and preview packaging.
- Governance and integration: human review checks gameplay fit and brand consistency, legal/policy review checks rights and unsafe content, and only approved assets are copied into the production repository or engine surface. (source: `resources/assetgen.workflow.md`)

Assets move through explicit lifecycle states: `briefed`, `generated`, `qa_pending`, `cleanup_required`, `review_pending`, `approved`, `integrated`, or `rejected`. Rejected assets are blocked from production at the QA, cleanup, or review gates. (source: `resources/assetgen.workflow.md`)

Metadata is required for traceability. The workflow records fields such as asset id/name/type, brief path, prompt template, final prompt, negative prompt, model and version, seed, generation date, creator, reviewer, source references, license status, usage rights, dimensions, export format, alpha type, transparency flag, QA/review status, approval date, embedded text status, and notes. (source: `resources/assetgen.workflow.md`)

Transparent assets have a dedicated alpha gate: they must include a functional alpha channel, be checked on white, black, gray, checkerboard, and in-game backgrounds, have halos/matte color/color spill/jagged edges/baked shadows removed, and document whether the final export uses straight or premultiplied alpha. (source: `resources/assetgen.workflow.md`)

Sprite and animation outputs have an additional QA expectation: frame dimensions, anchor points, scale, ordering, and contact-sheet or preview evidence must be stable before review. (source: `resources/assetgen.workflow.md`)

## Release Gate

An generated asset may enter production only when all of these are true:

- Status is `approved`.
- QA passed.
- Human review passed.
- License review passed.
- Metadata is complete and linked to the asset.
- Embedded text is absent or explicitly approved.
- Transparent assets passed alpha and halo checks. (source: `resources/assetgen.workflow.md`)

## Relationship To Existing Assets

The existing first-pass generated art under `resources/art/first_pass/` predates this documented process and is already tracked through pages such as [[main-menu-assets]]. Future generated asset batches should use this workflow as the durable process reference before moving final files into `resources/art/first_pass/`, `resources/visual/`, or another runtime resource path. (source: `resources/art/first_pass/`, `resources/visual/`, `wiki/main-menu-assets.md`, `resources/assetgen.workflow.md`)

## Related Pages

- [[main-menu-assets]]
- [[file-map]]
- [[features]]
