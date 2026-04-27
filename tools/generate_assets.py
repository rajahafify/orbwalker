#!/usr/bin/env python3
from __future__ import annotations

import json
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Sequence, Tuple

from PIL import Image, ImageChops, ImageDraw, ImageFilter


Color = Tuple[int, int, int, int]


@dataclass(frozen=True)
class AssetSpec:
    category: str
    name: str
    variant: str
    size: Tuple[int, int]
    intended_use: str
    default_display_size: Tuple[int, int]

    @property
    def filename(self) -> str:
        return f"{self.category}_{self.name}_{self.variant}_v01.png"


REQUIRED_SPECS: List[AssetSpec] = [
    # Orbs
    *[
        AssetSpec("orb", orb_name, variant, (512, 512), f"{orb_name} orb ({variant})", (128, 128))
        for orb_name in ("fire", "ice", "earth", "heart", "armor", "gold")
        for variant in ("normal", "selected", "matched_glow")
    ],
    # Icons
    AssetSpec("icon", "attack_sword", "normal", (512, 512), "Attack icon", (96, 96)),
    AssetSpec("icon", "block_shield", "normal", (512, 512), "Block icon", (96, 96)),
    AssetSpec("icon", "hp_heart", "normal", (512, 512), "HP icon", (96, 96)),
    AssetSpec("icon", "coin_gold", "normal", (512, 512), "Gold icon", (96, 96)),
    AssetSpec("icon", "timer_hourglass", "normal", (512, 512), "Timer icon", (96, 96)),
    AssetSpec("icon", "combo_badge", "normal", (512, 512), "Combo badge icon", (128, 128)),
    # UI
    AssetSpec("ui", "panel_frame", "normal", (1024, 320), "Main panel frame (9-slice ready)", (1024, 320)),
    AssetSpec("ui", "button_frame", "normal", (1024, 256), "Button frame (9-slice ready)", (360, 90)),
    AssetSpec("ui", "hp_bar_frame", "normal", (1024, 160), "HP bar frame", (600, 56)),
    AssetSpec("ui", "hp_bar_fill", "normal", (1024, 160), "HP bar fill strip", (600, 40)),
    AssetSpec("ui", "timer_bar_frame", "normal", (1024, 160), "Timer bar frame", (600, 56)),
    AssetSpec("ui", "timer_bar_fill", "normal", (1024, 160), "Timer bar fill strip", (600, 40)),
    AssetSpec("ui", "inventory_slot_frame", "normal", (1024, 1024), "Inventory slot frame", (128, 128)),
    # Characters
    AssetSpec(
        "character",
        "enemy_dreadknight_cutout",
        "normal",
        (1200, 1800),
        "Enemy full-body cutout",
        (700, 1050),
    ),
    AssetSpec(
        "character",
        "enemy_dreadknight_portrait_badge",
        "normal",
        (512, 512),
        "Enemy portrait badge",
        (120, 120),
    ),
    AssetSpec(
        "character",
        "enemy_dreadknight_hit_flash_overlay",
        "normal",
        (1200, 1800),
        "Enemy hit-flash overlay",
        (700, 1050),
    ),
    # FX
    AssetSpec("fx", "hand_cursor", "normal", (512, 512), "Hand cursor for drag interactions", (72, 72)),
    AssetSpec("fx", "drag_path_glow_node", "normal", (512, 512), "Glow node for drag path", (42, 42)),
]


def clamp(v: int) -> int:
    return max(0, min(255, v))


def hex_to_rgba(code: str, alpha: int = 255) -> Color:
    code = code.lstrip("#")
    return (int(code[0:2], 16), int(code[2:4], 16), int(code[4:6], 16), alpha)


def blend(c1: Color, c2: Color, t: float) -> Color:
    t = max(0.0, min(1.0, t))
    return (
        clamp(int(c1[0] * (1 - t) + c2[0] * t)),
        clamp(int(c1[1] * (1 - t) + c2[1] * t)),
        clamp(int(c1[2] * (1 - t) + c2[2] * t)),
        clamp(int(c1[3] * (1 - t) + c2[3] * t)),
    )


