#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
from collections import deque
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
ASSETGEN = ROOT / "resources" / "art" / "assetgen"
FIRST_PASS = ROOT / "resources" / "art" / "first_pass"
OUT_ROOT = ASSETGEN / "runtime"
CANVAS_ICON = 384
CANVAS_HERO = 512


ORB_RING_GRADES = {
    "fire": {
        "tint": (118, 10, 5),
        "strength": 0.78,
        "inner_radius": 0.70,
        "outer_radius": 1.03,
    },
    "ice": {
        "tint": (10, 42, 152),
        "strength": 0.68,
        "inner_radius": 0.70,
        "outer_radius": 1.03,
    },
    "armor": {
        "tint": (112, 120, 124),
        "strength": 0.30,
        "inner_radius": 0.70,
        "outer_radius": 1.03,
    },
}


SHEET_SPECS = {
    "orbs": {
        "source": ASSETGEN / "sheets" / "orb_icons_candidate_04_adaptive_alpha.png",
        "grid": (3, 2),
        "keys": ["fire", "ice", "earth", "heart", "armor", "gold"],
        "canvas": CANVAS_ICON,
        "padding": 10,
    },
    "mastery": {
        "source": ASSETGEN / "sheets" / "mastery_icons_candidate_04_adaptive_alpha.png",
        "grid": (3, 2),
        "keys": ["mastery_fire", "mastery_ice", "mastery_earth", "mastery_heart", "mastery_armor", "mastery_gold"],
        "canvas": CANVAS_ICON,
        "padding": 14,
    },
    "consumables": {
        "source": ASSETGEN / "sheets" / "consumable_icons_candidate_04_adaptive_alpha.png",
        "grid": (4, 2),
        "keys": [
            "consumable_fire_scroll",
            "consumable_ice_scroll",
            "consumable_earth_scroll",
            "consumable_heart_scroll",
            "consumable_armor_scroll",
            "consumable_gold_scroll",
            "consumable_reroll_scroll",
            "consumable_speed_scroll",
        ],
        "canvas": CANVAS_ICON,
        "padding": 14,
    },
    "treasure_chests": {
        "source": ASSETGEN / "sheets" / "treasure_chest_icons_candidate_04_adaptive_alpha.png",
        "grid": (2, 2),
        "keys": ["treasure_chest_elemental", "treasure_chest_fire", "treasure_chest_earth", "treasure_chest_shadow"],
        "canvas": CANVAS_ICON,
        "padding": 10,
    },
    "relics": {
        "source": ASSETGEN / "sheets" / "relic_icons_candidate_04_adaptive_alpha.png",
        "grid": (5, 1),
        "keys": [
            "relic_stalwart_mantle",
            "relic_golden_idol",
            "relic_crown_of_chains",
            "relic_merchant_compass",
            "relic_deep_pockets",
        ],
        "canvas": CANVAS_ICON,
        "padding": 12,
    },
    "equipment": {
        "source": ASSETGEN / "sheets" / "equipment_icons_candidate_04_adaptive_alpha.png",
        "grid": (5, 3),
        "keys": [
            "equipment_shortsword",
            "equipment_buckler",
            "equipment_coin_purse",
            "equipment_healing_charm",
            "equipment_leather_gloves",
            "equipment_twin_blades",
            "equipment_tower_shield",
            "equipment_merchant_scales",
            "equipment_ember_ring",
            "equipment_war_banner",
            "equipment_ruby_brooch",
            "equipment_champion_plate",
            "equipment_royal_seal",
            "equipment_mirror_charm",
            "equipment_battle_drum",
        ],
        "canvas": CANVAS_ICON,
        "padding": 12,
    },
}


