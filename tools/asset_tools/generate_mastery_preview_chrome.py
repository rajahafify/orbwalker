#!/usr/bin/env python3
from __future__ import annotations

import math
from pathlib import Path
from typing import Callable, Iterable

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
ICON_DIR = ROOT / "resources" / "art" / "first_pass" / "derived" / "icons"
CHROME_DIR = ROOT / "resources" / "art" / "first_pass" / "derived" / "ui_chrome"

CANVAS = 256
SCALE = 4
WORK = CANVAS * SCALE
PANEL_SIZE = (1048, 348)
CARD_SIZE = (320, 420)

RGBA = tuple[int, int, int, int]


PALETTES: dict[str, dict[str, RGBA]] = {
    "fire": {
        "core": (255, 86, 28, 255),
        "hot": (255, 222, 112, 255),
        "dark": (82, 10, 7, 255),
        "aura": (180, 28, 12, 255),
    },
    "ice": {
        "core": (78, 190, 255, 255),
        "hot": (225, 250, 255, 255),
        "dark": (17, 58, 112, 255),
        "aura": (24, 105, 186, 255),
    },
    "earth": {
        "core": (111, 214, 56, 255),
        "hot": (224, 255, 126, 255),
        "dark": (25, 72, 20, 255),
        "aura": (57, 130, 34, 255),
    },
    "heart": {
        "core": (243, 68, 138, 255),
        "hot": (255, 190, 220, 255),
        "dark": (104, 17, 62, 255),
        "aura": (170, 32, 104, 255),
    },
    "armor": {
        "core": (215, 224, 236, 255),
        "hot": (255, 255, 246, 255),
        "dark": (48, 55, 68, 255),
        "aura": (90, 114, 146, 255),
    },
    "gold": {
        "core": (255, 180, 40, 255),
        "hot": (255, 242, 132, 255),
        "dark": (105, 61, 8, 255),
        "aura": (190, 116, 14, 255),
    },
}

ORB_ORDER = ["fire", "ice", "earth", "heart", "armor", "gold"]
GOLD = (238, 188, 90, 255)
GOLD_HOT = (255, 236, 157, 255)
GOLD_DARK = (83, 48, 15, 255)


def clamp(value: float) -> int:
    return max(0, min(255, round(value)))


def blend(a: RGBA, b: RGBA, t: float) -> RGBA:
    t = max(0.0, min(1.0, t))
    return tuple(clamp(a[i] + (b[i] - a[i]) * t) for i in range(4))  # type: ignore[return-value]


def p(x: float, y: float) -> tuple[int, int]:
    return (round(x * WORK), round(y * WORK))


def scaled(points: Iterable[tuple[float, float]]) -> list[tuple[int, int]]:
    return [p(x, y) for x, y in points]


def vertical_gradient(size: tuple[int, int], top: RGBA, bottom: RGBA) -> Image.Image:
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    for y in range(size[1]):
        draw.line((0, y, size[0], y), fill=blend(top, bottom, y / max(1, size[1] - 1)))
    return image


