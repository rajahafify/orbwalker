#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageOps


ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = ROOT / "resources" / "art" / "first_pass" / "derived" / "combat_ui"
ENEMY_DIR = ROOT / "resources" / "art" / "first_pass" / "enemies"
BACKGROUND_PATH = ROOT / "resources" / "art" / "first_pass" / "backgrounds" / "combat_bg_dungeon_01.png"

STAGE_SIZE = (1048, 336)

ENEMY_ID_TO_SOURCE = {
    "cavern_striker": "enemy_cavern_striker.png",
    "cavern_defender": "enemy_cavern_defender.png",
    "ash_hunter": "enemy_ash_hunter.png",
    "ruin_lancer": "enemy_ruin_lancer.png",
    "vault_executioner": "enemy_vault_executioner.png",
    "goldbound_keeper": "enemy_goldbound_keeper.png",
    "iron_gate": "boss_iron_gate.png",
    "burning_knight": "boss_burning_knight.png",
    "prism_warden": "boss_prism_warden.png",
}


def ensure_dirs() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)


def load_rgba(path: Path) -> Image.Image:
    with Image.open(path) as src:
        return src.convert("RGBA")


def write_png(name: str, image: Image.Image) -> Path:
    out_path = OUT_DIR / name
    image.save(out_path, "PNG")
    return out_path


