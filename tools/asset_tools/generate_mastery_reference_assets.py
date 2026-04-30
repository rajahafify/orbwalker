#!/usr/bin/env python3
from __future__ import annotations

import math
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Tuple

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
VFX_DIR = ROOT / "resources" / "art" / "first_pass" / "derived" / "vfx"
UI_CHROME_DIR = ROOT / "resources" / "art" / "first_pass" / "derived" / "ui_chrome"

Color = Tuple[int, int, int, int]


@dataclass(frozen=True)
class BeamSpec:
    name: str
    core: Color
    accent: Color
    glow: Color


@dataclass(frozen=True)
class CardSpec:
    name: str
    base: Color
    glow: Color
    trim: Color


def clamp(value: float) -> int:
    return max(0, min(255, int(round(value))))


def blend(a: Color, b: Color, t: float) -> Color:
    t = max(0.0, min(1.0, t))
    return (
        clamp(a[0] + (b[0] - a[0]) * t),
        clamp(a[1] + (b[1] - a[1]) * t),
        clamp(a[2] + (b[2] - a[2]) * t),
        clamp(a[3] + (b[3] - a[3]) * t),
    )


def rounded_mask(size: Tuple[int, int], inset: int, radius: int) -> Image.Image:
    width, height = size
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask, "L")
    draw.rounded_rectangle(
        (inset, inset, width - inset - 1, height - inset - 1),
        radius=radius,
        fill=255,
    )
    return mask


def vertical_gradient(size: Tuple[int, int], top: Color, bottom: Color) -> Image.Image:
    width, height = size
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    for y in range(height):
        t = y / max(1, height - 1)
        color = blend(top, bottom, t)
        draw.line([(0, y), (width, y)], fill=color, width=1)
    return image


def clear_corner_pixels(image: Image.Image, padding: int = 2) -> None:
    px = image.load()
    width, height = image.size
    limit_x = min(padding, width)
    limit_y = min(padding, height)
    for x in range(limit_x):
        for y in range(limit_y):
            px[x, y] = (0, 0, 0, 0)
            px[x, height - 1 - y] = (0, 0, 0, 0)
            px[width - 1 - x, y] = (0, 0, 0, 0)
            px[width - 1 - x, height - 1 - y] = (0, 0, 0, 0)


def blur_alpha(image: Image.Image, radius: float) -> Image.Image:
    return image.filter(ImageFilter.GaussianBlur(radius))


def panel_frame() -> Image.Image:
    size = (1048, 188)
    width, height = size
    output = Image.new("RGBA", size, (0, 0, 0, 0))
    radius = max(2, int(height * 0.09))
    outer = rounded_mask(size, 0, radius)
    top_trim = max(10, int(height * 0.16))
    side_pad = max(1, int(width * 0.01))
    panel_radius = max(2, int(radius * 0.65))
    corner_h = max(10, int(height * 0.12))

    body = vertical_gradient(
        size,
        (16, 12, 24, 190),
        (4, 5, 10, 170),
    )
    body = Image.composite(body, Image.new("RGBA", size, (0, 0, 0, 0)), outer)
    body_alpha = body.getchannel("A").point(lambda v: int(v * 0.88))
    body.putalpha(body_alpha)
    output.alpha_composite(body)

    draw = ImageDraw.Draw(output, "RGBA")
    draw.rounded_rectangle(
        (2, 2, width - 3, height - 3),
        radius=panel_radius + 3,
        outline=(250, 214, 120, 238),
        width=3,
    )
    draw.rounded_rectangle(
        (side_pad * 2, top_trim - 2, width - side_pad * 2 - 1, height - int(height * 0.08)),
        radius=max(2, int(radius * 0.5)),
        outline=(206, 168, 78, 170),
        width=2,
    )
    draw.rounded_rectangle(
        (0, 0, width - 1, height - 1),
        radius=14,
        outline=(250, 214, 120, 90),
        width=1,
    )

    # Reference-style ornamental accents.
    accent = Image.new("RGBA", size, (0, 0, 0, 0))
    marks = ImageDraw.Draw(accent, "RGBA")
    mark_y_start = max(18, int(height * 0.10))
    mark_y_step = max(4, int(height * 0.04))
    for x in (130, 260, 390, 520, 650, 780, 910):
        for i in range(7):
            y = mark_y_start + int(i * mark_y_step * 0.85)
            a = 120 - abs(i - 3) * 12
            marks.line(
                [(x - 24 + i, y), (x + 24 - i, y)],
                fill=(232, 190, 84, clamp(a)),
                width=1,
            )
        dot_y = int(height * 0.57)
        marks.ellipse((x - 5, dot_y, x + 5, dot_y + 10), fill=(255, 225, 127, 80))
    output.alpha_composite(blur_alpha(accent, 1.0))

    # Corner flourishes
    corner = Image.new("RGBA", size, (0, 0, 0, 0))
    deco = ImageDraw.Draw(corner, "RGBA")
    corner_top = max(6, int(height * 0.08))
    corner_bottom = max(22, int(height * 0.22))
    points = [
        (16, corner_top, 44, corner_bottom),
        (width - 44, corner_top, width - 16, corner_bottom),
    ]
    for left, top, right, bottom in points:
        deco.arc((left, top, right, bottom), start=90, end=360, fill=(255, 225, 127, 140), width=2)
        deco.arc((left + 4, top + 4, right - 4, bottom - 4), start=180, end=420, fill=(255, 225, 127, 84), width=1)
    output.alpha_composite(blur_alpha(corner, 0.8))

    # Soft inner atmosphere
    ambience = Image.new("RGBA", size, (0, 0, 0, 0))
    amb = ImageDraw.Draw(ambience, "RGBA")
    amb.rectangle((22, top_trim - 2, width - 22, int(height * 0.86)), fill=(255, 231, 142, 24))
    output.alpha_composite(blur_alpha(ambience, 24.0))
    clear_corner_pixels(output)
    return output


