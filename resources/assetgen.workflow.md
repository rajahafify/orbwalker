# AI-Generated 2D Asset Workflow

This is a Codex multi-agent workflow for producing generated 2D assets. Each
workflow layer is owned by a separate `worker` subagent with a clear handoff
between layers. The main/default agent coordinates scope, reviews outputs, and
records final status, but layer work should be delegated to workers.

Current execution mode is `bulk_generation_first`: generate candidates for the
full planned asset list first, then run QA as one deferred batch. Legal/license
review, final approval, and runtime integration remain blocked until that later
QA/review pass is complete.

All image creation or raster image editing in this workflow must use the Codex
`imagegen` skill. Use the built-in `image_gen` tool path described by that skill
unless the human explicitly asks for the skill's CLI fallback.

For sprite sheets, animation strips, or frame-normalized 2D animation exports,
use the available `game-studio:sprite-pipeline` skill after image candidates
exist. This skill is for sprite normalization, contact sheets, anchors, scale,
animation strip assembly, and preview packaging; it does not replace the
`imagegen` requirement for creating or editing generated image candidates.

Audio, screenshot, and video assets are not generated via `imagegen`. They must
use non-image capture/audio tooling, or remain as explicit spec placeholders
until such tooling is requested.

## Folder Structure

```text
assets/
  art_bible/
    style.md
    palettes/
    references/
  briefs/
    asset_name.brief.md
  prompts/
    templates.md
    runs/
  generated/
    candidates/
    metadata/
  qa/
    reports/
    transparency_tests/
  cleanup/
    alpha_fixed/
  approved/
    sprites/
    ui/
    icons/
  rejected/
  integrated/
    game_engine/
```

## Bulk-Generation-First Mode

Use this mode when the request is to maximize candidate throughput before QA.

1. Load the candidate list from `assets.json` and the generated-record mirror at
   `assets/generated/metadata/assets.json`.
   If present, use `assets/generated/metadata/bulk_generation_plan.json` as the
   per-wave routing manifest.
2. Generate image candidates for all image-capable entries first.
3. Defer QA to one later batch across the whole wave.
4. Keep legal/license review, final approval, and runtime integration blocked
   until deferred QA is finished and reviewed.
5. For audio/screenshot/video entries, record non-image tooling requirements or
   placeholder specs; do not force them into image generation.

## Layer 1: Creative Control

**Worker ownership:** assign one worker subagent to prepare and validate the
creative-control inputs for the asset batch.

Maintain a single source of truth before production begins.

- **Art bible:** style, palette, lighting, camera angle, shape language, line weight, scale, allowed effects, prohibited motifs.
- **Asset briefs:** asset name, purpose, dimensions, game context, references, animation needs, export format, transparency requirement.
- **Prompt templates:** reusable prompt structure with variables for asset type, pose, material, mood, style, background, negative constraints.
- **Style and transparency rules:** transparent background required where applicable; no baked shadows, halos, unwanted glow, or unapproved text.

## Layer 2: Asset Production

**Worker ownership:** assign a separate worker subagent to generate, QA, clean,
and export candidates from the approved Layer 1 inputs. This worker must use the
Codex `imagegen` skill for all generated raster asset creation or editing.

Produce candidates first, then QA later as one batch in this mode.

1. Generate candidates from approved briefs and prompt templates for every
   image-capable record in the current `assets.json` list.
2. Save source prompt, model, seed, date, references, and generation settings.
3. After image candidates exist, run `game-studio:sprite-pipeline` for sprite
   sheets/animation strips that need frame normalization, anchors, padding,
   scale, contact sheets, and preview outputs.
4. Defer QA checks (style, dimensions, readability, defects, transparency, and
   policy constraints) into one later batch pass.
5. Defer cleanup (alpha edges, halos, color spill, baked shadows) into that QA
   batch unless a blocker must be fixed to continue generation.
6. Keep outputs in generated/metadata + candidate form until QA/review gates
   are explicitly reopened.

For non-image assets (audio, screenshot, video), record one of:

- tooling-needed entries for capture/audio pipelines, or
- spec placeholder deliverables if tooling is not yet requested.

## Layer 3: Governance & Integration

**Worker ownership:** assign a separate worker subagent to run the governance
and integration checklist after Layer 2 finishes. This worker verifies review
status, metadata, policy/license state, and production integration readiness.

Only reviewed and approved assets enter production. In
`bulk_generation_first` mode, this entire layer stays blocked until the deferred
QA batch is complete.

- Human reviewer checks style, gameplay fit, readability, and brand consistency.
- Legal/policy review checks license, source rights, likeness, trademarks, unsafe content, and embedded text.
- Approved assets are integrated into the engine or production repository.
- Unapproved, rejected, or incomplete assets are blocked from production builds.

## Asset Lifecycle

```text
briefed -> generated_bulk_pending_qa -> qa_pending_batch -> cleanup_required -> review_pending -> approved -> integrated
                                 |                  |                 |
                                 v                  v                 v
                              rejected          rejected          rejected
```

## Status Flow

| Status | Meaning |
|---|---|
| `briefed` | Asset brief approved for generation. |
| `generated_bulk_pending_qa` | Candidate generation complete for this record while batch QA is deferred. |
| `qa_pending_batch` | Waiting for the deferred one-pass QA batch. |
| `cleanup_required` | Needs alpha, halo, artifact, or style fixes. |
| `review_pending` | Passed QA and awaiting human/legal review. |
| `approved` | Cleared for production use. |
| `integrated` | Added to game/project build. |
| `rejected` | Blocked from production. |

## Metadata Fields

```yaml
asset_id:
asset_name:
asset_type:
brief_path:
prompt_template:
final_prompt:
negative_prompt:
model:
model_version:
seed:
generation_date:
creator:
reviewer:
source_references:
license_status:
usage_rights:
dimensions:
export_format:
alpha_type: straight | premultiplied
transparent_background: true | false
qa_status:
review_status:
approval_date:
embedded_text: none | approved | rejected
notes:
```

## Transparency Checks

Transparent assets must pass all checks before approval.

- Alpha channel is present and functional.
- Asset is tested on white, black, gray, checkerboard, and in-game background.
- Halos, matte color, color spill, jagged alpha, and baked shadows are detected and removed.
- Straight or premultiplied alpha is documented in metadata.
- Alpha edges are cleaned before approval.

## QA Rules

- Matches art bible, palette, silhouette, scale, and intended use.
- Meets required dimensions, padding, safe area, and export format.
- Sprite sheets and animation strips have stable frame dimensions, anchors, scale, ordering, and preview/contact-sheet evidence.
- No visible artifacts, warped geometry, broken outlines, unwanted blur, or compression damage.
- No embedded text unless explicitly approved.
- No unlicensed references, trademarks, likeness issues, or restricted content.
- Metadata is complete and linked to the asset file.

## Release Gate

An asset may enter production only when all conditions are true:

- `status = approved`
- QA passed
- Human reviewed
- License checked
- Metadata complete
- No embedded text unless approved
- Transparent assets passed alpha and halo checks

Under `bulk_generation_first`, all assets remain blocked from legal/license
clearance, final approval, and runtime integration until deferred QA batch
completion and follow-up review are explicitly recorded.
