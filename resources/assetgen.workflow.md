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
`imagegen` skill. Read that skill's `SKILL.md` first, then call the available
in-chat image generation tool exposed to the agent by Codex. Do not try to run
`image_gen`, `imagegen`, or any similarly named command in PowerShell, Bash, or
another CLI; those names are not shell executables in this workflow. Use a CLI
fallback only when the human explicitly asks for the skill's CLI fallback and
the skill documentation provides one.

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
Codex `imagegen` skill for all generated raster asset creation or editing. The
worker should invoke the Codex-provided image generation tool from the agent
tool interface, not from the local shell.

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

### Chroma-Key Transparency Fallback

Use this fallback only when true-alpha image generation is unavailable or has
repeatedly produced fake transparency, such as baked checkerboard or fully
opaque PNGs. The fallback creates a temporary opaque source image with a flat
key color, then derives the final transparent PNG through deterministic key
extraction.

Rules:

1. Choose an asset-specific key color that is absent from the intended asset.
   Prefer highly saturated synthetic colors:
   - `#FF00FF` magenta for green, earth, heal, gold, silver, blue, and mixed
     icon sheets.
   - `#00FFFF` cyan for fire, red, orange, dark, and violet VFX sheets.
   - Do not use a key color that appears in the asset palette, glows, particles,
     seals, symbols, or highlights.
2. Prompt for a perfectly flat solid key background. The prompt must forbid
   gradients, checkerboards, texture, shadows, glow, smoke, particles, frames,
   panels, antialias blending into the background, and use of the key color
   inside the asset.
3. Save the keyed opaque source as a generated candidate and record the key
   color in prompt metadata.
4. Run deterministic keyed-alpha extraction into
   `assets/cleanup/chroma_keyed/` or another documented cleanup path. Exact key
   pixels become alpha 0; near-key edge pixels may become partial alpha only
   when they are background antialiasing.
5. Reject the output if the background is not flat, if the key color appears
   inside the asset body, if large matte rectangles remain, or if glow/particle
   edges are visibly clipped.
6. Promote only the extracted RGBA PNG, not the opaque keyed source, to active
   candidate paths. Metadata must state the source key color, extraction script
   or report, alpha status, and remaining review gates.

This fallback does not approve an asset. It only creates a real-alpha candidate
for deferred QA, human review, legal/license review, and integration gates.

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
