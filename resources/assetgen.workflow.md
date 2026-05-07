# AI-Generated 2D Asset Workflow

This is a Codex multi-agent workflow for producing generated 2D assets. Each
workflow layer is owned by a separate `worker` subagent with a clear handoff
between layers. The main/default agent coordinates scope, reviews outputs, and
records final status, but layer work should be delegated to workers.

All image creation or raster image editing in this workflow must use the Codex
`imagegen` skill. Use the built-in `image_gen` tool path described by that skill
unless the human explicitly asks for the skill's CLI fallback.

For sprite sheets, animation strips, or frame-normalized 2D animation exports,
use the available `game-studio:sprite-pipeline` skill after image candidates
exist. This skill is for sprite normalization, contact sheets, anchors, scale,
animation strip assembly, and preview packaging; it does not replace the
`imagegen` requirement for creating or editing generated image candidates.

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

Produce, verify, clean, and export assets.

1. Generate multiple candidates from approved briefs and prompt templates.
2. Save source prompt, model, seed, date, references, and generation settings.
3. Run QA for style match, dimensions, readability, defects, transparency, and policy constraints.
4. Clean alpha edges, halos, color spill, and baked shadows before approval.
5. For sprite sheets or animation strips, run `game-studio:sprite-pipeline` to normalize frame size, anchor points, padding, scale, contact sheets, and preview outputs.
6. Export final assets in required formats, sizes, and naming convention.

## Layer 3: Governance & Integration

**Worker ownership:** assign a separate worker subagent to run the governance
and integration checklist after Layer 2 finishes. This worker verifies review
status, metadata, policy/license state, and production integration readiness.

Only reviewed and approved assets enter production.

- Human reviewer checks style, gameplay fit, readability, and brand consistency.
- Legal/policy review checks license, source rights, likeness, trademarks, unsafe content, and embedded text.
- Approved assets are integrated into the engine or production repository.
- Unapproved, rejected, or incomplete assets are blocked from production builds.

## Asset Lifecycle

```text
briefed -> generated -> qa_pending -> cleanup_required -> review_pending -> approved -> integrated
                         |                  |                 |
                         v                  v                 v
                      rejected          rejected          rejected
```

## Status Flow

| Status | Meaning |
|---|---|
| `briefed` | Asset brief approved for generation. |
| `generated` | Candidate images created and metadata saved. |
| `qa_pending` | Waiting for automated/manual QA. |
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