def load_reference_palette(reference_path: Path) -> Dict[str, Color]:
    default = {
        "bg_dark": hex_to_rgba("#0E0A18"),
        "metal_dark": hex_to_rgba("#2B253B"),
        "metal_light": hex_to_rgba("#A88945"),
        "purple_glow": hex_to_rgba("#7D39D6"),
        "accent_red": hex_to_rgba("#C32A2A"),
        "accent_blue": hex_to_rgba("#2788D5"),
    }
    if not reference_path.exists():
        return default

    img = Image.open(reference_path).convert("RGBA")
    small = img.resize((256, 256))
    pal = small.convert("P", palette=Image.Palette.ADAPTIVE, colors=12).getpalette()
    counts = small.convert("P", palette=Image.Palette.ADAPTIVE, colors=12).getcolors()
    if not counts or not pal:
        return default

    ranked = sorted(counts, reverse=True)
    colors: List[Tuple[int, int, int]] = []
    for _, idx in ranked[:8]:
        base = idx * 3
        colors.append((pal[base], pal[base + 1], pal[base + 2]))

    if not colors:
        return default

    def pick(offset: int) -> Color:
        c = colors[min(offset, len(colors) - 1)]
        return (c[0], c[1], c[2], 255)

    return {
        "bg_dark": blend(default["bg_dark"], pick(0), 0.45),
        "metal_dark": blend(default["metal_dark"], pick(1), 0.35),
        "metal_light": blend(default["metal_light"], pick(2), 0.30),
        "purple_glow": blend(default["purple_glow"], pick(3), 0.35),
        "accent_red": blend(default["accent_red"], pick(4), 0.35),
        "accent_blue": blend(default["accent_blue"], pick(5), 0.35),
    }


ORB_BASE = {
    "fire": (hex_to_rgba("#C32911"), hex_to_rgba("#FF9B2C")),
    "ice": (hex_to_rgba("#1568C6"), hex_to_rgba("#78D7FF")),
    "earth": (hex_to_rgba("#3B8B2B"), hex_to_rgba("#B8EC5B")),
    "heart": (hex_to_rgba("#B21E83"), hex_to_rgba("#FF84D4")),
    "armor": (hex_to_rgba("#5A6475"), hex_to_rgba("#D8E2F0")),
    "gold": (hex_to_rgba("#B57A17"), hex_to_rgba("#FFD96A")),
}


def radial_gradient(size: Tuple[int, int], c_inner: Color, c_outer: Color, alpha_scale: float = 1.0) -> Image.Image:
    w, h = size
    cx, cy = w / 2.0, h / 2.0
    max_r = min(w, h) / 2.0
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            r = math.dist((x, y), (cx, cy)) / max_r
            t = min(1.0, r)
            c = blend(c_inner, c_outer, t)
            px[x, y] = (c[0], c[1], c[2], clamp(int(c[3] * alpha_scale)))
    return img