ALIASES = {
    "equipment_stone_ring": "equipment_healing_charm",
    "equipment_frost_ring": "equipment_ember_ring",
    "equipment_combo_lens": "equipment_merchant_scales",
    "equipment_earthbreaker_maul": "equipment_shortsword",
    "equipment_hearth_amulet": "equipment_healing_charm",
    "equipment_alchemist_gloves": "equipment_leather_gloves",
    "equipment_training_manual": "equipment_royal_seal",
    "equipment_sapphire_brooch": "equipment_ruby_brooch",
    "equipment_emerald_brooch": "equipment_ruby_brooch",
}


ENEMY_ICON_SOURCES = {
    "enemy_striker": FIRST_PASS / "enemies" / "enemy_cavern_striker.png",
    "enemy_defender": FIRST_PASS / "enemies" / "enemy_cavern_defender.png",
    "enemy_charger": FIRST_PASS / "enemies" / "enemy_ruin_lancer.png",
    "enemy_cavern_striker": FIRST_PASS / "enemies" / "enemy_cavern_striker.png",
    "enemy_cavern_defender": FIRST_PASS / "enemies" / "enemy_cavern_defender.png",
    "enemy_ash_hunter": FIRST_PASS / "enemies" / "enemy_ash_hunter.png",
    "enemy_ruin_lancer": FIRST_PASS / "enemies" / "enemy_ruin_lancer.png",
    "enemy_vault_executioner": FIRST_PASS / "enemies" / "enemy_vault_executioner.png",
    "enemy_goldbound_keeper": FIRST_PASS / "enemies" / "enemy_goldbound_keeper.png",
    "boss_iron_gate": FIRST_PASS / "enemies" / "boss_iron_gate.png",
    "boss_burning_knight": FIRST_PASS / "enemies" / "boss_burning_knight.png",
    "boss_prism_warden": FIRST_PASS / "enemies" / "boss_prism_warden.png",
}


def rel_res(path: Path) -> str:
    return "res://" + path.relative_to(ROOT).as_posix()


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for block in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def save_png(image: Image.Image, path: Path) -> dict:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, "PNG", optimize=True)
    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    opaque = sum(1 for value in alpha.getdata() if value > 12)
    return {
        "path": rel_res(path),
        "size": list(image.size),
        "alpha_bbox": list(bbox) if bbox else None,
        "coverage": round(opaque / float(image.size[0] * image.size[1]), 4),
        "sha256": sha256(path),
    }


def is_visible(pixel: tuple[int, int, int, int]) -> bool:
    return pixel[3] > 12