def radial_alpha(size: tuple[int, int], center: tuple[float, float], radius: float, alpha: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    px = mask.load()
    cx, cy = center
    for y in range(size[1]):
        for x in range(size[0]):
            distance = math.hypot((x - cx) / radius, (y - cy) / radius)
            value = max(0.0, 1.0 - distance)
            px[x, y] = round((value * value) * alpha)
    return mask


def apply_alpha(image: Image.Image, alpha: Image.Image) -> Image.Image:
    out = image.copy()
    out.putalpha(alpha)
    return out


def blur_alpha(image: Image.Image, radius: float) -> Image.Image:
    return image.filter(ImageFilter.GaussianBlur(radius))


def rounded_mask(size: tuple[int, int], inset: int, radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask, "L")
    draw.rounded_rectangle((inset, inset, size[0] - inset - 1, size[1] - inset - 1), radius=radius, fill=255)
    return mask


def draw_panel_frame() -> Image.Image:
    width, height = PANEL_SIZE
    out = Image.new("RGBA", PANEL_SIZE, (0, 0, 0, 0))

    outer_mask = rounded_mask(PANEL_SIZE, 2, 28)
    body = vertical_gradient(PANEL_SIZE, (9, 18, 25, 244), (3, 7, 12, 244))
    out.alpha_composite(apply_alpha(body, outer_mask))

    ambience = Image.new("RGBA", PANEL_SIZE, (0, 0, 0, 0))
    amb = ImageDraw.Draw(ambience, "RGBA")
    amb.ellipse((120, 74, width - 120, height + 96), fill=(26, 42, 54, 86))
    amb.rectangle((48, 86, width - 48, height - 40), fill=(255, 206, 95, 16))
    out.alpha_composite(blur_alpha(ambience, 24.0))

    draw = ImageDraw.Draw(out, "RGBA")
    for inset, color, line_width, radius in [
        (3, GOLD_HOT, 4, 27),
        (9, GOLD_DARK, 3, 22),
        (14, (218, 160, 68, 210), 2, 18),
        (28, (188, 132, 52, 124), 2, 18),
    ]:
        draw.rounded_rectangle(
            (inset, inset, width - inset - 1, height - inset - 1),
            radius=radius,
            outline=color,
            width=line_width,
        )

    header_y = 44
    title_y = 74
    line_y = 94
    card_top = 126
    draw.line((76, line_y, 340, line_y), fill=(174, 112, 42, 180), width=2)
    draw.line((708, line_y, width - 76, line_y), fill=(174, 112, 42, 180), width=2)
    for x in (340, 708):
        draw.polygon([(x - 16, line_y), (x, line_y - 7), (x + 16, line_y), (x, line_y + 7)], fill=(231, 184, 86, 220))
        draw.polygon([(x - 8, line_y), (x, line_y - 13), (x + 8, line_y), (x, line_y + 13)], outline=GOLD_HOT, fill=(23, 17, 11, 255))
    draw.line((36, card_top - 11, width - 36, card_top - 11), fill=(229, 177, 77, 160), width=2)
    draw.line((36, height - 34, width - 36, height - 34), fill=(229, 177, 77, 140), width=2)

    def corner(left: bool, top: bool) -> None:
        sx = 1 if left else -1
        sy = 1 if top else -1
        ox = 22 if left else width - 22
        oy = 22 if top else height - 22
        box = (ox if left else ox - 84, oy if top else oy - 84, ox + 84 if left else ox, oy + 84 if top else oy)
        start = 180 if left and top else 270 if not left and top else 90 if left else 0
        draw.arc(box, start=start, end=start + 90, fill=GOLD_HOT, width=3)
        draw.arc((box[0] + 8, box[1] + 8, box[2] - 8, box[3] - 8), start=start, end=start + 90, fill=(176, 106, 36, 190), width=2)
        pts = [
            (ox, oy + sy * 14),
            (ox + sx * 42, oy + sy * 22),
            (ox + sx * 22, oy + sy * 42),
        ]
        draw.line(pts, fill=(242, 196, 92, 170), width=2)
        draw.polygon([(ox + sx * 6, oy), (ox + sx * 14, oy + sy * 6), (ox + sx * 6, oy + sy * 14)], fill=GOLD_HOT)

    for left in (True, False):
        for top in (True, False):
            corner(left, top)

    for y in (13, height - 13):
        x = width // 2
        draw.polygon([(x - 23, y), (x, y - 16), (x + 23, y), (x, y + 16)], fill=(32, 19, 9, 255), outline=GOLD_HOT)
        draw.polygon([(x - 9, y), (x, y - 28), (x + 9, y), (x, y + 28)], fill=(14, 15, 18, 255), outline=GOLD)
        draw.polygon([(x - 5, y), (x, y - 12), (x + 5, y), (x, y + 12)], fill=GOLD_HOT)

    for x in range(96, width - 96, 96):
        draw.line((x, title_y + 42, x + 28, title_y + 42), fill=(255, 217, 115, 28), width=1)

    return out


def draw_symbol_mask(name: str) -> Image.Image:
    mask = Image.new("L", (WORK, WORK), 0)
    draw = ImageDraw.Draw(mask, "L")
    if name == "fire":
        draw.polygon(scaled([(0.50, 0.05), (0.66, 0.30), (0.77, 0.51), (0.72, 0.73), (0.58, 0.92), (0.41, 0.92), (0.25, 0.72), (0.22, 0.54), (0.31, 0.34), (0.40, 0.48)]), fill=255)
        draw.polygon(scaled([(0.50, 0.25), (0.61, 0.46), (0.57, 0.66), (0.50, 0.82), (0.40, 0.66), (0.42, 0.48)]), fill=0)
    elif name == "ice":
        center = (WORK * 0.5, WORK * 0.5)
        for i in range(6):
            angle = math.tau * i / 6.0
            dx, dy = math.cos(angle), math.sin(angle)
            nx, ny = -dy, dx
            start = (center[0] - dx * WORK * 0.08, center[1] - dy * WORK * 0.08)
            tip = (center[0] + dx * WORK * 0.40, center[1] + dy * WORK * 0.40)
            half = WORK * 0.034
            draw.polygon([(start[0] + nx * half, start[1] + ny * half), (start[0] - nx * half, start[1] - ny * half), (tip[0] - nx * half, tip[1] - ny * half), (tip[0] + nx * half, tip[1] + ny * half)], fill=255)
            base = (center[0] + dx * WORK * 0.22, center[1] + dy * WORK * 0.22)
            for sign in (-1, 1):
                ba = angle + sign * 0.78
                bx, by = math.cos(ba), math.sin(ba)
                draw.polygon([base, (base[0] + bx * WORK * 0.16, base[1] + by * WORK * 0.16), (base[0] + dx * WORK * 0.16, base[1] + dy * WORK * 0.16)], fill=255)
        r = WORK * 0.105
        draw.ellipse((center[0] - r, center[1] - r, center[0] + r, center[1] + r), fill=255)
    elif name == "earth":
        draw.polygon(scaled([(0.50, 0.07), (0.78, 0.34), (0.67, 0.78), (0.50, 0.93), (0.33, 0.78), (0.22, 0.34)]), fill=255)
        draw.polygon(scaled([(0.48, 0.18), (0.54, 0.48), (0.50, 0.88), (0.45, 0.48)]), fill=0)
    elif name == "heart":
        draw.ellipse((WORK * 0.18, WORK * 0.13, WORK * 0.55, WORK * 0.50), fill=255)
        draw.ellipse((WORK * 0.45, WORK * 0.13, WORK * 0.82, WORK * 0.50), fill=255)
        draw.polygon(scaled([(0.15, 0.34), (0.85, 0.34), (0.50, 0.93)]), fill=255)
    elif name == "armor":
        draw.polygon(scaled([(0.50, 0.07), (0.83, 0.20), (0.80, 0.57), (0.50, 0.92), (0.20, 0.57), (0.17, 0.20)]), fill=255)
        draw.polygon(scaled([(0.48, 0.22), (0.57, 0.29), (0.53, 0.72), (0.47, 0.78)]), fill=0)
    elif name == "gold":
        draw.polygon(scaled([(0.13, 0.60), (0.23, 0.20), (0.39, 0.47), (0.50, 0.12), (0.61, 0.47), (0.77, 0.20), (0.87, 0.60), (0.78, 0.83), (0.22, 0.83)]), fill=255)
        draw.rounded_rectangle((WORK * 0.20, WORK * 0.70, WORK * 0.80, WORK * 0.91), radius=round(WORK * 0.06), fill=255)
    return mask


def draw_symbol(name: str) -> Image.Image:
    palette = PALETTES[name]
    mask = draw_symbol_mask(name)
    out = Image.new("RGBA", mask.size, (0, 0, 0, 0))
    glow = Image.new("RGBA", mask.size, palette["core"])
    glow.putalpha(mask.filter(ImageFilter.GaussianBlur(8 * SCALE)).point(lambda v: round(v * 0.48)))
    out.alpha_composite(glow)
    edge = mask.filter(ImageFilter.MaxFilter(15))
    edge = Image.eval(edge, lambda v: max(0, v - mask.getpixel((0, 0))))
    outline = Image.new("RGBA", mask.size, palette["dark"])
    outline.putalpha(edge.point(lambda v: round(v * 0.65)))
    out.alpha_composite(outline)
    fill = vertical_gradient(mask.size, palette["hot"], palette["core"])
    fill.putalpha(mask)
    out.alpha_composite(fill)
    return out.resize((CANVAS, CANVAS), Image.Resampling.LANCZOS)


def draw_emblem(name: str) -> Image.Image:
    palette = PALETTES[name]
    out = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    center = CANVAS / 2

    aura = Image.new("RGBA", (CANVAS, CANVAS), palette["aura"])
    aura.putalpha(radial_alpha((CANVAS, CANVAS), (center, center), 116, 150))
    out.alpha_composite(aura)

    rings = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(rings, "RGBA")
    draw.ellipse((29, 29, 227, 227), outline=(252, 224, 142, 236), width=6)
    draw.ellipse((40, 40, 216, 216), outline=(92, 59, 22, 235), width=5)
    draw.ellipse((50, 50, 206, 206), outline=(248, 220, 132, 206), width=3)
    draw.ellipse((63, 63, 193, 193), outline=(255, 255, 220, 80), width=2)
    for i in range(42):
        angle = math.tau * i / 42.0
        radius = 102 + 5 * math.sin(i * 1.7)
        x = center + math.cos(angle) * radius
        y = center + math.sin(angle) * radius
        color = palette["hot"] if i % 7 == 0 else palette["core"]
        draw.ellipse((x - 1.5, y - 1.5, x + 1.5, y + 1.5), fill=color[:3] + (120,))
    for angle in (0, math.pi / 2, math.pi, math.pi * 1.5):
        x = center + math.cos(angle) * 101
        y = center + math.sin(angle) * 101
        draw.polygon([(x, y - 14), (x + 8, y), (x, y + 14), (x - 8, y)], fill=(48, 34, 18, 255), outline=GOLD_HOT)
    out.alpha_composite(blur_alpha(rings, 0.35))

    symbol = draw_symbol(name).resize((112, 112), Image.Resampling.LANCZOS)
    out.alpha_composite(symbol, (72, 72))
    return out


def draw_card(name: str) -> Image.Image:
    palette = PALETTES[name]
    width, height = CARD_SIZE
    out = Image.new("RGBA", CARD_SIZE, (0, 0, 0, 0))
    mask = rounded_mask(CARD_SIZE, 3, 24)
    body = vertical_gradient(CARD_SIZE, blend(palette["aura"], (0, 0, 0, 255), 0.68), (4, 6, 10, 238))
    out.alpha_composite(apply_alpha(body, mask))

    aura = Image.new("RGBA", CARD_SIZE, palette["aura"])
    aura.putalpha(radial_alpha(CARD_SIZE, (width / 2, height * 0.38), 150, 108))
    out.alpha_composite(aura)

    draw = ImageDraw.Draw(out, "RGBA")
    for inset, color, line_width, radius in [
        (3, (218, 158, 70, 235), 4, 24),
        (10, (34, 23, 14, 255), 3, 18),
        (15, (242, 205, 104, 154), 2, 14),
    ]:
        draw.rounded_rectangle((inset, inset, width - inset - 1, height - inset - 1), radius=radius, outline=color, width=line_width)
    for x in (22, width - 22):
        draw.polygon([(x, height * 0.52 - 12), (x + (10 if x < width / 2 else -10), height * 0.52), (x, height * 0.52 + 12)], fill=(219, 174, 82, 168))
    for i in range(18):
        angle = math.tau * i / 18.0
        rx = width / 2 + math.cos(angle) * (88 + i % 3 * 5)
        ry = height * 0.34 + math.sin(angle) * (88 + i % 3 * 5)
        draw.line((width / 2, height * 0.34, rx, ry), fill=palette["core"][:3] + (18,), width=1)
    return out


def main() -> None:
    ICON_DIR.mkdir(parents=True, exist_ok=True)
    CHROME_DIR.mkdir(parents=True, exist_ok=True)
    outputs: list[Path] = []

    panel_path = CHROME_DIR / "mastery_preview_panel_frame.png"
    draw_panel_frame().save(panel_path, "PNG")
    outputs.append(panel_path)

    for name in ORB_ORDER:
        card_path = CHROME_DIR / f"mastery_preview_card_{name}.png"
        draw_card(name).save(card_path, "PNG")
        outputs.append(card_path)

    for output in outputs:
        print(f"created {output.relative_to(ROOT)}")
    print(f"generated {len(outputs)} mastery preview chrome assets")


if __name__ == "__main__":
    main()
