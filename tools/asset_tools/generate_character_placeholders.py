#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Tuple

from PIL import Image, ImageDraw, ImageFilter


Color = Tuple[int, int, int, int]
ROOT = Path(__file__).resolve().parents[2]
ENEMIES_DIR = ROOT / "resources" / "art" / "first_pass" / "enemies"
HEROES_DIR = ROOT / "resources" / "art" / "first_pass" / "heroes"


@dataclass(frozen=True)
class PortraitSpec:
	name: str
	path: Path
	size: Tuple[int, int]
	primary: Color
	secondary: Color
	accent: Color
	is_enemy: bool


def clamp(value: int) -> int:
	return max(0, min(255, value))


def blend(a: Color, b: Color, t: float) -> Color:
	t = max(0.0, min(1.0, t))
	return (
		clamp(int(a[0] * (1.0 - t) + b[0] * t)),
		clamp(int(a[1] * (1.0 - t) + b[1] * t)),
		clamp(int(a[2] * (1.0 - t) + b[2] * t)),
		clamp(int(a[3] * (1.0 - t) + b[3] * t)),
	)


def radial_gradient(size: Tuple[int, int], inner: Color, outer: Color) -> Image.Image:
	width, height = size
	image = Image.new("RGBA", size, (0, 0, 0, 0))
	pixels = image.load()
	cx = (width - 1) * 0.5
	cy = (height - 1) * 0.5
	radius = max(1.0, min(width, height) * 0.55)
	for y in range(height):
		for x in range(width):
			dx = x - cx
			dy = y - cy
			dist = (dx * dx + dy * dy) ** 0.5
			t = min(1.0, dist / radius)
			pixels[x, y] = blend(inner, outer, t)
	return image


def draw_enemy_portrait(spec: PortraitSpec) -> Image.Image:
	width, height = spec.size
	base = radial_gradient(spec.size, spec.secondary, (8, 12, 20, 255))
	draw = ImageDraw.Draw(base, "RGBA")

	border = blend(spec.primary, (220, 188, 126, 255), 0.22)
	draw.rounded_rectangle(
		(3, 3, width - 4, height - 4),
		radius=14,
		outline=border,
		width=4,
		fill=(10, 14, 24, 210),
	)
	draw.rounded_rectangle(
		(8, 8, width - 9, height - 9),
		radius=12,
		outline=blend(border, (255, 230, 184, 255), 0.20),
		width=2,
	)

	# Shoulders + torso silhouette
	draw.polygon(
		[
			(width * 0.16, height * 0.90),
			(width * 0.84, height * 0.90),
			(width * 0.73, height * 0.56),
			(width * 0.27, height * 0.56),
		],
		fill=blend(spec.primary, (24, 30, 42, 255), 0.35),
	)
	draw.rounded_rectangle(
		(width * 0.33, height * 0.20, width * 0.67, height * 0.58),
		radius=32,
		fill=blend(spec.primary, (18, 22, 30, 255), 0.20),
		outline=blend(spec.primary, (220, 220, 230, 255), 0.18),
		width=3,
	)

	# Eye glow
	draw.ellipse(
		(width * 0.41, height * 0.34, width * 0.48, height * 0.40),
		fill=spec.accent,
	)
	draw.ellipse(
		(width * 0.52, height * 0.34, width * 0.59, height * 0.40),
		fill=spec.accent,
	)

	# Weapon accent
	draw.polygon(
		[
			(width * 0.72, height * 0.50),
			(width * 0.87, height * 0.34),
			(width * 0.90, height * 0.41),
			(width * 0.76, height * 0.56),
		],
		fill=blend(spec.accent, (240, 220, 170, 255), 0.24),
	)

	highlight = Image.new("RGBA", spec.size, (0, 0, 0, 0))
	hd = ImageDraw.Draw(highlight, "RGBA")
	hd.ellipse(
		(width * 0.22, height * 0.06, width * 0.58, height * 0.42),
		fill=(255, 255, 255, 36),
	)
	base.alpha_composite(highlight.filter(ImageFilter.GaussianBlur(5)))
	return base


