# QA Report: treasure_chest_icons

Candidate paths:
- assets/generated/candidates/wave-01-public-demo-core/treasure_chest_icons_candidate_01.png
- assets/generated/candidates/wave-01-public-demo-core/treasure_chest_icons_candidate_02.png
- assets/generated/candidates/wave-01-public-demo-core/treasure_chest_icons_candidate_03.png
- assets/cleanup/treasure_chest_icons_candidate_03_alpha_cleanup.png
Metadata path: assets/generated/metadata/records/treasure_chest_icons.json
Brief path: assets/briefs/wave-01-public-demo-core/treasure_chest_icons.brief.md
Status: qa_pending_alpha_cleanup_created

## Initial Automated Checks

- Candidate file exists: yes
- Dimensions recorded: 1254x1254 for all four current files
- Runtime integration status: blocked_pending_approval
- Human visual review: pending
- Legal/license/source review: pending
- Embedded text check: no text visible in current candidates; still pending human visual review
- Transparency/alpha check: generated candidates failed; cleanup candidate passes basic alpha probe

## Alpha Findings

- candidate_01: failed. PowerShell/System.Drawing probe reports `Format24bppRgb`, sampled alpha values `255`, corner alpha `255,255,255,255`; visual inspection shows an opaque gray background.
- candidate_02: failed. PowerShell/System.Drawing probe reports `Format24bppRgb`, sampled alpha values `255`, corner alpha `255,255,255,255`; generated file has no alpha channel.
- candidate_03: failed as generated. PowerShell/System.Drawing probe reports `Format24bppRgb`, sampled alpha values `255`, corner alpha `255,255,255,255`; visual inspection shows baked checkerboard pixels.
- candidate_03_alpha_cleanup: basic alpha probe passed. PowerShell/System.Drawing probe reports `Format32bppArgb`, sampled alpha values `0,255`, corner alpha `0,0,0,0`.

## Cleanup Notes

The cleanup file was derived from candidate_03 by removing only edge-connected checkerboard-like background pixels. This makes it suitable for the next visual QA pass, but it is not approved and must still be checked over white, black, gray, checkerboard, and representative game backgrounds.

Generated and cleaned as Wave 1 review candidates only. Do not copy into runtime resource paths until the full approval gate passes.
