# AI-Generated 2D Asset Workflow

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

Maintain a single source of truth before production begins.

- **Art bible:** style, palette, lighting, camera angle, shape language, line weight, scale, allowed effects, prohibited motifs.
- **Asset briefs:** asset name, purpose, dimensions, game context, references, animation needs, export format, transparency requirement.
- **Prompt templates:** reusable prompt structure with variables for asset type, pose, material, mood, style, background, negative constraints.
- **Style and transparency rules:** transparent background required where applicable; no baked shadows, halos, unwanted glow, or unapproved text.

## Layer 2: Asset Production

Produce, verify, clean, and export assets.

1. Generate multiple candidates from approved briefs and prompt templates.
2. Save source prompt, model, seed, date, references, and generation settings.
3. Run QA for style match, dimensions, readability, defects, transparency, and policy constraints.
4. Clean alpha edges, halos, color spill, and baked shadows before approval.
5. Export final assets in required formats, sizes, and naming convention.

## Layer 3: Governance & Integration

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