def card_background(spec: CardSpec) -> Image.Image:
    size = (320, 256)
    width, height = size
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    base_shape = rounded_mask(size, 2, 10)
    body = vertical_gradient(size, spec.base, (0, 0, 0, 160))
    body = Image.composite(body, Image.new("RGBA", size, (0, 0, 0, 0)), base_shape)
    body.putalpha(body.getchannel("A").point(lambda v: int(v * 0.88)))
    canvas.alpha_composite(body)

    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rounded_rectangle(
        (3, 3, width - 4, height - 4),
        radius=8,
        fill=None,
        outline=spec.trim,
        width=2,
    )
    draw.rounded_rectangle(
        (9, 9, width - 10, height - 10),
        radius=4,
        outline=(255, 232, 158, 72),
        width=1,
    )

    accent = Image.new("RGBA", size, (0, 0, 0, 0))
    halo = ImageDraw.Draw(accent, "RGBA")
    halo.rounded_rectangle(
        (6, 6, width - 7, height - 7),
        radius=6,
        outline=spec.glow[:3] + (70,),
        width=1,
    )
    for i in range(2):
        halo.arc((6, 12 + i * (height * 0.45), 16, 22 + i * (height * 0.45)), 0, 360, fill=spec.trim, width=1)
        halo.arc((width - 16, 12 + i * (height * 0.45), width - 6, 22 + i * (height * 0.45)), 0, 360, fill=spec.trim, width=1)
    canvas.alpha_composite(blur_alpha(accent, 0.9))
    clear_corner_pixels(canvas, padding=2)
    return canvas


def beam(spec: BeamSpec) -> Image.Image:
    size = (560, 84)
    width, height = size
    core = Image.new("RGBA", size, (0, 0, 0, 0))
    core_draw = ImageDraw.Draw(core, "RGBA")
    glow = Image.new("RGBA", size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow, "RGBA")
    center_y = height * 0.5

    for x in range(width):
        t = x / max(1, width - 1)
        drift = 1.9 * math.sin(t * 2.4 * math.pi + 0.12)
        y = center_y + drift
        ribbon = 3.0 + 2.4 * math.sin(t * 3.7 * math.pi + 0.8)
        if ribbon < 2.0:
            ribbon = 2.0
        profile = 0.35 + 0.55 * (1.0 - abs(t - 0.5) * 1.55)
        if profile < 0.0:
            profile = 0.0
        color = blend(spec.core, spec.accent, t * 0.85 + 0.08)
        glow_draw.line(
            (x, y - ribbon * 4.1, x, y + ribbon * 4.1),
            fill=(spec.glow[0], spec.glow[1], spec.glow[2], int(75 * profile)),
            width=1,
        )
        core_draw.line(
            (x, y - ribbon, x, y + ribbon),
            fill=(color[0], color[1], color[2], int(130 * profile)),
            width=1,
        )
        if x % 32 == 0:
            pulse = 0.5 + 0.5 * math.sin(t * 10.0)
            cy = y + 1.6
            r = 2.6 + 2.0 * pulse
            glow_draw.ellipse((x - r - 2, cy - r - 2, x + r + 2, cy + r + 2), fill=(255, 255, 255, 20))

    core_glow = blur_alpha(glow, 7.2)
    beam_img = core_glow
    beam_img.alpha_composite(core)
    # Soft terminal caps for cleaner “impact-ready” ends.
    terminal = Image.new("RGBA", size, (0, 0, 0, 0))
    term_draw = ImageDraw.Draw(terminal, "RGBA")
    tip_size = height * 0.5
    term_draw.ellipse(
        (6, center_y - tip_size * 0.28, 30, center_y + tip_size * 0.28),
        fill=spec.core[:3] + (140,),
    )
    term_draw.ellipse(
        (width - 30, center_y - tip_size * 0.28, width - 6, center_y + tip_size * 0.28),
        fill=spec.core[:3] + (140,),
    )
    beam_img.alpha_composite(blur_alpha(terminal, 2.4))

    # Add long, clean core ridge.
    ridge = Image.new("RGBA", size, (0, 0, 0, 0))
    ridge_draw = ImageDraw.Draw(ridge, "RGBA")
    ridge_draw.rounded_rectangle(
        (18, center_y - 1, width - 18, center_y + 1),
        radius=1,
        fill=(255, 255, 255, 45),
    )
    beam_img.alpha_composite(blur_alpha(ridge, 0.6))

    return beam_img


