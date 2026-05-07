# Asset Workspace

This folder implements the governed assetgen workflow for Orbwalker production asset preparation.

Runtime integration is blocked until QA, human review, legal/license review, metadata completion, and explicit integration approval are complete.

Current layers:
- `art_bible/`: creative-control source of truth.
- `briefs/`: one brief per asset inventory id.
- `prompts/`: reusable generation prompt templates and future prompt runs.
- `generated/`: candidate image and metadata area.
- `qa/`: QA reports, transparency checks, approval gates.
- `approved/`: human-approved assets only.
- `rejected/`: rejected candidate records.
- `integrated/`: runtime integration prep only until approved.