def draw_orb(spec: AssetSpec) -> Image.Image:
    base_name = spec.name
    inner, outer = ORB_BASE[base_name]
    img = Image.new("RGBA", spec.size, (0, 0, 0, 0))
    glow = radial_gradient(spec.size, (*inner[:3], 180), (0, 0, 0, 0), 1.0)
    img.alpha_composite(glow)

    draw = ImageDraw.Draw(img, "RGBA")
    w, h = spec.size
    cx, cy = w // 2, h // 2
    r = min(w, h) // 2 - 34

    orb_surface = radial_gradient((2 * r, 2 * r), (*outer[:3], 255), (*inner[:3], 255))
    mask = Image.new("L", (2 * r, 2 * r), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, 2 * r - 1, 2 * r - 1), fill=255)
    orb_layer = Image.new("RGBA", spec.size, (0, 0, 0, 0))
    orb_layer.paste(orb_surface, (cx - r, cy - r), mask)
    img.alpha_composite(orb_layer)

    ring_color = blend(outer, hex_to_rgba("#FFFFFF"), 0.35)
    draw.ellipse((cx - r - 8, cy - r - 8, cx + r + 8, cy + r + 8), outline=ring_color, width=10)

    highlight = Image.new("RGBA", spec.size, (0, 0, 0, 0))
    hd = ImageDraw.Draw(highlight, "RGBA")
    hd.ellipse((cx - int(r * 0.7), cy - int(r * 0.85), cx + int(r * 0.3), cy - int(r * 0.1)), fill=(255, 255, 255, 75))
    img.alpha_composite(highlight.filter(ImageFilter.GaussianBlur(5)))

    if spec.variant == "selected":
        draw.ellipse((cx - r - 20, cy - r - 20, cx + r + 20, cy + r + 20), outline=(255, 227, 120, 255), width=12)
    elif spec.variant == "matched_glow":
        aura = radial_gradient(spec.size, (255, 235, 180, 180), (255, 255, 255, 0), 1.0)
        img.alpha_composite(aura.filter(ImageFilter.GaussianBlur(3)))
        draw.ellipse((cx - r - 24, cy - r - 24, cx + r + 24, cy + r + 24), outline=(255, 248, 194, 255), width=14)

    return img