def build_stage_background(backdrop: Image.Image) -> Image.Image:
    panel = Image.new("RGBA", STAGE_SIZE, (0, 0, 0, 0))
    resized = ImageOps.fit(backdrop, STAGE_SIZE, method=Image.Resampling.LANCZOS, centering=(0.5, 0.2))
    panel.alpha_composite(resized)

    darken = Image.new("RGBA", STAGE_SIZE, (10, 16, 26, 120))
    panel.alpha_composite(darken)

    haze = Image.new("RGBA", STAGE_SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(haze, "RGBA")
    draw.ellipse((-120, -120, 700, 440), fill=(54, 86, 126, 64))
    draw.ellipse((540, -160, 1280, 420), fill=(90, 56, 34, 68))
    panel.alpha_composite(haze)
    return panel


def fit_enemy(enemy: Image.Image, target_height: int) -> Image.Image:
    if enemy.height <= 0:
        return enemy
    scale = target_height / float(enemy.height)
    width = max(1, int(round(enemy.width * scale)))
    return enemy.resize((width, target_height), Image.Resampling.LANCZOS)


def stage_frame_lines(panel: Image.Image) -> None:
    draw = ImageDraw.Draw(panel, "RGBA")
    width, height = panel.size
    draw.rounded_rectangle((2, 2, width - 3, height - 3), radius=20, outline=(246, 202, 116, 240), width=3)
    draw.rounded_rectangle((10, 10, width - 11, height - 11), radius=16, outline=(102, 72, 40, 210), width=2)
    draw.rectangle((0, height - 70, width, height), fill=(0, 0, 0, 84))


def build_stage_panel(enemy_image: Image.Image | None, backdrop: Image.Image) -> Image.Image:
    panel = build_stage_background(backdrop)

    if enemy_image is not None:
        enemy = fit_enemy(enemy_image, 298)
        shadow = enemy.copy().convert("RGBA")
        shadow = ImageOps.colorize(shadow.convert("L"), black=(0, 0, 0), white=(0, 0, 0)).convert("RGBA")
        shadow.putalpha(enemy.getchannel("A").point(lambda value: int(value * 0.48)))
        shadow = shadow.filter(ImageFilter.GaussianBlur(4.0))
        enemy_x = panel.width - enemy.width - 40
        enemy_y = panel.height - enemy.height - 20
        panel.alpha_composite(shadow, (enemy_x + 8, enemy_y + 10))
        panel.alpha_composite(enemy, (enemy_x, enemy_y))

    stage_frame_lines(panel)
    return panel


def linear_gradient(size: tuple[int, int], top: tuple[int, int, int, int], bottom: tuple[int, int, int, int]) -> Image.Image:
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    width, height = size
    for y in range(height):
        t = y / max(1, height - 1)
        row = (
            round(top[0] + (bottom[0] - top[0]) * t),
            round(top[1] + (bottom[1] - top[1]) * t),
            round(top[2] + (bottom[2] - top[2]) * t),
            round(top[3] + (bottom[3] - top[3]) * t),
        )
        draw.line((0, y, width, y), fill=row, width=1)
    return image


def make_frame(size: tuple[int, int], top: tuple[int, int, int, int], bottom: tuple[int, int, int, int], primary: tuple[int, int, int, int], secondary: tuple[int, int, int, int], radius: int = 16) -> Image.Image:
    frame = linear_gradient(size, top, bottom)
    draw = ImageDraw.Draw(frame, "RGBA")
    w, h = size
    draw.rounded_rectangle((2, 2, w - 3, h - 3), radius=radius, outline=primary, width=3)
    draw.rounded_rectangle((10, 10, w - 11, h - 11), radius=max(8, radius - 4), outline=secondary, width=2)
    return frame


def icon_badge(kind: str) -> Image.Image:
    badge = Image.new("RGBA", (168, 168), (0, 0, 0, 0))
    draw = ImageDraw.Draw(badge, "RGBA")

    base_colors = {
        "attack": ((110, 20, 24, 250), (56, 10, 12, 250), (245, 104, 84, 255)),
        "block": ((26, 52, 96, 250), (10, 24, 56, 250), (134, 194, 248, 255)),
        "mixed": ((78, 52, 18, 250), (34, 24, 12, 250), (240, 205, 120, 255)),
        "idle": ((52, 56, 66, 250), (22, 24, 30, 250), (196, 204, 218, 255)),
    }
    top, bottom, accent = base_colors[kind]
    shell = linear_gradient((168, 168), top, bottom)
    badge.alpha_composite(shell)
    draw.rounded_rectangle((4, 4, 163, 163), radius=30, outline=(248, 230, 176, 236), width=3)
    draw.rounded_rectangle((14, 14, 153, 153), radius=24, outline=(96, 62, 28, 218), width=2)

    if kind == "attack":
        draw.polygon([(84, 36), (128, 88), (98, 86), (116, 132), (54, 84), (76, 86)], fill=accent, outline=(255, 226, 202, 230))
    elif kind == "block":
        draw.polygon([(84, 28), (132, 56), (122, 124), (84, 146), (46, 124), (36, 56)], fill=accent, outline=(212, 236, 255, 234))
        draw.line((84, 40, 84, 124), fill=(224, 242, 255, 228), width=4)
    elif kind == "mixed":
        draw.polygon([(58, 102), (84, 36), (110, 102)], fill=(255, 148, 120, 250), outline=(250, 220, 198, 220))
        draw.polygon([(84, 54), (124, 78), (116, 130), (84, 148), (52, 130), (44, 78)], fill=(170, 218, 252, 235), outline=(230, 245, 255, 220))
    else:
        draw.ellipse((56, 56, 112, 112), fill=accent, outline=(238, 242, 250, 220), width=4)
        draw.rectangle((82, 28, 86, 142), fill=(224, 232, 248, 160))
    return badge


def slot_frame(filled: bool) -> Image.Image:
    top = (28, 34, 48, 255) if not filled else (70, 48, 20, 255)
    bottom = (12, 16, 24, 255) if not filled else (34, 24, 10, 255)
    primary = (148, 164, 190, 240) if not filled else (248, 202, 112, 246)
    secondary = (66, 78, 100, 220) if not filled else (114, 80, 36, 224)
    return make_frame((96, 96), top, bottom, primary, secondary, radius=12)


def generate() -> list[Path]:
    ensure_dirs()
    backdrop = load_rgba(BACKGROUND_PATH)
    written: list[Path] = []

    fallback_stage = build_stage_panel(None, backdrop)
    written.append(write_png("combat_stage_fallback.png", fallback_stage))
    for enemy_id, source_name in ENEMY_ID_TO_SOURCE.items():
        enemy_path = ENEMY_DIR / source_name
        enemy_image = load_rgba(enemy_path) if enemy_path.exists() else None
        panel = build_stage_panel(enemy_image, backdrop)
        written.append(write_png(f"combat_stage_{enemy_id}.png", panel))

    written.append(write_png("combat_intent_badge_attack.png", icon_badge("attack")))
    written.append(write_png("combat_intent_badge_block.png", icon_badge("block")))
    written.append(write_png("combat_intent_badge_mixed.png", icon_badge("mixed")))
    written.append(write_png("combat_intent_badge_idle.png", icon_badge("idle")))

    written.append(write_png("combat_top_bar_frame.png", make_frame((1048, 66), (20, 34, 56, 246), (8, 14, 24, 246), (238, 198, 112, 242), (100, 72, 38, 220), radius=14)))
    written.append(write_png("combat_enemy_panel_frame.png", make_frame((1048, 392), (16, 28, 44, 248), (8, 14, 24, 248), (246, 206, 118, 245), (108, 76, 40, 220), radius=18)))
    written.append(write_png("combat_board_frame.png", make_frame((1048, 846), (10, 18, 30, 250), (4, 8, 14, 252), (236, 194, 106, 244), (102, 70, 36, 220), radius=16)))
    written.append(write_png("combat_mastery_rail_frame.png", make_frame((1048, 128), (18, 30, 46, 246), (8, 14, 26, 246), (226, 186, 100, 238), (96, 68, 34, 214), radius=12)))
    written.append(write_png("combat_player_vitals_frame.png", make_frame((714, 196), (16, 30, 46, 248), (6, 12, 22, 250), (206, 176, 96, 240), (90, 64, 32, 214), radius=12)))
    written.append(write_png("combat_equipment_rail_frame.png", make_frame((500, 100), (16, 28, 44, 248), (8, 12, 22, 250), (226, 186, 100, 236), (96, 68, 34, 212), radius=12)))
    written.append(write_png("combat_consumables_rail_frame.png", make_frame((296, 100), (16, 28, 44, 248), (8, 12, 22, 250), (226, 186, 100, 236), (96, 68, 34, 212), radius=12)))
    written.append(write_png("combat_slot_frame_empty.png", slot_frame(False)))
    written.append(write_png("combat_slot_frame_filled.png", slot_frame(True)))

    # Compatibility textures used by existing code paths while the new names are adopted.
    written.append(write_png("combat_enemy_panel.png", make_frame((1048, 392), (16, 28, 44, 248), (8, 14, 24, 248), (246, 206, 118, 245), (108, 76, 40, 220), radius=18)))
    written.append(write_png("combat_mastery_rail.png", make_frame((1048, 128), (18, 30, 46, 246), (8, 14, 26, 246), (226, 186, 100, 238), (96, 68, 34, 214), radius=12)))
    written.append(write_png("combat_player_hud_rail.png", make_frame((1080, 536), (14, 24, 38, 248), (6, 10, 18, 248), (214, 174, 90, 232), (92, 64, 30, 210), radius=14)))
    written.append(write_png("combat_loadout_rail.png", make_frame((1048, 228), (16, 26, 40, 250), (7, 12, 21, 250), (228, 188, 100, 236), (98, 68, 34, 212), radius=12)))
    written.append(write_png("combat_timer_track.png", make_frame((860, 34), (20, 66, 92, 246), (10, 32, 50, 246), (150, 206, 255, 242), (64, 108, 150, 218), radius=8)))

    return written


def main() -> None:
    written = generate()
    for path in written:
        print(f"created {path.relative_to(ROOT)}")
    print(f"generated {len(written)} combat ui textures")


if __name__ == "__main__":
    main()
