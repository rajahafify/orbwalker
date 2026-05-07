# Assetgen Prompt Templates

Use the built-in imagegen path for generated bitmap image candidates. Do not use CLI fallback unless explicitly requested.

## Standard Image Candidate Prompt

Use case: stylized-concept
Asset type: <asset type and target surface>
Primary request: Create production candidate art for <asset name> in Orbwalker, a fantasy match-3 roguelike.
Scene/backdrop: <where it appears in game>
Subject: <main subject>
Style/medium: polished stylized 2D game art, crisp mobile-readable shapes.
Composition/framing: <dimensions, crop, padding, transparency needs>
Lighting/mood: dark fantasy with warm gold highlights and cool dungeon shadows.
Color palette: charcoal, steel, antique gold, and relevant elemental colors.
Materials/textures: carved stone, beveled metal, parchment, jewel-like orb magic where appropriate.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard.
Avoid: illegible silhouettes, overbusy detail, blurry edges, alpha halos, matte spill.

## UI Candidate Prompt

Use case: ui-mockup
Asset type: <UI surface or icon set>
Primary request: Create a mobile-readable fantasy UI candidate for <asset name>.
Constraints: preserve clear state readability; no readable text unless explicitly approved; transparent background when the asset is a UI element.

## Marketing Candidate Prompt

Use case: stylized-concept
Asset type: marketing art
Primary request: Create key art for Orbwalker showing a lone fantasy hero using elemental orbs in a dungeon roguelike run.
Constraints: leave safe space for page copy; no logo text unless separately approved.