def shell_armor() -> Image.Image:
    size = (168, 168)
    width, height = size
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    cx = width * 0.5
    cy = height * 0.58
    shield = [
        (cx, height * 0.06),
        (width * 0.89, height * 0.28),
        (width * 0.86, height * 0.68),
        (cx, height * 0.94),
        (width * 0.14, height * 0.68),
        (width * 0.11, height * 0.28),
    ]
    draw = ImageDraw.Draw(out, "RGBA")
    # outer shell
    draw.polygon(shield, fill=(72, 96, 156, 44), outline=(132, 184, 255, 230), width=2)
    draw.polygon(
        [
            (cx, height * 0.24),
            (width * 0.66, height * 0.34),
            (width * 0.66, height * 0.58),
            (cx, height * 0.81),
            (width * 0.34, height * 0.58),
            (width * 0.34, height * 0.34),
        ],
        fill=(128, 164, 230, 84),
        outline=(160, 210, 255, 190),
        width=2,
    )

    # inner starburst
    for i in range(10):
        a = i * 36.0 / 180.0 * math.pi
        r0 = 45 + 6 * math.sin(i)
        r1 = 72 + 8 * math.cos(i * 2.3)
        x0 = cx + r0 * math.cos(a)
        y0 = cy + r0 * math.sin(a) * 0.82
        x1 = cx + r1 * math.cos(a)
        y1 = cy + r1 * math.sin(a) * 0.82
        draw.line((x0, y0, x1, y1), fill=(196, 230, 255, 64), width=1)

    outer_glow_source = Image.new("RGBA", size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(outer_glow_source, "RGBA")
    glow_draw.ellipse((20, 16, width - 20, height - 16), outline=(150, 190, 255, 110), width=5)
    outer_glow = blur_alpha(outer_glow_source, 2.0)
    out.alpha_composite(outer_glow)

    rim = Image.new("RGBA", size, (0, 0, 0, 0))
    rim_draw = ImageDraw.Draw(rim, "RGBA")
    rim_draw.ellipse((18, 12, width - 18, height - 12), outline=(255, 255, 255, 45), width=2)
    rim_draw.ellipse((25, 22, width - 25, height - 22), outline=(160, 210, 255, 90), width=1)
    out.alpha_composite(blur_alpha(rim, 1.2))
    return out


def impact(name: str, core: Color, accent: Color, accent2: Color) -> tuple[str, Image.Image]:
    size = (128, 128)
    cx = size[0] * 0.5
    cy = size[1] * 0.5
    out = Image.new("RGBA", size, (0, 0, 0, 0))

    for i in range(4):
        ring_t = i / 4.0
        radius = 12 + ring_t * 46
        alpha = 110 - i * 24
        out_draw = ImageDraw.Draw(out, "RGBA")
        out_draw.ellipse(
            (cx - radius, cy - radius, cx + radius, cy + radius),
            outline=(core[0], core[1], core[2], max(0, alpha)),
            width=3,
        )

    for i in range(12):
        ang = i / 12.0 * 2 * math.pi
        x0 = cx + math.cos(ang) * 14
        y0 = cy + math.sin(ang) * 14
        x1 = cx + math.cos(ang) * 50
        y1 = cy + math.sin(ang) * 50
        out_draw = ImageDraw.Draw(out, "RGBA")
        out_draw.line((x0, y0, x1, y1), fill=(accent[0], accent[1], accent[2], 74), width=2)

    for i in range(20):
        ring = 55 + i * 1.4
        start = i * 18
        out_draw = ImageDraw.Draw(out, "RGBA")
        out_draw.arc(
            (cx - ring, cy - ring, cx + ring, cy + ring),
            start=start,
            end=start + 11,
            fill=(accent2[0], accent2[1], accent2[2], 44),
            width=1,
        )

    center = Image.new("RGBA", size, (0, 0, 0, 0))
    center_draw = ImageDraw.Draw(center, "RGBA")
    center_draw.ellipse((cx - 10, cy - 10, cx + 10, cy + 10), fill=core[:3] + (132,))
    out.alpha_composite(blur_alpha(center, 2.3))

    return name, out


def card_specs() -> Iterable[CardSpec]:
    yield CardSpec("fire", (90, 24, 16, 204), (255, 130, 80, 90), (255, 196, 108, 220))
    yield CardSpec("ice", (38, 66, 108, 204), (115, 194, 255, 86), (205, 238, 255, 220))
    yield CardSpec("earth", (48, 75, 30, 204), (188, 230, 118, 90), (214, 255, 160, 220))
    yield CardSpec("heart", (74, 38, 64, 204), (255, 145, 170, 90), (255, 204, 224, 220))
    yield CardSpec("armor", (46, 56, 88, 204), (170, 198, 255, 90), (220, 236, 255, 220))
    yield CardSpec("gold", (94, 73, 23, 204), (255, 214, 122, 90), (255, 244, 194, 220))


def beam_specs() -> Iterable[BeamSpec]:
    yield BeamSpec("fire", (251, 82, 26, 255), (255, 181, 109, 255), (255, 128, 56, 255))
    yield BeamSpec("ice", (72, 170, 246, 255), (179, 234, 255, 255), (112, 223, 255, 255))
    yield BeamSpec("earth", (132, 191, 84, 255), (226, 252, 163, 255), (126, 209, 74, 255))
    yield BeamSpec("heart", (251, 82, 146, 255), (255, 194, 224, 255), (255, 130, 183, 255))
    yield BeamSpec("armor", (191, 204, 247, 255), (238, 248, 255, 255), (186, 208, 255, 255))
    yield BeamSpec("gold", (255, 189, 83, 255), (255, 236, 188, 255), (255, 206, 95, 255))


def generate_all() -> list[tuple[str, Path]]:
    outputs: list[tuple[str, Path]] = []

    panel = panel_frame()
    panel_path = UI_CHROME_DIR / "mastery_panel_frame.png"
    outputs.append(("panel_frame", panel_path))
    panel.save(panel_path, "PNG")

    for spec in card_specs():
        card = card_background(spec)
        path = UI_CHROME_DIR / f"mastery_card_{spec.name}.png"
        outputs.append((f"card_{spec.name}", path))
        card.save(path, "PNG")

    for spec in beam_specs():
        b = beam(spec)
        path = VFX_DIR / f"mastery_beam_{spec.name}.png"
        outputs.append((f"beam_{spec.name}", path))
        b.save(path, "PNG")

    shell = shell_armor()
    shell_path = VFX_DIR / "mastery_shell_armor.png"
    outputs.append(("shell_armor", shell_path))
    shell.save(shell_path, "PNG")

    impact_specs = [
        ("mastery_hit_impact.png", (255, 104, 96, 220), (255, 204, 96, 130), (255, 255, 255, 90)),
        ("mastery_heal_impact.png", (110, 255, 165, 220), (173, 255, 204, 130), (255, 255, 255, 90)),
        ("mastery_gold_impact.png", (255, 206, 110, 220), (255, 240, 173, 130), (255, 255, 255, 90)),
    ]
    for file_name, core, glow, accent in impact_specs:
        _, img = impact(file_name, core, glow, accent)
        path = VFX_DIR / file_name
        outputs.append((f"impact_{file_name}", path))
        img.save(path, "PNG")

    return outputs


def main() -> None:
    UI_CHROME_DIR.mkdir(parents=True, exist_ok=True)
    VFX_DIR.mkdir(parents=True, exist_ok=True)

    generated = generate_all()
    for key, path in generated:
        print(f"created {path.relative_to(ROOT)}")
    print(f"generated {len(generated)} assets")


if __name__ == "__main__":
    main()