def draw_icon(spec: AssetSpec, palette: Dict[str, Color]) -> Image.Image:
    img = Image.new("RGBA", spec.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img, "RGBA")
    w, h = spec.size
    center = (w // 2, h // 2)

    if spec.name == "attack_sword":
        blade = [(center[0] - 30, 80), (center[0] + 30, 80), (center[0] + 8, 360), (center[0] - 8, 360)]
        draw.polygon(blade, fill=(214, 219, 230, 255), outline=(80, 80, 95, 255))
        draw.rectangle((center[0] - 60, 340, center[0] + 60, 390), fill=(130, 90, 30, 255))
        draw.rectangle((center[0] - 20, 390, center[0] + 20, 470), fill=(80, 50, 28, 255))
    elif spec.name == "block_shield":
        shield = [(center[0], 58), (130, 170), (165, 340), (center[0], 465), (347, 340), (382, 170)]
        draw.polygon(shield, fill=(115, 130, 155, 255), outline=(220, 232, 248, 255), width=8)
        draw.line((center[0], 90, center[0], 430), fill=(220, 232, 248, 190), width=6)
    elif spec.name == "hp_heart":
        draw.pieslice((90, 90, 260, 260), 180, 360, fill=(225, 40, 120, 255))
        draw.pieslice((252, 90, 422, 260), 180, 360, fill=(225, 40, 120, 255))
        draw.polygon([(85, 200), (427, 200), (256, 450)], fill=(225, 40, 120, 255))
        draw.polygon([(130, 220), (382, 220), (256, 400)], fill=(255, 135, 190, 220))
    elif spec.name == "coin_gold":
        draw.ellipse((70, 70, 442, 442), fill=(196, 140, 30, 255), outline=(255, 220, 114, 255), width=20)
        draw.ellipse((130, 130, 382, 382), outline=(255, 220, 130, 210), width=10)
        draw.rectangle((237, 145, 275, 365), fill=(255, 232, 150, 230))
    elif spec.name == "timer_hourglass":
        frame = palette["metal_light"]
        draw.rectangle((150, 70, 362, 110), fill=frame)
        draw.rectangle((150, 402, 362, 442), fill=frame)
        draw.polygon([(170, 100), (342, 100), (280, 250), (232, 250)], fill=(190, 170, 100, 255))
        draw.polygon([(232, 262), (280, 262), (342, 412), (170, 412)], fill=(190, 170, 100, 255))
        draw.rectangle((150, 95, 175, 418), fill=frame)
        draw.rectangle((337, 95, 362, 418), fill=frame)
    elif spec.name == "combo_badge":
        draw.rounded_rectangle((48, 90, 464, 420), radius=70, fill=(32, 20, 15, 240), outline=(240, 185, 68, 255), width=12)
        star = [(256, 140), (292, 230), (390, 236), (314, 300), (338, 396), (256, 344), (174, 396), (198, 300), (122, 236), (220, 230)]
        draw.polygon(star, fill=(255, 182, 67, 255))
    return img.filter(ImageFilter.GaussianBlur(0.2))


def draw_ui(spec: AssetSpec, palette: Dict[str, Color]) -> Image.Image:
    w, h = spec.size
    img = Image.new("RGBA", spec.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img, "RGBA")
    panel_dark = (*palette["metal_dark"][:3], 220)
    trim = (*palette["metal_light"][:3], 255)

    if "fill" in spec.name:
        if "hp" in spec.name:
            left, right = hex_to_rgba("#F06464"), hex_to_rgba("#B9192C")
        else:
            left, right = hex_to_rgba("#FFEA8A"), hex_to_rgba("#CB8D1E")
        strip = Image.new("RGBA", spec.size, (0, 0, 0, 0))
        sd = ImageDraw.Draw(strip, "RGBA")
        for x in range(w):
            c = blend(left, right, x / max(1, w - 1))
            sd.rectangle((x, int(h * 0.25), x, int(h * 0.75)), fill=c)
        sd.rounded_rectangle((10, int(h * 0.22), w - 10, int(h * 0.78)), radius=int(h * 0.2), outline=(255, 240, 190, 130), width=4)
        return strip

    draw.rounded_rectangle((8, 8, w - 8, h - 8), radius=max(24, h // 8), fill=panel_dark, outline=trim, width=8)
    draw.rounded_rectangle((20, 20, w - 20, h - 20), radius=max(20, h // 10), outline=(*palette["purple_glow"][:3], 120), width=3)

    if spec.name == "inventory_slot_frame":
        draw.rounded_rectangle((58, 58, w - 58, h - 58), radius=64, outline=(255, 232, 181, 180), width=10)
        draw.line((w * 0.15, h * 0.5, w * 0.85, h * 0.5), fill=(*palette["purple_glow"][:3], 90), width=8)

    return img


def draw_character(spec: AssetSpec, palette: Dict[str, Color]) -> Image.Image:
    img = Image.new("RGBA", spec.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img, "RGBA")

    if spec.name.endswith("hit_flash_overlay"):
        overlay = Image.new("RGBA", spec.size, (255, 255, 255, 0))
        od = ImageDraw.Draw(overlay, "RGBA")
        w, h = spec.size
        body = [
            (w * 0.28, h * 0.20),
            (w * 0.72, h * 0.20),
            (w * 0.82, h * 0.72),
            (w * 0.62, h * 0.95),
            (w * 0.38, h * 0.95),
            (w * 0.18, h * 0.72),
        ]
        od.polygon(body, fill=(255, 255, 255, 130))
        od.ellipse((w * 0.35, h * 0.04, w * 0.65, h * 0.28), fill=(255, 255, 255, 145))
        return overlay.filter(ImageFilter.GaussianBlur(8))

    if spec.name.endswith("portrait_badge"):
        w, h = spec.size
        badge = Image.new("RGBA", spec.size, (0, 0, 0, 0))
        bd = ImageDraw.Draw(badge, "RGBA")
        bd.ellipse((12, 12, w - 12, h - 12), fill=(25, 20, 35, 240), outline=palette["metal_light"], width=12)
        bd.ellipse((68, 68, w - 68, h - 68), fill=(45, 34, 68, 255), outline=(*palette["purple_glow"][:3], 170), width=6)
        bd.polygon([(w * 0.50, h * 0.17), (w * 0.38, h * 0.45), (w * 0.62, h * 0.45)], fill=(25, 20, 35, 255))
        bd.rectangle((w * 0.38, h * 0.45, w * 0.62, h * 0.75), fill=(32, 28, 48, 255))
        bd.ellipse((w * 0.42, h * 0.53, w * 0.49, h * 0.60), fill=(*palette["purple_glow"][:3], 255))
        bd.ellipse((w * 0.51, h * 0.53, w * 0.58, h * 0.60), fill=(*palette["purple_glow"][:3], 255))
        return badge

    # Full body cutout
    w, h = spec.size
    armor_dark = blend(palette["metal_dark"], hex_to_rgba("#111217"), 0.5)
    armor_light = blend(palette["metal_light"], hex_to_rgba("#D5D8E0"), 0.2)
    glow = palette["purple_glow"]

    body = [(w * 0.33, h * 0.25), (w * 0.67, h * 0.25), (w * 0.79, h * 0.76), (w * 0.62, h * 0.96), (w * 0.38, h * 0.96), (w * 0.21, h * 0.76)]
    draw.polygon(body, fill=armor_dark, outline=armor_light, width=10)
    draw.ellipse((w * 0.36, h * 0.06, w * 0.64, h * 0.30), fill=armor_dark, outline=armor_light, width=9)
    draw.polygon([(w * 0.44, h * 0.08), (w * 0.30, h * 0.03), (w * 0.41, h * 0.15)], fill=armor_light)
    draw.polygon([(w * 0.56, h * 0.08), (w * 0.70, h * 0.03), (w * 0.59, h * 0.15)], fill=armor_light)
    draw.rectangle((w * 0.25, h * 0.36, w * 0.35, h * 0.62), fill=armor_dark, outline=armor_light, width=8)
    draw.rectangle((w * 0.65, h * 0.36, w * 0.75, h * 0.62), fill=armor_dark, outline=armor_light, width=8)

    sword = [(w * 0.13, h * 0.25), (w * 0.20, h * 0.20), (w * 0.42, h * 0.72), (w * 0.35, h * 0.77)]
    draw.polygon(sword, fill=(188, 194, 212, 255), outline=(84, 90, 108, 255))
    draw.rectangle((w * 0.30, h * 0.72, w * 0.39, h * 0.76), fill=(88, 66, 30, 255))

    shield = [(w * 0.72, h * 0.36), (w * 0.88, h * 0.42), (w * 0.85, h * 0.71), (w * 0.72, h * 0.81), (w * 0.59, h * 0.71), (w * 0.56, h * 0.42)]
    draw.polygon(shield, fill=(66, 62, 88, 255), outline=armor_light, width=8)
    draw.ellipse((w * 0.45, h * 0.15, w * 0.49, h * 0.18), fill=(*glow[:3], 255))
    draw.ellipse((w * 0.51, h * 0.15, w * 0.55, h * 0.18), fill=(*glow[:3], 255))

    aura = radial_gradient(spec.size, (*glow[:3], 140), (0, 0, 0, 0), 1.0).filter(ImageFilter.GaussianBlur(18))
    return Image.alpha_composite(aura, img)


def draw_fx(spec: AssetSpec, palette: Dict[str, Color]) -> Image.Image:
    img = Image.new("RGBA", spec.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img, "RGBA")
    w, h = spec.size

    if spec.name == "hand_cursor":
        draw.polygon(
            [(w * 0.22, h * 0.17), (w * 0.42, h * 0.47), (w * 0.52, h * 0.41), (w * 0.36, h * 0.12)],
            fill=(230, 230, 230, 255),
            outline=(70, 70, 70, 255),
        )
        draw.rounded_rectangle((w * 0.35, h * 0.38, w * 0.72, h * 0.77), radius=36, fill=(222, 222, 222, 255), outline=(70, 70, 70, 255), width=6)
        draw.rounded_rectangle((w * 0.58, h * 0.25, w * 0.72, h * 0.55), radius=26, fill=(228, 228, 228, 255), outline=(70, 70, 70, 255), width=6)
    else:
        c = (*palette["purple_glow"][:3], 230)
        draw.ellipse((w * 0.18, h * 0.18, w * 0.82, h * 0.82), fill=(*c[:3], 80), outline=(255, 236, 172, 255), width=12)
        draw.ellipse((w * 0.34, h * 0.34, w * 0.66, h * 0.66), fill=(255, 232, 170, 225))
        img = img.filter(ImageFilter.GaussianBlur(1))
    return img


def dispatch_draw(spec: AssetSpec, palette: Dict[str, Color]) -> Image.Image:
    if spec.category == "orb":
        return draw_orb(spec)
    if spec.category == "icon":
        return draw_icon(spec, palette)
    if spec.category == "ui":
        return draw_ui(spec, palette)
    if spec.category == "character":
        return draw_character(spec, palette)
    if spec.category == "fx":
        return draw_fx(spec, palette)
    raise ValueError(f"Unknown category: {spec.category}")


def validate_png_has_alpha(path: Path) -> bool:
    with Image.open(path) as img:
        if "A" not in img.getbands():
            return False
        alpha = img.getchannel("A")
        lo, hi = alpha.getextrema()
        # Require transparency support (not fully opaque)
        return lo < 255 and hi > 0


def target_dir_for(category: str, root: Path) -> Path:
    mapping = {
        "ui": root / "assets" / "ui",
        "icon": root / "assets" / "icons",
        "orb": root / "assets" / "orbs",
        "character": root / "assets" / "characters",
        "fx": root / "assets" / "fx",
    }
    return mapping[category]


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    reference_path = Path("C:/Users/Home/Desktop/image-ref.png")
    palette = load_reference_palette(reference_path)

    # Ensure allowed folders exist.
    for folder in (
        root / "assets" / "ui",
        root / "assets" / "icons",
        root / "assets" / "orbs",
        root / "assets" / "characters",
        root / "assets" / "fx",
    ):
        folder.mkdir(parents=True, exist_ok=True)

    manifest_entries: List[Dict[str, object]] = []
    generated_paths: List[Path] = []
    for spec in REQUIRED_SPECS:
        out_dir = target_dir_for(spec.category, root)
        out_path = out_dir / spec.filename
        img = dispatch_draw(spec, palette)
        img.save(out_path, "PNG")
        generated_paths.append(out_path)
        manifest_entries.append(
            {
                "filename": str(out_path.relative_to(root)).replace("\\", "/"),
                "intended_use": spec.intended_use,
                "category": spec.category,
                "default_display_size": [spec.default_display_size[0], spec.default_display_size[1]],
            }
        )

    manifest_path = root / "assets" / "manifest.json"
    manifest = {
        "version": 1,
        "source_reference": str(reference_path).replace("\\", "/"),
        "naming_pattern": "<category>_<name>_<variant>_v01.png",
        "assets": manifest_entries,
    }
    manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    missing_files: List[str] = []
    alpha_failures: List[str] = []
    for spec in REQUIRED_SPECS:
        p = target_dir_for(spec.category, root) / spec.filename
        if not p.exists():
            missing_files.append(str(p.relative_to(root)).replace("\\", "/"))
            continue
        if not validate_png_has_alpha(p):
            alpha_failures.append(str(p.relative_to(root)).replace("\\", "/"))

    print(f"Generated assets: {len(generated_paths)}")
    print(f"Manifest: {manifest_path.relative_to(root)}")
    print(f"Missing required files: {len(missing_files)}")
    print(f"Alpha validation failures: {len(alpha_failures)}")
    if missing_files:
        print("Missing list:")
        for item in missing_files:
            print(f" - {item}")
    if alpha_failures:
        print("Alpha failure list:")
        for item in alpha_failures:
            print(f" - {item}")

    if missing_files or alpha_failures:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
