# Asset QA and transparency reports

Asset ID: qa_reports
Type: qa_report_set
Group: asset_pipeline_and_metadata - Asset Pipeline, Briefs, Metadata, And QA Records
Wave: wave-03-governance-foundation
Inventory status: missing

## Purpose

Prepare production candidate assets for Asset QA and transparency reports based on assets.json while preserving the assetgen approval workflow.

## Current References

- None recorded

## Requirements

- Follow assets/art_bible/style.md.
- Use the built-in imagegen path for image candidates when this is visual art.
- Audio entries are specification-only in this pass; do not generate or replace audio files.
- Do not overwrite resources/art/first_pass/ or any runtime path.
- Keep runtime integration blocked until QA, human review, legal/license review, and explicit approval pass.

## Technical Target

- Export format: PNG for visual candidates unless a later brief says otherwise.
- Transparent background: false unless generated as a cutout.
- Embedded text: none unless separately approved.
- Metadata record required: assets/generated/metadata/records/qa_reports.json.
- QA report target: assets/qa/reports/qa_reports.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: qa_report_set
Primary request: Create production candidate art for Asset QA and transparency reports in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