def draw_hero_portrait(spec: PortraitSpec) -> Image.Image:
	width, height = spec.size
	base = radial_gradient(spec.size, spec.secondary, (8, 11, 18, 255))
	draw = ImageDraw.Draw(base, "RGBA")

	gold = blend((210, 170, 102, 255), spec.primary, 0.25)
	draw.rounded_rectangle(
		(3, 3, width - 4, height - 4),
		radius=14,
		outline=gold,
		width=4,
		fill=(10, 14, 22, 215),
	)
	draw.rounded_rectangle(
		(8, 8, width - 9, height - 9),
		radius=12,
		outline=blend(gold, (245, 220, 170, 255), 0.20),
		width=2,
	)

	# Cloak
	draw.polygon(
		[
			(width * 0.18, height * 0.90),
			(width * 0.82, height * 0.90),
			(width * 0.68, height * 0.58),
			(width * 0.32, height * 0.58),
		],
		fill=blend(spec.primary, (20, 28, 40, 255), 0.35),
	)

	# Head and hood
	draw.ellipse(
		(width * 0.34, height * 0.18, width * 0.66, height * 0.54),
		fill=blend(spec.primary, (24, 30, 42, 255), 0.28),
		outline=blend(spec.primary, (210, 210, 220, 255), 0.16),
		width=3,
	)
	draw.polygon(
		[
			(width * 0.30, height * 0.36),
			(width * 0.50, height * 0.10),
			(width * 0.70, height * 0.36),
			(width * 0.62, height * 0.30),
			(width * 0.38, height * 0.30),
		],
		fill=blend(spec.secondary, spec.primary, 0.30),
	)

	# Orb focus in hand
	orb_center = (int(width * 0.68), int(height * 0.72))
	orb_radius = int(min(width, height) * 0.11)
	draw.ellipse(
		(
			orb_center[0] - orb_radius,
			orb_center[1] - orb_radius,
			orb_center[0] + orb_radius,
			orb_center[1] + orb_radius,
		),
		fill=spec.accent,
	)
	orb_glow = Image.new("RGBA", spec.size, (0, 0, 0, 0))
	og = ImageDraw.Draw(orb_glow, "RGBA")
	og.ellipse(
		(
			orb_center[0] - orb_radius * 2,
			orb_center[1] - orb_radius * 2,
			orb_center[0] + orb_radius * 2,
			orb_center[1] + orb_radius * 2,
		),
		fill=(spec.accent[0], spec.accent[1], spec.accent[2], 70),
	)
	base.alpha_composite(orb_glow.filter(ImageFilter.GaussianBlur(4)))

	# Eye glow
	draw.ellipse(
		(width * 0.44, height * 0.33, width * 0.48, height * 0.37),
		fill=(255, 240, 200, 255),
	)
	draw.ellipse(
		(width * 0.52, height * 0.33, width * 0.56, height * 0.37),
		fill=(255, 240, 200, 255),
	)
	return base


def specs() -> Iterable[PortraitSpec]:
	yield PortraitSpec(
		name="enemy_ruin_lancer",
		path=ENEMIES_DIR / "enemy_ruin_lancer.png",
		size=(260, 230),
		primary=(90, 112, 160, 255),
		secondary=(18, 26, 44, 255),
		accent=(120, 202, 255, 255),
		is_enemy=True,
	)
	yield PortraitSpec(
		name="enemy_vault_executioner",
		path=ENEMIES_DIR / "enemy_vault_executioner.png",
		size=(260, 230),
		primary=(126, 78, 66, 255),
		secondary=(30, 17, 22, 255),
		accent=(255, 138, 110, 255),
		is_enemy=True,
	)
	yield PortraitSpec(
		name="enemy_goldbound_keeper",
		path=ENEMIES_DIR / "enemy_goldbound_keeper.png",
		size=(260, 230),
		primary=(120, 98, 56, 255),
		secondary=(36, 28, 14, 255),
		accent=(246, 210, 122, 255),
		is_enemy=True,
	)
	yield PortraitSpec(
		name="hero_orbwalker",
		path=HEROES_DIR / "hero_orbwalker.png",
		size=(192, 192),
		primary=(86, 120, 176, 255),
		secondary=(16, 24, 44, 255),
		accent=(128, 212, 255, 255),
		is_enemy=False,
	)


def save_portrait(spec: PortraitSpec) -> None:
	spec.path.parent.mkdir(parents=True, exist_ok=True)
	image = draw_enemy_portrait(spec) if spec.is_enemy else draw_hero_portrait(spec)
	image.save(spec.path, "PNG")
	print(f"saved {spec.path.relative_to(ROOT)}")


def main() -> None:
	for spec in specs():
		save_portrait(spec)


if __name__ == "__main__":
	main()