def is_bright_neutral(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a <= 12:
        return False
    return max(r, g, b) - min(r, g, b) <= 34 and (r + g + b) / 3.0 >= 178


def clear_edge_connected_background(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    px = rgba.load()
    visited = bytearray(width * height)
    q: deque[tuple[int, int]] = deque()

    def enqueue(x: int, y: int) -> None:
        if x < 0 or y < 0 or x >= width or y >= height:
            return
        index = y * width + x
        if visited[index]:
            return
        visited[index] = 1
        if is_bright_neutral(px[x, y]):
            q.append((x, y))

    for edge_x in range(width):
        enqueue(edge_x, 0)
        enqueue(edge_x, height - 1)
    for edge_y in range(height):
        enqueue(0, edge_y)
        enqueue(width - 1, edge_y)

    while q:
        x, y = q.pop()
        r, g, b, _a = px[x, y]
        px[x, y] = (r, g, b, 0)
        enqueue(x + 1, y)
        enqueue(x - 1, y)
        enqueue(x, y + 1)
        enqueue(x, y - 1)
    return rgba


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").getbbox()


def drop_minor_components(image: Image.Image, min_ratio: float = 0.055) -> Image.Image:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    px = rgba.load()
    visited = bytearray(width * height)
    components: list[dict] = []

    for start_y in range(height):
        for start_x in range(width):
            start_index = start_y * width + start_x
            if visited[start_index]:
                continue
            visited[start_index] = 1
            if not is_visible(px[start_x, start_y]):
                continue
            stack = [(start_x, start_y)]
            points: list[tuple[int, int]] = []
            min_x = max_x = start_x
            min_y = max_y = start_y
            while stack:
                x, y = stack.pop()
                points.append((x, y))
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if nx < 0 or ny < 0 or nx >= width or ny >= height:
                        continue
                    index = ny * width + nx
                    if visited[index]:
                        continue
                    visited[index] = 1
                    if is_visible(px[nx, ny]):
                        stack.append((nx, ny))
            components.append({
                "points": points,
                "size": len(points),
                "bbox": (min_x, min_y, max_x + 1, max_y + 1),
            })

    if len(components) <= 1:
        return rgba
    max_size = max(component["size"] for component in components)
    if max_size <= 0:
        return rgba
    for component in components:
        size_ratio = component["size"] / float(max_size)
        min_x, min_y, max_x, max_y = component["bbox"]
        touches_edge = min_x <= 2 or min_y <= 2 or max_x >= width - 2 or max_y >= height - 2
        if component["size"] < max_size and touches_edge and size_ratio < 0.22:
            for x, y in component["points"]:
                r, g, b, _a = px[x, y]
                px[x, y] = (r, g, b, 0)
            continue
        if size_ratio >= min_ratio or (size_ratio >= min_ratio * 0.55 and not touches_edge):
            continue
        for x, y in component["points"]:
            r, g, b, _a = px[x, y]
            px[x, y] = (r, g, b, 0)
    return rgba


def trim_and_center(image: Image.Image, canvas: int, padding: int) -> Image.Image:
    rgba = drop_minor_components(image)
    bbox = alpha_bbox(rgba)
    if bbox is None:
        return Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    cropped = rgba.crop(bbox)
    src_w, src_h = cropped.size
    fit = max(16, canvas - padding * 2)
    scale = min(1.0, fit / float(max(src_w, src_h)))
    if scale < 1.0:
        cropped = cropped.resize((max(1, round(src_w * scale)), max(1, round(src_h * scale))), Image.Resampling.LANCZOS)
        src_w, src_h = cropped.size
    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    out.alpha_composite(cropped, ((canvas - src_w) // 2, (canvas - src_h) // 2))
    return out


def clamp_channel(value: float) -> int:
    return max(0, min(255, round(value)))


def apply_orb_ring_grade(image: Image.Image, key: str) -> tuple[Image.Image, str | None]:
    profile = ORB_RING_GRADES.get(key)
    if profile is None:
        return image, None

    graded = image.convert("RGBA")
    bbox = alpha_bbox(graded)
    if bbox is None:
        return graded, None

    min_x, min_y, max_x, max_y = bbox
    center_x = (min_x + max_x - 1) * 0.5
    center_y = (min_y + max_y - 1) * 0.5
    radius = max(max_x - min_x, max_y - min_y) * 0.5
    inner_radius = float(profile["inner_radius"])
    outer_radius = float(profile["outer_radius"])
    ring_width = max(0.001, outer_radius - inner_radius)
    tint_r, tint_g, tint_b = profile["tint"]
    strength = float(profile["strength"])
    pixels = graded.load()
    width, height = graded.size
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a <= 3:
                continue
            distance = (((x + 0.5 - center_x) ** 2.0 + (y + 0.5 - center_y) ** 2.0) ** 0.5) / radius
            if distance < inner_radius or distance > outer_radius:
                continue
            ring_progress = min(1.0, max(0.0, (distance - inner_radius) / ring_width))
            alpha_strength = strength * (0.35 + ring_progress * 0.65) * min(1.0, a / 255.0)
            pixels[x, y] = (
                clamp_channel(r * (1.0 - alpha_strength) + tint_r * alpha_strength),
                clamp_channel(g * (1.0 - alpha_strength) + tint_g * alpha_strength),
                clamp_channel(b * (1.0 - alpha_strength) + tint_b * alpha_strength),
                a,
            )
    return graded, key


def sheet_region(image: Image.Image, columns: int, rows: int, index: int) -> Image.Image:
    width, height = image.size
    column = index % columns
    row = index // columns
    x0 = round(width * column / columns)
    x1 = round(width * (column + 1) / columns)
    y0 = round(height * row / rows)
    y1 = round(height * (row + 1) / rows)
    return image.crop((x0, y0, x1, y1))


def add_alias(entries: dict, key: str, target_key: str) -> None:
    target = entries.get(target_key)
    if not target:
        return
    alias_entry = dict(target)
    alias_entry["alias_of"] = target_key
    entries[key] = alias_entry


def build_sheet_category(name: str, spec: dict, icon_entries: dict, manifest: dict) -> None:
    source = spec["source"]
    if not source.exists():
        manifest["warnings"].append(f"Missing source sheet for {name}: {source}")
        return
    with Image.open(source) as raw:
        sheet = raw.convert("RGBA")
        columns, rows = spec["grid"]
        category_entries: dict = {}
        for index, key in enumerate(spec["keys"]):
            region = sheet_region(sheet, columns, rows, index)
            runtime = trim_and_center(region, spec["canvas"], spec["padding"])
            ring_grade: str | None = None
            if name == "orbs":
                runtime, ring_grade = apply_orb_ring_grade(runtime, key)
            out_path = OUT_ROOT / name / f"{key}.png"
            entry = save_png(runtime, out_path)
            entry.update({"source": rel_res(source), "source_index": index, "source_grid": [columns, rows]})
            if ring_grade is not None:
                entry["ring_grade"] = ring_grade
            category_entries[key] = entry
            icon_entries[key] = entry
        manifest["categories"][name] = category_entries


def build_enemy_icons(icon_entries: dict, manifest: dict) -> None:
    entries: dict = {}
    for key, source in ENEMY_ICON_SOURCES.items():
        if not source.exists():
            manifest["warnings"].append(f"Missing enemy icon source for {key}: {source}")
            continue
        with Image.open(source) as raw:
            runtime = trim_and_center(raw.convert("RGBA"), CANVAS_ICON, 8)
        out_path = OUT_ROOT / "enemies" / f"{key}.png"
        entry = save_png(runtime, out_path)
        entry.update({"source": rel_res(source), "source_index": 0})
        entries[key] = entry
        icon_entries[key] = entry
    manifest["categories"]["enemies"] = entries


def build_hero(manifest: dict) -> None:
    source = ASSETGEN / "heroes" / "hero_orbwalker_portrait_candidate_01.png"
    fallback = FIRST_PASS / "heroes" / "hero_orbwalker.png"
    entries: dict = {}
    if source.exists():
        with Image.open(source) as raw:
            cleaned = clear_edge_connected_background(raw)
            runtime = trim_and_center(cleaned, CANVAS_HERO, 10)
        bbox = alpha_bbox(runtime)
        coverage = 0.0
        if bbox is not None:
            alpha = runtime.getchannel("A")
            coverage = sum(1 for value in alpha.getdata() if value > 12) / float(CANVAS_HERO * CANVAS_HERO)
        if bbox is not None and 0.08 <= coverage <= 0.88:
            out_path = OUT_ROOT / "heroes" / "hero_orbwalker.png"
            entry = save_png(runtime, out_path)
            entry.update({"source": rel_res(source), "source_index": 0, "background_removed": "edge_connected_bright_neutral"})
            entries["hero_orbwalker"] = entry
        else:
            manifest["warnings"].append("Hero cleanup coverage was invalid; falling back to first_pass hero.")
    if "hero_orbwalker" not in entries and fallback.exists():
        with Image.open(fallback) as raw:
            runtime = trim_and_center(raw.convert("RGBA"), CANVAS_HERO, 12)
        out_path = OUT_ROOT / "heroes" / "hero_orbwalker.png"
        entry = save_png(runtime, out_path)
        entry.update({"source": rel_res(fallback), "source_index": 0, "fallback": True})
        entries["hero_orbwalker"] = entry
    manifest["categories"]["heroes"] = entries


def write_contact_sheet(entries: Iterable[tuple[str, dict]], file_name: str, title: str) -> dict:
    items = list(entries)
    if not items:
        return {}
    tile = 160
    label_h = 28
    gap = 14
    cols = min(6, max(1, len(items)))
    rows = (len(items) + cols - 1) // cols
    canvas = Image.new("RGBA", (cols * tile + (cols + 1) * gap, rows * (tile + label_h) + (rows + 1) * gap), (20, 22, 28, 255))
    draw = ImageDraw.Draw(canvas)
    for index, (key, entry) in enumerate(items):
        path = ROOT / entry["path"].replace("res://", "")
        with Image.open(path) as raw:
            image = raw.convert("RGBA")
        image.thumbnail((tile, tile), Image.Resampling.LANCZOS)
        x = gap + (index % cols) * (tile + gap)
        y = gap + (index // cols) * (tile + label_h + gap)
        checker = Image.new("RGBA", (tile, tile), (32, 34, 42, 255))
        cd = ImageDraw.Draw(checker)
        for cy in range(0, tile, 16):
            for cx in range(0, tile, 16):
                if (cx // 16 + cy // 16) % 2 == 0:
                    cd.rectangle((cx, cy, cx + 15, cy + 15), fill=(58, 60, 70, 255))
        canvas.alpha_composite(checker, (x, y))
        canvas.alpha_composite(image, (x + (tile - image.width) // 2, y + (tile - image.height) // 2))
        draw.text((x, y + tile + 5), key[:24], fill=(230, 224, 208, 255))
    out_path = OUT_ROOT / "previews" / file_name
    return save_png(canvas, out_path) | {"title": title}


def update_existing_import_settings(manifest: dict) -> None:
    updated = 0
    checked = 0
    for import_path in OUT_ROOT.rglob("*.png.import"):
        checked += 1
        text = import_path.read_text(encoding="utf-8")
        revised = text.replace("mipmaps/generate=false", "mipmaps/generate=true")
        if revised != text:
            import_path.write_text(revised, encoding="utf-8")
            updated += 1
    manifest["import_settings"] = {
        "checked_png_imports": checked,
        "enabled_mipmaps": updated,
        "texture_filter": "linear_with_mipmaps",
    }


def main() -> None:
    OUT_ROOT.mkdir(parents=True, exist_ok=True)
    icon_entries: dict = {}
    manifest = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "runtime_root": rel_res(OUT_ROOT),
        "categories": {},
        "warnings": [],
    }
    for category_name in ["orbs", "mastery", "consumables", "treasure_chests", "relics", "equipment"]:
        build_sheet_category(category_name, SHEET_SPECS[category_name], icon_entries, manifest)
    for alias_key, target_key in ALIASES.items():
        add_alias(icon_entries, alias_key, target_key)
    build_enemy_icons(icon_entries, manifest)
    build_hero(manifest)
    manifest["categories"]["icons"] = dict(sorted(icon_entries.items()))
    manifest["previews"] = {
        "orbs": write_contact_sheet(manifest["categories"].get("orbs", {}).items(), "runtime_orbs_contact.png", "Runtime Orbs"),
        "icons": write_contact_sheet(manifest["categories"].get("icons", {}).items(), "runtime_icons_contact.png", "Runtime Icons"),
        "hero": write_contact_sheet(manifest["categories"].get("heroes", {}).items(), "runtime_hero_contact.png", "Runtime Hero"),
    }
    update_existing_import_settings(manifest)
    manifest_path = OUT_ROOT / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True), encoding="utf-8")
    print(f"runtime_manifest={manifest_path.relative_to(ROOT)}")
    print(f"runtime_icons={len(manifest['categories'].get('icons', {}))}")
    print(f"warnings={len(manifest['warnings'])}")


if __name__ == "__main__":
    main()
