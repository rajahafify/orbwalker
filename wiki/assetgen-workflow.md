# Assetgen Workflow

**Summary**: Governance workflow for AI-generated 2D assets before they are integrated into the game.

**Sources**: `resources/assetgen.workflow.md`

**Last updated**: 2026-05-08

---

## Overview

`resources/assetgen.workflow.md` defines the review and production process for generated 2D assets. It is a Codex multi-agent workflow, not a runtime asset loader or Godot integration script. The workflow keeps creative direction, generation metadata, QA, cleanup, human review, legal review, and final engine integration as separate gates. Each layer is owned by a separate `worker` subagent, while the main/default agent coordinates scope, reviews outputs, and records final status. Current mode is `bulk_generation_first`: generate candidates for the full `assets.json` list first, defer QA as one later batch, and keep legal/license/final approval/runtime integration blocked until that batch and follow-up review are complete. The optional per-wave routing manifest is `assets/generated/metadata/bulk_generation_plan.json`. (source: `resources/assetgen.workflow.md`, `assets/generated/metadata/bulk_generation_plan.json`)

## Details

The proposed asset workspace is organized under an `assets/` folder with separate areas for the art bible, asset briefs, prompt templates and run records, generated candidates and metadata, QA reports, transparency tests, cleanup outputs, approved assets, rejected assets, and engine-integrated copies. This folder structure is not yet the same as the existing `resources/art/first_pass/` runtime art package. (source: `resources/assetgen.workflow.md`, `resources/art/first_pass/`)

The workflow has three layers:

- Creative control: the art bible, asset briefs, prompt templates, style rules, palette rules, transparency requirements, and negative constraints define what may be generated.
- Asset production: candidates are generated from approved briefs for all image-capable records in the current `assets.json` wave first, generation settings are recorded, sprite normalization runs after image candidates exist, and QA/cleanup are deferred into one later batch. All generated image candidate creation or editing must use the Codex `imagegen` skill: read the skill instructions, then call the Codex-provided in-chat image generation tool from the agent tool interface. Do not run `image_gen`, `imagegen`, or similar names in PowerShell/Bash/CLI; those are not shell executables for this workflow. Sprite sheets, animation strips, and frame-normalized animation exports should use the available `game-studio:sprite-pipeline` skill after image candidates exist, for frame sizing, anchors, scale normalization, contact sheets, and preview packaging.
- Governance and integration: in `bulk_generation_first`, this layer stays blocked while QA is deferred. Human review checks gameplay fit and brand consistency, legal/policy review checks rights and unsafe content, and only approved assets are copied into the production repository or engine surface after deferred QA and review gates reopen. (source: `resources/assetgen.workflow.md`)

Audio, screenshot, and video assets are not imagegen outputs; they require non-image capture/audio tooling or explicit spec placeholders until that tooling is requested. (source: `resources/assetgen.workflow.md`)

Assets move through explicit lifecycle states: `briefed`, `generated_bulk_pending_qa`, `qa_pending_batch`, `cleanup_required`, `review_pending`, `approved`, `integrated`, or `rejected`. Rejected assets are blocked from production at the QA, cleanup, or review gates. (source: `resources/assetgen.workflow.md`)

Metadata is required for traceability. The workflow records fields such as asset id/name/type, brief path, prompt template, final prompt, negative prompt, model and version, seed, generation date, creator, reviewer, source references, license status, usage rights, dimensions, export format, alpha type, transparency flag, QA/review status, approval date, embedded text status, and notes. (source: `resources/assetgen.workflow.md`)

Transparent assets have a dedicated alpha gate: they must include a functional alpha channel, be checked on white, black, gray, checkerboard, and in-game backgrounds, have halos/matte color/color spill/jagged edges/baked shadows removed, and document whether the final export uses straight or premultiplied alpha. (source: `resources/assetgen.workflow.md`)

Sprite and animation outputs have an additional QA expectation: frame dimensions, anchor points, scale, ordering, and contact-sheet or preview evidence must be stable before review. (source: `resources/assetgen.workflow.md`)

## Release Gate

A generated asset may enter production only when all of these are true:

- Status is `approved`.
- QA passed.
- Human review passed.
- License review passed.
- Metadata is complete and linked to the asset.
- Embedded text is absent or explicitly approved.
- Transparent assets passed alpha and halo checks. (source: `resources/assetgen.workflow.md`)

Under `bulk_generation_first`, legal/license clearance, final approval, and runtime integration remain blocked until the deferred QA batch has completed and review outcomes are recorded. (source: `resources/assetgen.workflow.md`)

## Current Bulk Generation Status

As of the 2026-05-08 deferred transparency QA documentation pass, the root production inventory still contains 53 asset records and the bulk plan routes 38 records through image generation. Candidate PNGs and per-record metadata are present for all 38 image-generation records. Deferred transparency QA evidence from `assets/qa/transparency_tests/transparency_probe_current.json` shows most alpha-sensitive bulk candidates are RGB/no real alpha: 21 alpha-sensitive asset records are now marked `cleanup_required`, and only the cleanup treasure chest candidate (`assets/cleanup/treasure_chest_icons_candidate_03_alpha_cleanup.png`) currently reports real alpha in probe output. Sprite-source sheets (`hero_animation_set`, `enemy_animation_set`) are explicitly blocked and deferred to sprite-pipeline normalization/cleanup for alpha extraction. Opaque/background and other non-alpha-sensitive candidates are not failed solely for missing alpha in this pass. The aggregate metadata, QA status manifest, and approval status manifest are synced from per-record metadata, and runtime integration remains blocked pending cleanup, QA follow-up, and downstream review gates. (source: `assets/generated/metadata/assets.json`, `assets/generated/metadata/records/hero_animation_set.json`, `assets/generated/metadata/records/enemy_animation_set.json`, `assets/generated/metadata/records/treasure_chest_icons.json`, `assets/qa/reports/bulk_transparency_qa.md`, `assets/qa/reports/qa_status_manifest.json`, `assets/approved/status_manifest.json`)

## Relationship To Existing Assets

The existing first-pass generated art under `resources/art/first_pass/` predates this documented process and is already tracked through pages such as [[main-menu-assets]]. Future generated asset batches should use this workflow as the durable process reference before moving final files into `resources/art/first_pass/`, `resources/visual/`, or another runtime resource path. (source: `resources/art/first_pass/`, `resources/visual/`, `wiki/main-menu-assets.md`, `resources/assetgen.workflow.md`)

## Related Pages

- [[main-menu-assets]]
- [[file-map]]
- [[features]]
