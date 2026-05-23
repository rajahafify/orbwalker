extends RefCounted
class_name CombatMaxVfxOverlay

const REQUIRED_TEXTURE_KEYS: Array[String] = [
	"fire_impact",
	"fire_projectile",
	"ice_impact",
	"ice_projectile",
	"earth_impact",
	"earth_projectile",
	"heal_impact",
	"armor_impact",
	"gold_reward",
	"damage_impact",
	"enemy_attack",
	"orb_clear",
	"spark_particles",
	"smoke_puff",
	"frost_mist",
	"light_rays",
	"shockwave_ring",
	"ice_shards",
	"coin_spin",
	"dust_puff",
	"heal_motes",
	"armor_shell",
	"flame_trail",
	"stone_chunks",
]
const OVERLAY_Z_INDEX := 122
const PRIMARY_FRAMES := 16
const GRID_COLUMNS := 4
const GRID_ROWS := 4
const PACK_VFX_SCENE_PATHS := {
	"hit_01": "res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/hit/vfx_hit_01.tscn",
	"hit_02": "res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/hit/vfx_hit_02.tscn",
	"impact_01": "res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/impact/vfx_impact_01.tscn",
	"impact_02": "res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/impact/vfx_impact_02.tscn",
	"big_impact_01": "res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/big_impact/vfx_big_impact_01.tscn",
	"big_impact_02": "res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/big_impact/vfx_big_impact_02.tscn",
}
const ELEMENTAL_MAGIC_SCENE_PATHS := {
	"cast": "res://assets/BinbunVFX_Vol2/ElementalMagicFX/effects/cast/vfx_fire_cast_01.tscn",
	"projectile": "res://assets/BinbunVFX_Vol2/ElementalMagicFX/effects/projectile/vfx_fire_projectile_01.tscn",
	"area": "res://assets/BinbunVFX_Vol2/ElementalMagicFX/effects/area/vfx_fire_area_01.tscn",
}
const STATUS_VFX_SHEET_PATHS := {
	"armor": "res://assets/VividMotion23/ArmorEffect/Spritesheets/ArmorEffect_Sheet_64x64.png",
	"bleed": "res://assets/VividMotion23/BleedEffect/Spritesheets/BleedEffect_Sheet_64x64.png",
	"blessed": "res://assets/VividMotion23/BlessedEffect/Spritesheets/BlessedEffect_Sheet_64x64.png",
	"burn": "res://assets/VividMotion23/BurnEffect/Spritesheets/BurnEffect_Sheet_64x64.png",
	"freeze": "res://assets/VividMotion23/FreezeEffect/Spritesheets/FreezeEffect_Sheet_64x64.png",
	"haste": "res://assets/VividMotion23/HasteEffect/Spritesheets/HasteEffect_Sheet_64x64.png",
	"heal": "res://assets/VividMotion23/HealEffect/Spritesheets/HealEffect_Sheet_64x64.png",
	"poison": "res://assets/VividMotion23/PoisonBubble/Spritesheets/PoisonBubble_Sheet_64x64.png",
	"rage": "res://assets/VividMotion23/RageEffect/Spritesheets/RageEffect_Sheet_64x64.png",
	"regen": "res://assets/VividMotion23/RegenEffect/Spritesheets/RegenEffect_Sheet_64x64.png",
	"shield": "res://assets/VividMotion23/ShieldEffect/Spritesheets/ShieldEffect_Sheet_64x64.png",
	"shock": "res://assets/VividMotion23/ShockEffect/Spritesheets/ShockEffect_Sheet_64x64.png",
	"slow": "res://assets/VividMotion23/SlowEffect/Spritesheets/SlowEffect_Sheet_64x64.png",
	"stun": "res://assets/VividMotion23/StunEffect/Spritesheets/StunEffect_Sheet_64x64.png",
	"weaken": "res://assets/VividMotion23/WeakenEffect/Spritesheets/WeakenEffect_Sheet_64x64.png",
}
const ATMOSPHERIC_VFX_SHEET_PATHS := {
	"aurora": "res://assets/AleniaAtmospheric/Spritesheets/clima_aurora_boreal.png",
	"bubbles": "res://assets/AleniaAtmospheric/Spritesheets/clima_burbujas_explosivas.png",
	"caustics": "res://assets/AleniaAtmospheric/Spritesheets/clima_causticas.png",
	"embers": "res://assets/AleniaAtmospheric/Spritesheets/clima_chispas_fuego.png",
	"fireflies": "res://assets/AleniaAtmospheric/Spritesheets/clima_luciernagas_cozy.png",
	"fog": "res://assets/AleniaAtmospheric/Spritesheets/clima_niebla_espesa.png",
	"frost": "res://assets/AleniaAtmospheric/Spritesheets/clima_congelacion.png",
	"godrays": "res://assets/AleniaAtmospheric/Spritesheets/clima_godrays.png",
	"magic_wind": "res://assets/AleniaAtmospheric/Spritesheets/clima_viento_magico.png",
	"meteor": "res://assets/AleniaAtmospheric/Spritesheets/clima_meteoritos.png",
	"rain_splash": "res://assets/AleniaAtmospheric/Spritesheets/clima_lluvia_splash.png",
	"snow": "res://assets/AleniaAtmospheric/Spritesheets/clima_nieve_cinematica.png",
	"storm": "res://assets/AleniaAtmospheric/Spritesheets/clima_tormenta_electrica.png",
	"tornado": "res://assets/AleniaAtmospheric/Spritesheets/clima_tornado_epico.png",
	"wind": "res://assets/AleniaAtmospheric/Spritesheets/clima_viento_estetico.png",
}
const ATMOSPHERIC_FRAMES := 48
const FLAME_VFX_SCENE_PATH := "res://assets/BinbunVFX_Vol2/FlameFX/effects/fire/vfx_basic_fire_01.tscn"
const BEAM_VFX_SCENE_PATH := "res://assets/BinbunVFX/beam_vfx/effects/base/base_beam_vfx.tscn"
const SHIELD_VFX_SCENE_PATH := "res://assets/UserVFX/shield_vfx/main.tscn"
const TORNADO_VFX_SCENE_PATH := "res://assets/UserVFX/tornado_vfx/node_3d.tscn"

var _vfx_layer: Control
var _visual_registry: Variant
var _timer_owner: Node
var _container: SubViewportContainer
var _sub_viewport: SubViewport
var _root_3d: Node3D
var _camera: Camera3D
var _ambient_light: DirectionalLight3D
var _texture_cache: Dictionary = {}
var _pack_scene_cache: Dictionary = {}
var _elemental_scene_cache: Dictionary = {}
var _status_texture_cache: Dictionary = {}
var _atmospheric_texture_cache: Dictionary = {}
var _external_scene_cache: Dictionary = {}


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_timer_owner = dependencies.get("timer_owner") as Node
	_ensure_overlay()


func is_available() -> bool:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return false
	if not _ensure_overlay():
		return false
	if _status_vfx_available():
		return true
	if _elemental_magic_available() or _pack_vfx_available():
		return true
	if _visual_registry == null:
		return false
	for key in REQUIRED_TEXTURE_KEYS:
		if _max_texture(key) == null:
			return false
	return true


func required_texture_keys() -> Array[String]:
	return REQUIRED_TEXTURE_KEYS.duplicate()


func required_status_sheet_paths() -> Dictionary:
	return STATUS_VFX_SHEET_PATHS.duplicate()


func required_atmospheric_sheet_paths() -> Dictionary:
	return ATMOSPHERIC_VFX_SHEET_PATHS.duplicate()


func external_scene_paths() -> Dictionary:
	return {
		"flame": FLAME_VFX_SCENE_PATH,
		"beam": BEAM_VFX_SCENE_PATH,
		"shield": SHIELD_VFX_SCENE_PATH,
		"tornado": TORNADO_VFX_SCENE_PATH,
	}


func spawn_replay_impact(global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, _result_amount: int, intensity: int, screen_wide: bool) -> bool:
	if not is_available() or global_center == Vector2.ZERO:
		return false
	var kind := _clean_kind(clean_kind)
	var center := _global_to_overlay_local(global_center)
	var colors := _kind_colors(kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", Color.WHITE)
	var max_size := maxf(draw_size.x, draw_size.y)
	var basis_size := _replay_impact_basis_size(kind, draw_size, max_size)
	var base_size := basis_size * (2.25 + float(intensity) * 0.22)
	var duration := maxf(0.32, lifetime * 1.10)
	if _status_vfx_available():
		_spawn_status_replay_recipe(kind, center, draw_size, max_size, base_size, duration, intensity, screen_wide)
		_spawn_light(center, core, 2.9 + float(intensity) * 0.38, base_size * 1.24, duration * 0.76)
		return true
	if _elemental_magic_available() and _should_use_elemental_magic(kind):
		_spawn_elemental_replay_recipe(kind, center, max_size, base_size, duration, intensity, screen_wide)
		_spawn_light(center, core, 2.7 + float(intensity) * 0.34, base_size * 1.20, duration * 0.78)
		return true
	if _pack_vfx_available():
		var impact_scene := _pack_impact_scene_key(kind, intensity, screen_wide)
		var pack_size := Vector2(base_size, base_size) * (1.15 if screen_wide else 0.72)
		_spawn_pack_effect(impact_scene, center, kind, pack_size, duration, intensity, 0.0, Vector2.ZERO, 0.0, 0.0, 1.0)
		_spawn_pack_effect(_pack_hit_scene_key(kind), center, kind, pack_size * 0.58, duration * 0.74, intensity, 0.035, Vector2.ZERO, 0.0, 1.2, 0.82)
		_spawn_light(center, core, 2.4 + float(intensity) * 0.34, base_size * 1.15, duration * 0.65)
		if screen_wide:
			_spawn_pack_screen_wide(kind, center, duration, intensity)
		if kind == "gold":
			_spawn_coin_rain(center, max_size, duration, intensity, screen_wide)
		return true
	_spawn_light(center, core, 2.4 + float(intensity) * 0.34, base_size * 1.15, duration * 0.65)
	_spawn_flipbook(_impact_key(kind), center, Vector2(base_size, base_size), duration, Color(1, 1, 1, 0.95), 0.0, Vector2.ZERO, 1.12 + float(intensity) * 0.04, 0.0, 0.18)
	_spawn_flipbook("shockwave_ring", center, Vector2(base_size * 0.92, base_size * 0.92), duration * 0.78, Color(core.r, core.g, core.b, 0.82), 0.03, Vector2.ZERO, 1.52 + float(intensity) * 0.07, -0.8, 0.0)
	_spawn_flipbook(_mist_key(kind), center + Vector2(0.0, max_size * 0.08), Vector2(base_size * 1.10, base_size * 0.78), duration * 1.08, Color(accent.r, accent.g, accent.b, 0.36), 0.04, Vector2(0.0, -max_size * 0.10), 1.18, -1.2, 0.08)
	_spawn_burst_particles(kind, center, max_size, duration, intensity)
	if screen_wide:
		_spawn_screen_wide(kind, center, duration, intensity)
	if kind == "gold":
		_spawn_coin_rain(center, max_size, duration, intensity, false)
	return true


func spawn_armor_linger(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> bool:
	if not is_available() or global_center == Vector2.ZERO:
		return false
	var center := _global_to_overlay_local(global_center)
	var width := maxf(draw_size.x * 1.34, 260.0)
	var height := maxf(draw_size.y * 3.1, 150.0)
	if _status_vfx_available():
		_spawn_status_armor_linger(center, Vector2(width, height), lifetime, intensity)
		return true
	if _elemental_magic_available():
		var shell_size := Vector2(width, height) * (1.0 + float(intensity) * 0.045)
		_spawn_elemental_effect("area", center, "armor", shell_size, lifetime * 1.35, intensity, 0.0, Vector2.ZERO, 0.0, 0.75, 0.82)
		_spawn_elemental_effect("cast", center + Vector2(0.0, -height * 0.10), "armor", shell_size * 0.48, lifetime * 0.80, intensity, 0.08, Vector2.ZERO, 0.0, 1.5, 0.68)
		if _pack_vfx_available():
			_spawn_pack_effect("hit_02", center + Vector2(0.0, -height * 0.08), "armor", shell_size * 0.42, lifetime * 0.62, intensity, 0.10, Vector2.ZERO, 0.0, 1.9, 0.52)
		_spawn_light(center, Color(0.78, 0.92, 1.0, 1.0), 2.2 + float(intensity) * 0.24, width * 0.84, lifetime)
		return true
	if _pack_vfx_available():
		var shell_size := Vector2(width, height) * (1.0 + float(intensity) * 0.035)
		_spawn_pack_effect("impact_02", center, "armor", shell_size, lifetime, intensity, 0.0, Vector2.ZERO, 0.0, 0.9, 0.86)
		_spawn_pack_effect("hit_02", center + Vector2(0.0, -height * 0.10), "armor", shell_size * 0.66, lifetime * 0.72, intensity, 0.08, Vector2.ZERO, 0.0, 1.4, 0.64)
		_spawn_light(center, Color(0.78, 0.92, 1.0, 1.0), 1.9 + float(intensity) * 0.22, width * 0.80, lifetime)
		return true
	_spawn_light(center, Color(0.78, 0.92, 1.0, 1.0), 1.9 + float(intensity) * 0.22, width * 0.80, lifetime)
	_spawn_flipbook("armor_shell", center, Vector2(width, height), lifetime * 1.24, Color(0.82, 0.94, 1.0, 0.74), 0.0, Vector2.ZERO, 1.05, 1.0, 0.0)
	_spawn_flipbook("shockwave_ring", center, Vector2(width * 0.82, height * 1.12), lifetime * 0.86, Color(0.88, 0.98, 1.0, 0.72), 0.08, Vector2.ZERO, 1.24, 0.6, 0.0)
	for i in range(5 + mini(intensity, 8)):
		var x := (float(i) / float(maxi(1, 4 + mini(intensity, 8))) - 0.5) * width
		_spawn_flipbook("light_rays", center + Vector2(x, -height * 0.18 + sin(float(i)) * 10.0), Vector2(width * 0.26, 28.0), lifetime * 0.42, Color(0.92, 0.98, 1.0, 0.72), lifetime * (0.08 + float(i % 4) * 0.035), Vector2(20.0, 0.0), 0.64, 1.4, sin(float(i)) * 0.28)
	return true


func spawn_mastery_cast_sequence(orb_id: int, source_global: Vector2, target_global: Vector2, spool_lifetime: float, travel_lifetime: float, result_amount: int) -> bool:
	if not is_available() or source_global == Vector2.ZERO or target_global == Vector2.ZERO:
		return false
	var kind := _kind_for_orb(orb_id)
	var source := _global_to_overlay_local(source_global)
	var target := _global_to_overlay_local(target_global)
	var delta := target - source
	if delta.length() <= 1.0:
		return false
	var intensity := clampi(2 + int(floor(float(maxi(0, result_amount)) / 8.0)), 2, 8)
	var colors := _kind_colors(kind)
	var core: Color = colors.get("core", Color.WHITE)
	var accent: Color = colors.get("accent", Color.WHITE)
	var spool_size := Vector2(150, 150) * (1.0 + float(intensity) * 0.08)
	if _status_vfx_available():
		_spawn_status_cast_recipe(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core, accent)
		return true
	if _elemental_magic_available() and _should_use_elemental_magic(kind):
		_spawn_elemental_cast_recipe(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core)
		return true
	if _pack_vfx_available():
		var travel_duration := maxf(0.18, travel_lifetime)
		var pack_angle := delta.angle()
		var travel_size := Vector2(104 + intensity * 15, 74 + intensity * 9)
		_spawn_light(source, core, 1.8 + float(intensity) * 0.18, spool_size.x * 1.2, spool_lifetime * 1.2)
		_spawn_pack_effect(_pack_hit_scene_key(kind), source, kind, spool_size * 0.92, spool_lifetime * 1.10, intensity, 0.0, Vector2.ZERO, pack_angle, 0.7, 0.78)
		_spawn_pack_effect("hit_01", source, kind, travel_size, travel_duration, intensity, spool_lifetime, delta, pack_angle, 1.3, 0.58)
		_spawn_pack_effect(_pack_impact_scene_key(kind, intensity, false), target, kind, spool_size * (1.08 + float(intensity) * 0.05), travel_duration * 1.2, intensity, spool_lifetime + travel_duration * 0.86, Vector2.ZERO, pack_angle, 1.8, 0.96)
		_spawn_camera_kick(delta.normalized() * (4.0 + float(intensity)), spool_lifetime + travel_duration * 0.85)
		return true
	_spawn_light(source, core, 1.8 + float(intensity) * 0.18, spool_size.x * 1.2, spool_lifetime * 1.2)
	_spawn_flipbook(_impact_key(kind), source, spool_size, spool_lifetime * 1.15, Color(1, 1, 1, 0.88), 0.0, Vector2.ZERO, 0.92, 0.4, 0.22)
	_spawn_flipbook("shockwave_ring", source, spool_size * 0.78, spool_lifetime, Color(accent.r, accent.g, accent.b, 0.72), 0.05, Vector2.ZERO, 1.34, 0.2, 0.0)
	var projectile_key := _projectile_key(kind)
	var projectile_size := Vector2(170 + intensity * 18, 96 + intensity * 8)
	var fallback_angle := delta.angle()
	_spawn_flipbook(projectile_key, source, projectile_size, maxf(0.18, travel_lifetime), Color(1, 1, 1, 0.98), spool_lifetime, delta, 0.84, 1.8, fallback_angle)
	var trail_key := _trail_key(kind)
	var trail_count := 10 + intensity * 4
	for i in range(trail_count):
		var progress := float(i) / float(maxi(1, trail_count - 1))
		var lane := Vector2(-delta.y, delta.x).normalized() * sin(float(i) * 2.1) * (14.0 + float(intensity) * 3.0)
		var start := source + delta * progress * 0.72 + lane
		_spawn_flipbook(trail_key, start, Vector2(72 + intensity * 6, 44 + intensity * 4), travel_lifetime * 0.72, Color(accent.r, accent.g, accent.b, 0.58), spool_lifetime + travel_lifetime * progress * 0.62, delta * (0.30 + progress * 0.24), 0.42, 0.6, fallback_angle + sin(float(i)) * 0.3)
	_spawn_camera_kick(delta.normalized() * (4.0 + float(intensity)), spool_lifetime + travel_lifetime * 0.85)
	return true


func spawn_mastery_beam(orb_id: int, source_global: Vector2, target_global: Vector2, lifetime: float) -> bool:
	if not is_available() or source_global == Vector2.ZERO or target_global == Vector2.ZERO:
		return false
	var kind := _kind_for_orb(orb_id)
	var source := _global_to_overlay_local(source_global)
	var target := _global_to_overlay_local(target_global)
	var delta := target - source
	if delta.length() <= 1.0:
		return false
	var colors := _kind_colors(kind)
	var core: Color = colors.get("core", Color.WHITE)
	var angle := delta.angle()
	var length := delta.length()
	var beam_intensity := clampi(int(round(length / 110.0)), 2, 8)
	if _status_vfx_available():
		_spawn_status_beam_recipe(kind, source, delta, lifetime, beam_intensity, angle)
		return true
	if _elemental_magic_available() and _should_use_elemental_magic(kind):
		_spawn_elemental_beam_recipe(kind, source, delta, lifetime, beam_intensity, angle)
		return true
	if _pack_vfx_available():
		_spawn_pack_effect("hit_01", source, kind, Vector2(116 + beam_intensity * 8, 76 + beam_intensity * 5), lifetime, beam_intensity, 0.0, delta, angle, 1.3, 0.62)
		return true
	_spawn_flipbook("light_rays", source + delta * 0.5, Vector2(length, 44.0), lifetime * 0.82, Color(core.r, core.g, core.b, 0.72), 0.0, Vector2.ZERO, 0.62, 0.5, angle)
	_spawn_flipbook(_projectile_key(kind), source, Vector2(126, 72), lifetime, Color(1, 1, 1, 0.86), 0.0, delta, 0.72, 1.4, angle)
	return true


func spawn_enemy_attack_cue(source_global: Vector2, lifetime: float) -> bool:
	if not is_available() or source_global == Vector2.ZERO:
		return false
	var source := _global_to_overlay_local(source_global)
	if _pack_vfx_available():
		_spawn_pack_effect("hit_02", source, "damage", Vector2(150, 150), lifetime * 1.10, 3, 0.0, Vector2.ZERO, -0.12, 1.0, 0.80)
		_spawn_light(source, Color(1.0, 0.34, 0.48, 1.0), 1.5, 160.0, lifetime)
		return true
	_spawn_light(source, Color(1.0, 0.34, 0.48, 1.0), 1.5, 160.0, lifetime)
	_spawn_flipbook("enemy_attack", source, Vector2(180, 180), lifetime * 1.15, Color(1, 1, 1, 0.88), 0.0, Vector2.ZERO, 1.04, 1.0, -0.12)
	return true


func spawn_enemy_attack_travel(source_global: Vector2, target_global: Vector2, lifetime: float) -> bool:
	if not is_available() or source_global == Vector2.ZERO or target_global == Vector2.ZERO:
		return false
	var source := _global_to_overlay_local(source_global)
	var target := _global_to_overlay_local(target_global)
	var delta := target - source
	if delta.length() <= 1.0:
		return false
	var angle := delta.angle()
	if _pack_vfx_available():
		var intensity := clampi(int(round(delta.length() / 120.0)), 2, 8)
		_spawn_pack_effect("hit_01", source, "damage", Vector2(112 + intensity * 7, 68 + intensity * 5), lifetime, intensity, 0.0, delta, angle, 1.3, 0.66)
		return true
	_spawn_flipbook("enemy_attack", source, Vector2(150, 88), lifetime, Color(1, 1, 1, 0.94), 0.0, delta, 0.78, 1.5, angle)
	_spawn_flipbook("light_rays", source + delta * 0.5, Vector2(delta.length(), 34.0), lifetime * 0.74, Color(1.0, 0.35, 0.52, 0.56), 0.0, Vector2.ZERO, 0.50, 0.3, angle)
	return true


func spawn_enemy_attack_impact(global_center: Vector2, blocked: bool, amount: int, lifetime: float) -> bool:
	if blocked:
		return spawn_replay_impact(global_center, "armor", Vector2(92, 92), lifetime, amount, 4, false)
	return spawn_replay_impact(global_center, "damage", Vector2(96, 96), lifetime, amount, 4, false)


func spawn_generic(global_center: Vector2, draw_size: Vector2, lifetime: float, color: Color = Color.WHITE) -> bool:
	if not is_available() or global_center == Vector2.ZERO:
		return false
	var center := _global_to_overlay_local(global_center)
	var size := Vector2(maxf(draw_size.x, draw_size.y), maxf(draw_size.x, draw_size.y)) * 1.8
	if _pack_vfx_available():
		_spawn_pack_effect("hit_01", center, "generic", size, lifetime * 1.10, 3, 0.0, Vector2.ZERO, 0.0, 0.0, color.a)
		return true
	_spawn_flipbook("orb_clear", center, size, lifetime * 1.15, color, 0.0, Vector2.ZERO, 1.12, 0.0, 0.0)
	return true


func _ensure_overlay() -> bool:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return false
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return false
	if _container != null and is_instance_valid(_container):
		_sync_overlay_size(layer_size)
		return true
	_container = SubViewportContainer.new()
	_container.name = "CombatMaxVfx3DOverlay"
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_container.z_index = OVERLAY_Z_INDEX
	_container.anchor_left = 0.0
	_container.anchor_top = 0.0
	_container.anchor_right = 0.0
	_container.anchor_bottom = 0.0
	_container.position = Vector2.ZERO
	_container.size = layer_size
	_container.stretch = true
	_vfx_layer.add_child(_container)

	_sub_viewport = SubViewport.new()
	_sub_viewport.name = "CombatMaxVfxViewport"
	_sub_viewport.transparent_bg = true
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_sub_viewport.size = Vector2i(int(layer_size.x), int(layer_size.y))
	_container.add_child(_sub_viewport)

	_root_3d = Node3D.new()
	_root_3d.name = "CombatMaxVfxRoot3D"
	_sub_viewport.add_child(_root_3d)

	_camera = Camera3D.new()
	_camera.name = "CombatMaxVfxCamera"
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.current = true
	_root_3d.add_child(_camera)

	_ambient_light = DirectionalLight3D.new()
	_ambient_light.name = "CombatMaxVfxKeyLight"
	_ambient_light.light_color = Color(0.74, 0.82, 1.0, 1.0)
	_ambient_light.light_energy = 0.18
	_ambient_light.rotation_degrees = Vector3(-58.0, 18.0, 0.0)
	_root_3d.add_child(_ambient_light)
	_sync_overlay_size(layer_size)
	return true


func _sync_overlay_size(layer_size: Vector2) -> void:
	if _container != null and is_instance_valid(_container):
		_container.size = layer_size
	if _sub_viewport != null and is_instance_valid(_sub_viewport):
		var next_size := Vector2i(maxi(1, int(layer_size.x)), maxi(1, int(layer_size.y)))
		if _sub_viewport.size != next_size:
			_sub_viewport.size = next_size
	if _camera != null and is_instance_valid(_camera):
		_camera.size = layer_size.y
		_camera.position = Vector3(layer_size.x * 0.5, layer_size.y * 0.5, 1000.0)
		_camera.rotation = Vector3.ZERO


func _status_vfx_available() -> bool:
	for key in ["burn", "freeze", "poison", "heal", "shield", "blessed"]:
		if _status_texture(key) == null:
			return false
	return true


func _atmospheric_vfx_available() -> bool:
	for key in ["embers", "snow", "wind", "magic_wind", "godrays"]:
		if _atmospheric_texture(key) == null:
			return false
	return true


func _status_texture(key: String) -> Texture2D:
	if _status_texture_cache.has(key):
		return _status_texture_cache[key]
	var path := String(STATUS_VFX_SHEET_PATHS.get(key, ""))
	if path == "":
		return null
	var imported_texture := load(path) as Texture2D
	if imported_texture != null:
		_status_texture_cache[key] = imported_texture
		return imported_texture
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var texture := ImageTexture.create_from_image(image)
	if texture != null:
		_status_texture_cache[key] = texture
	return texture


func _atmospheric_texture(key: String) -> Texture2D:
	if _atmospheric_texture_cache.has(key):
		return _atmospheric_texture_cache[key]
	var path := String(ATMOSPHERIC_VFX_SHEET_PATHS.get(key, ""))
	if path == "":
		return null
	var imported_texture := load(path) as Texture2D
	if imported_texture != null:
		_atmospheric_texture_cache[key] = imported_texture
		return imported_texture
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var texture := ImageTexture.create_from_image(image)
	if texture != null:
		_atmospheric_texture_cache[key] = texture
	return texture


func _external_scene(key: String, path: String) -> PackedScene:
	if _external_scene_cache.has(key):
		return _external_scene_cache[key]
	var scene := load(path) as PackedScene
	if scene != null:
		_external_scene_cache[key] = scene
	return scene


func _flame_scene() -> PackedScene:
	return _external_scene("flame", FLAME_VFX_SCENE_PATH)


func _beam_scene() -> PackedScene:
	return _external_scene("beam", BEAM_VFX_SCENE_PATH)


func _shield_scene() -> PackedScene:
	return _external_scene("shield", SHIELD_VFX_SCENE_PATH)


func _tornado_scene() -> PackedScene:
	return _external_scene("tornado", TORNADO_VFX_SCENE_PATH)


func _spawn_status_replay_recipe(kind: String, center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	var clean_kind := _clean_kind(kind)
	var status_size := Vector2(base_size, base_size) * (1.36 if screen_wide else 0.86)
	var colors := _kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	var accent: Color = colors.get("accent", Color.WHITE)
	if clean_kind == "fire":
		_spawn_fire_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)
		return
	if clean_kind == "ice":
		_spawn_ice_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)
		return
	if clean_kind == "earth":
		_spawn_earth_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)
		return
	_spawn_atmospheric_replay_layer(clean_kind, center, max_size, base_size, duration, intensity, screen_wide)
	match clean_kind:
		"fire":
			_spawn_status_flipbook("burn", center, status_size * 0.46, duration * 0.96, Color(1.0, 0.92, 0.74, 0.78), 0.0, Vector2.ZERO, 1.10, 1.9, 0.0, 1)
			_spawn_flame_scene(center + Vector2(0.0, max_size * 0.05), status_size * 0.74, duration * 0.92, intensity, 0.02, Vector2(0.0, -max_size * 0.10), 2.0, 0.90)
			_spawn_status_flipbook("rage", center + Vector2(0.0, -max_size * 0.10), status_size * 0.30, duration * 0.60, Color(1.0, 0.42, 0.14, 0.50), 0.08, Vector2.ZERO, 1.10, 2.3, 0.12, 1)
			_spawn_pack_layer(_pack_impact_scene_key("fire", intensity, screen_wide), center, "fire", status_size * 0.46, duration * 0.58, intensity, 0.08, 0.10, 2.7, 0.58)
		"ice":
			_spawn_status_flipbook("freeze", center, status_size * 0.42, duration * 0.98, Color(0.86, 0.98, 1.0, 0.74), 0.0, Vector2(0.0, max_size * 0.04), 1.10, 1.9, -0.05, 1)
			_spawn_status_flipbook("slow", center + Vector2(0.0, -max_size * 0.12), status_size * 0.32, duration * 0.82, Color(0.50, 0.88, 1.0, 0.46), 0.06, Vector2(0.0, max_size * 0.10), 1.04, 2.1, 0.08, 1)
			_spawn_status_flipbook("shock", center + Vector2(-max_size * 0.12, -max_size * 0.04), status_size * 0.26, duration * 0.52, Color(0.78, 0.96, 1.0, 0.36), 0.16, Vector2(max_size * 0.16, -max_size * 0.04), 0.76, 2.4, -0.20, 1)
			_spawn_pack_layer("impact_02", center, "ice", status_size * 0.44, duration * 0.68, intensity, 0.10, 0.0, 2.6, 0.42)
		"earth":
			_spawn_atmospheric_flipbook("rain_splash", center + Vector2(0.0, max_size * 0.12), status_size * Vector2(0.82, 0.40), duration * 0.76, Color(0.52, 0.82, 0.30, 0.34), 0.0, Vector2(0.0, -max_size * 0.06), 0.72, 1.7, 0.0, 1)
			_spawn_atmospheric_flipbook("bubbles", center + Vector2(0.0, max_size * 0.02), status_size * Vector2(0.46, 0.36), duration * 0.66, Color(0.50, 1.0, 0.22, 0.30), 0.08, Vector2(0.0, -max_size * 0.16), 0.54, 2.0, 0.0, 1)
			_spawn_flipbook("dust_puff", center + Vector2(0.0, max_size * 0.18), status_size * Vector2(0.52, 0.28), duration * 0.72, Color(0.54, 0.42, 0.28, 0.36), 0.08, Vector2(0.0, -max_size * 0.08), 0.82, 1.9, 0.18)
			_spawn_flipbook("stone_chunks", center + Vector2(-max_size * 0.08, max_size * 0.12), status_size * Vector2(0.28, 0.34), duration * 0.56, Color(0.64, 0.54, 0.38, 0.46), 0.10, Vector2(max_size * 0.14, -max_size * 0.12), 0.54, 2.0, -0.20)
			_spawn_pack_layer("impact_01", center + Vector2(0.0, max_size * 0.10), "earth", status_size * 0.42, duration * 0.70, intensity, 0.14, 0.0, 2.4, 0.42)
		"heart":
			_spawn_status_flipbook("heal", center, status_size * Vector2(0.38, 0.52), duration * 0.98, Color(0.84, 1.0, 0.80, 0.66), 0.0, Vector2(0.0, -max_size * 0.24), 1.06, 1.9, 0.0, 1)
			_spawn_status_flipbook("regen", center + Vector2(0.0, max_size * 0.12), status_size * 0.30, duration * 0.82, Color(0.48, 1.0, 0.60, 0.52), 0.08, Vector2(0.0, -max_size * 0.30), 0.92, 2.2, 0.08, 1)
			_spawn_pack_layer("hit_02", center + Vector2(0.0, -max_size * 0.05), "heart", status_size * 0.28, duration * 0.54, intensity, 0.16, 0.0, 2.6, 0.34)
		"armor":
			_spawn_status_flipbook("shield", center, status_size * Vector2(0.50, 0.42), duration * 0.98, Color(0.86, 0.96, 1.0, 0.66), 0.0, Vector2.ZERO, 1.08, 1.9, 0.0, 1)
			_spawn_shield_scene(center, status_size * Vector2(0.92, 0.62), duration * 1.10, intensity, 0.02, Vector2.ZERO, 2.1)
			_spawn_status_flipbook("armor", center + Vector2(0.0, -max_size * 0.06), status_size * 0.28, duration * 0.64, Color(0.62, 0.86, 1.0, 0.44), 0.12, Vector2.ZERO, 0.94, 2.6, 0.0, 1)
			_spawn_pack_layer("impact_02", center, "armor", status_size * 0.38, duration * 0.58, intensity, 0.12, 0.0, 2.7, 0.42)
		"gold":
			_spawn_status_flipbook("blessed", center, status_size * 0.42, duration * 0.86, Color(1.0, 0.86, 0.38, 0.62), 0.0, Vector2.ZERO, 1.10, 1.9, 0.0, 1)
			_spawn_status_flipbook("haste", center + Vector2(0.0, -max_size * 0.08), status_size * 0.28, duration * 0.58, Color(1.0, 0.96, 0.44, 0.42), 0.08, Vector2.ZERO, 1.05, 2.2, 0.12, 1)
			_spawn_coin_rain(center, max_size, duration, intensity, screen_wide)
			_spawn_pack_layer("hit_01", center, "gold", status_size * 0.30, duration * 0.46, intensity, 0.12, 0.22, 2.5, 0.42)
		"damage":
			_spawn_status_flipbook("bleed", center, status_size * 0.40, duration * 0.72, Color(1.0, 0.56, 0.48, 0.62), 0.0, Vector2.ZERO, 1.08, 1.9, -0.10, 1)
			_spawn_status_flipbook("stun", center, status_size * 0.26, duration * 0.48, Color(1.0, 0.90, 0.42, 0.34), 0.08, Vector2.ZERO, 0.88, 2.2, 0.16, 1)
			_spawn_pack_layer(_pack_impact_scene_key("damage", intensity, screen_wide), center, "damage", status_size * 0.46, duration * 0.56, intensity, 0.04, -0.08, 2.5, 0.54)
		_:
			_spawn_status_flipbook(_status_sheet_key(clean_kind), center, status_size * 0.42, duration, Color(core.r, core.g, core.b, 0.62), 0.0, Vector2.ZERO, 1.10, 1.9, 0.0, 1)
	if screen_wide:
		_spawn_status_screen_wide(clean_kind, center, duration, intensity)
	_spawn_burst_particles(clean_kind, center, max_size, duration * 0.74, intensity)
	_spawn_light(center, core, 2.6 + float(intensity) * 0.32, base_size * 1.05, duration * 0.64)


func _fire_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	if screen_wide or intensity >= 5:
		return 3
	if intensity >= 3:
		return 2
	return 1


func _ice_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	if screen_wide or intensity >= 6:
		return 3
	if intensity >= 3:
		return 2
	return 1


func _earth_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	if screen_wide or intensity >= 6:
		return 3
	if intensity >= 3:
		return 2
	return 1


func _replay_impact_basis_size(kind: String, draw_size: Vector2, fallback_size: float) -> float:
	if _clean_kind(kind) != "fire":
		return fallback_size
	if draw_size.x <= 1.0 or draw_size.y <= 1.0:
		return fallback_size
	var wide_ratio := maxf(draw_size.x, draw_size.y) / maxf(1.0, minf(draw_size.x, draw_size.y))
	if wide_ratio < 1.45:
		return fallback_size
	var geometric_size := sqrt(draw_size.x * draw_size.y) * 0.64
	var short_side_size := minf(draw_size.x, draw_size.y) * 1.18
	return maxf(96.0, maxf(geometric_size, short_side_size))


func _spawn_fire_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	var tier := _fire_vfx_tier(intensity, screen_wide)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var wide_target := draw_size.x > draw_size.y * 1.35
	var fire_center := center + Vector2(0.0, draw_size.y * (0.20 if wide_target else 0.0))
	var impact_extent := maxf(124.0, base_size * 0.54) if tier == 1 else maxf(170.0, base_size * (0.70 + float(tier) * 0.12))
	var impact_size := Vector2(impact_extent, impact_extent)
	var area_cover_size := Vector2(
		maxf(draw_size.x * 1.04, impact_extent * (0.88 if wide_target else 1.0)),
		maxf(draw_size.y * (1.86 if wide_target else 1.10), impact_extent * (0.58 if wide_target else 0.54))
	)
	var aura_size := Vector2(
		maxf(area_cover_size.x, base_size * (1.05 + float(tier) * 0.20)),
		maxf(area_cover_size.y, base_size * (0.54 + float(tier) * 0.06))
	)
	var area_alpha := 0.30 if wide_target else 0.48
	_spawn_atmospheric_flipbook("fog", fire_center, area_cover_size * Vector2(1.06, 1.18), duration * 1.20, Color(1.0, 0.12, 0.03, 0.16 if wide_target else 0.22), 0.0, Vector2(0.0, -max_size * 0.04), 1.03, 0.15, 0.0, 1)
	_spawn_atmospheric_flipbook("embers", fire_center, aura_size, duration * 1.22, Color(1.0, 0.48, 0.18, area_alpha), 0.0, Vector2(0.0, -max_size * 0.08), 1.08, 0.35, 0.0, 1)
	if wide_target:
		var base_center := center + Vector2(0.0, draw_size.y * 0.48)
		_spawn_atmospheric_flipbook("fog", base_center, area_cover_size * Vector2(1.04, 0.82), duration * 1.24, Color(1.0, 0.08, 0.02, 0.18), 0.02, Vector2(0.0, -draw_size.y * 0.20), 1.04, 0.55, 0.0, 1)
		_spawn_atmospheric_flipbook("embers", base_center, area_cover_size * Vector2(1.02, 0.72), duration * 1.12, Color(1.0, 0.26, 0.04, 0.28), 0.05, Vector2(0.0, -draw_size.y * 0.24), 1.02, 0.80, 0.0, 2)
	_spawn_status_flipbook("burn", fire_center, impact_size * 0.62, duration * 0.96, Color(1.0, 0.72, 0.22, 0.72), 0.0, Vector2.ZERO, 1.18, 1.8, 0.04, 1)
	if not wide_target:
		_spawn_flame_scene(fire_center + Vector2(0.0, max_size * 0.05), impact_size * 0.92, duration * 1.00, layer_intensity, 0.02, Vector2(0.0, -max_size * 0.08), 2.0, 0.96)
	var weak_impact_scale := 0.72 if tier == 1 else 1.0
	_spawn_pack_layer("impact_01", fire_center, "fire", impact_size * (0.86 * weak_impact_scale), duration * 0.64, layer_intensity, 0.06, 0.10, 2.6, 0.56 if tier == 1 else 0.72)
	_spawn_pack_layer("hit_01", fire_center + Vector2(max_size * 0.09, -max_size * 0.08), "fire", impact_size * (0.50 * weak_impact_scale), duration * 0.48, layer_intensity, 0.13, -0.28, 2.9, 0.42 if tier == 1 else 0.58)
	_spawn_burst_particles("fire", fire_center, maxf(max_size * 0.78, impact_extent * 0.52) if tier == 1 else maxf(max_size * 1.30, impact_extent * 0.62), duration * 0.88, layer_intensity)
	_spawn_fire_spark_spray(fire_center, maxf(max_size * 0.74, impact_extent * 0.48) if tier == 1 else maxf(max_size * 1.20, impact_extent * 0.58), duration * 0.78, layer_intensity, 0.02, tier)
	_spawn_light(fire_center, Color(1.0, 0.56, 0.14, 1.0), (2.0 + float(layer_intensity) * 0.24) if tier == 1 else (3.0 + float(layer_intensity) * 0.36), impact_extent * (0.86 if tier == 1 else 1.08), duration * 0.72)
	if tier == 1:
		_spawn_fireball_impact_layers(fire_center, impact_size, duration, layer_intensity, max_size)
	if tier >= 2:
		_spawn_atmospheric_flipbook("embers", fire_center + Vector2(0.0, -max_size * 0.16), aura_size * Vector2(1.22, 0.82), duration * 1.06, Color(1.0, 0.28, 0.06, 0.36), duration * 0.03, Vector2(0.0, -max_size * 0.10), 1.03, 0.60, 0.04, 1)
		_spawn_atmospheric_flipbook("embers", fire_center + Vector2(-max_size * 0.18, -max_size * 0.04), impact_size * Vector2(1.05, 0.60), duration * 0.76, Color(1.0, 0.42, 0.12, 0.30), duration * 0.08, Vector2(max_size * 0.30, -max_size * 0.04), 0.88, 1.2, -0.10, 1)
		_spawn_status_flipbook("rage", fire_center + Vector2(0.0, -max_size * 0.12), impact_size * 0.38, duration * 0.74, Color(1.0, 0.30, 0.08, 0.48), duration * 0.08, Vector2.ZERO, 1.10, 2.4, 0.10, 1)
		_spawn_pack_layer("hit_01", fire_center + Vector2(-max_size * 0.12, max_size * 0.02), "fire", impact_size * 0.62, duration * 0.54, layer_intensity + 1, 0.17, 0.34, 3.0, 0.52)
		_spawn_burst_particles("fire", fire_center, maxf(max_size * 1.75, impact_extent * 0.82), duration * 0.76, layer_intensity + 1)
		_spawn_fire_spark_spray(fire_center, maxf(max_size * 1.60, impact_extent * 0.76), duration * 0.72, layer_intensity + 1, duration * 0.08, tier)
	if tier >= 3:
		var wide_size := Vector2(maxf(area_cover_size.x, base_size * 1.24), maxf(area_cover_size.y * 1.18, base_size * 0.88))
		if not wide_target:
			_spawn_fire_aurora_layer(fire_center, duration * 1.36, intensity, 0.0, 0.50)
			_spawn_fire_screen_ember_field(fire_center + Vector2(0.0, _vfx_layer_size().y * 0.20), duration * 1.18, layer_intensity + 1, 0.0, 0.36)
		_spawn_fire_meteor_impact_layers(fire_center, wide_size, duration, layer_intensity, 0.0, wide_target)
		_spawn_atmospheric_flipbook("embers", fire_center + Vector2(0.0, -max_size * 0.06), wide_size * Vector2(1.06, 0.80), duration * 1.22, Color(1.0, 0.24, 0.04, 0.24 if wide_target else 0.34), 0.02, Vector2(0.0, -max_size * 0.08), 1.04, -0.4, 0.0, 2)
		if not wide_target:
			_spawn_flame_scene(fire_center + Vector2(0.0, max_size * 0.10), wide_size * Vector2(0.82, 0.92), duration * 1.18, layer_intensity + 2, 0.04, Vector2(0.0, -max_size * 0.06), 2.6, 0.92)
			_spawn_pack_layer("big_impact_01", fire_center, "fire", wide_size * Vector2(0.82, 0.96), duration * 0.84, layer_intensity + 2, 0.08, 0.06, 3.3, 0.68)
		else:
			_spawn_fire_fragmented_impact_cluster(fire_center, wide_size * Vector2(0.92, 0.68), duration * 0.78, layer_intensity + 2, duration * 0.08, 0.62)
		_spawn_burst_particles("fire", fire_center, maxf(base_size * 1.12, max_size * 3.0), duration * 0.94, layer_intensity + 2)
		_spawn_fire_spark_spray(fire_center, maxf(base_size * 0.98, max_size * 2.60), duration * 0.92, layer_intensity + 2, duration * 0.04, tier)
		_spawn_light(fire_center, Color(1.0, 0.32, 0.06, 1.0), 4.2 + float(layer_intensity) * 0.42, wide_size.x * 0.62, duration * 0.82)


func _spawn_fire_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	var tier := _fire_vfx_tier(intensity)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var source_size := spool_size * (1.02 + float(tier) * 0.12)
	var impact_extent := maxf(142.0, maxf(source_size.x, source_size.y) * 0.72) if tier == 1 else maxf(190.0, maxf(source_size.x, source_size.y) * (1.10 + float(tier) * 0.16))
	var impact_size := Vector2(impact_extent, impact_extent)
	var impact_delay := launch_delay + travel_duration * 0.82
	_spawn_light(source, core, 3.8 + float(layer_intensity) * 0.36, source_size.x * 2.05, spool_duration * 1.24)
	_spawn_atmospheric_flipbook("embers", source, source_size * Vector2(2.18, 1.36), spool_duration * 1.44, Color(1.0, 0.34, 0.08, 0.72), 0.0, Vector2(0.0, -22.0), 1.16, 0.66, angle, 2)
	_spawn_atmospheric_flipbook("embers", source + Vector2(0.0, -18.0), source_size * Vector2(1.64, 1.08), spool_duration * 1.12, Color(1.0, 0.18, 0.03, 0.46), spool_duration * 0.08, Vector2(0.0, -34.0), 1.04, 0.92, angle + 0.10, 1)
	_spawn_atmospheric_flipbook("embers", source + Vector2(0.0, -10.0), source_size * Vector2(1.28, 0.82), spool_duration * 0.86, Color(1.0, 0.36, 0.08, 0.32), spool_duration * 0.12, Vector2(0.0, -20.0), 0.88, 1.05, angle, 1)
	_spawn_status_flipbook("burn", source, source_size * 0.88, spool_duration * 1.02, Color(1.0, 0.68, 0.18, 0.90), 0.0, Vector2.ZERO, 1.26, 1.0, angle, 1)
	_spawn_flame_scene(source, source_size * 1.34, spool_duration * 1.18, layer_intensity + 1, 0.02, Vector2(0.0, -22.0), 1.45, 1.0)
	_spawn_pack_layer("hit_01", source, "fire", source_size * 0.86, spool_duration * 0.66, layer_intensity + 1, 0.08, angle, 1.6, 0.70)
	_spawn_fire_spark_spray(source, source_size.x * 1.04, spool_duration * 0.86, layer_intensity + 1, 0.02, tier + 1)
	_spawn_fire_ember_lane(source, delta, launch_delay, travel_duration, layer_intensity, angle, tier)
	_spawn_status_path_afterimage("fire", source, delta, launch_delay, travel_duration, layer_intensity, angle)
	_spawn_beam_effect(source, delta, "fire", travel_duration * 1.06, layer_intensity, launch_delay, 1.08 + float(tier) * 0.12)
	_spawn_status_flipbook("burn", source, Vector2(142 + layer_intensity * 18, 92 + layer_intensity * 9), travel_duration * 1.04, Color(1.0, 0.58, 0.18, 0.50), launch_delay, delta, 0.84, 2.3, angle, 1)
	if tier == 1:
		_spawn_fireball_spell_layers(source, target, delta, source_size, impact_size, launch_delay, travel_duration, layer_intensity, angle)
	if tier < 3:
		_spawn_flame_scene(target, impact_size * (0.58 if tier == 1 else 0.82), travel_duration * 1.18, layer_intensity, impact_delay, Vector2.ZERO, 2.8, 0.62 if tier == 1 else 0.96)
	_spawn_pack_layer("impact_01", target, "fire", impact_size * (0.52 if tier == 1 else 0.72), travel_duration * 0.66, layer_intensity, impact_delay + travel_duration * 0.03, angle, 3.0, 0.44 if tier == 1 else 0.68)
	_spawn_status_flipbook("rage", target + Vector2(0.0, -impact_extent * 0.06), impact_size * (0.24 if tier == 1 else 0.34), travel_duration * 0.90, Color(1.0, 0.30, 0.08, 0.30 if tier == 1 else 0.48), impact_delay + travel_duration * 0.02, Vector2.ZERO, 1.06 if tier == 1 else 1.12, 3.2, angle, 1)
	_spawn_burst_particles("fire", target, impact_extent * (0.42 if tier == 1 else 0.62), travel_duration * 0.82, layer_intensity)
	_spawn_fire_spark_spray(target, impact_extent * (0.46 if tier == 1 else 0.68), travel_duration * 0.78, layer_intensity, impact_delay, tier)
	_spawn_light(target, Color(1.0, 0.46, 0.10, 1.0), (2.2 + float(layer_intensity) * 0.24) if tier == 1 else (3.2 + float(layer_intensity) * 0.34), impact_extent * (0.86 if tier == 1 else 1.12), travel_duration * 0.78)
	if tier >= 2:
		_spawn_fire_screen_ember_field(source + delta * 0.50, travel_duration * 1.22, layer_intensity, launch_delay + travel_duration * 0.03, 0.28)
		_spawn_atmospheric_flipbook("embers", source + delta * 0.50 + normal * 12.0, Vector2(delta.length() * 1.04, 118.0 + float(layer_intensity) * 12.0), travel_duration * 1.18, Color(1.0, 0.30, 0.06, 0.36), launch_delay + travel_duration * 0.04, Vector2.ZERO, 0.98, 1.05, angle + 0.04, 1)
		_spawn_atmospheric_flipbook("embers", source + delta * 0.52 - normal * 12.0, Vector2(delta.length() * 0.88, 88.0 + float(layer_intensity) * 8.0), travel_duration * 0.92, Color(1.0, 0.46, 0.14, 0.30), launch_delay + travel_duration * 0.12, Vector2.ZERO, 0.92, 1.15, angle - 0.05, 1)
		_spawn_beam_effect(source + normal * 8.0, delta - normal * 6.0, "fire", travel_duration * 0.90, layer_intensity + 1, launch_delay + travel_duration * 0.04, 0.82 + float(tier) * 0.08)
		_spawn_pack_layer("hit_01", target + normal * 12.0, "fire", impact_size * 0.58, travel_duration * 0.48, layer_intensity + 1, impact_delay + travel_duration * 0.08, angle + 0.18, 3.1, 0.56)
		_spawn_burst_particles("fire", target, impact_extent * 0.82, travel_duration * 0.76, layer_intensity + 1)
		_spawn_fire_spark_spray(target, impact_extent * 0.86, travel_duration * 0.72, layer_intensity + 1, impact_delay + travel_duration * 0.06, tier)
	if tier >= 3:
		var meteor_target := target
		var meteor_impact_size := impact_size * Vector2(1.65, 1.28)
		meteor_target = target + Vector2(0.0, impact_extent * 0.12)
		_spawn_fire_meteor_attack_layers(meteor_target, launch_delay, travel_duration, layer_intensity, meteor_impact_size)
		_spawn_beam_effect(source, delta, "fire", travel_duration * 1.12, layer_intensity + 2, launch_delay, 1.78)
		for lane_index in [-1, 1]:
			var lane := normal * float(lane_index) * 14.0
			_spawn_beam_effect(source + lane, delta - lane * 0.40, "fire", travel_duration * 0.94, layer_intensity + 1, launch_delay + 0.04, 1.02)
		_spawn_atmospheric_flipbook("embers", source + delta * 0.50, Vector2(delta.length() * 0.92, 126.0 + float(layer_intensity) * 9.0), travel_duration * 1.16, Color(1.0, 0.20, 0.04, 0.30), launch_delay, Vector2.ZERO, 1.02, 0.72, angle, 1)
		_spawn_fire_fragmented_impact_cluster(meteor_target, meteor_impact_size * Vector2(0.88, 0.72), travel_duration * 0.76, layer_intensity + 2, impact_delay + travel_duration * 0.04, 0.72, angle)
		_spawn_burst_particles("fire", meteor_target, maxf(impact_extent * 1.08, meteor_impact_size.y * 0.74), travel_duration * 0.92, layer_intensity + 2)
		_spawn_fire_spark_spray(meteor_target, maxf(impact_extent * 1.16, meteor_impact_size.y * 0.82), travel_duration * 0.90, layer_intensity + 2, impact_delay + travel_duration * 0.04, tier)
		_spawn_light(meteor_target, Color(1.0, 0.28, 0.04, 1.0), 4.6 + float(layer_intensity) * 0.42, meteor_impact_size.x * 0.88, travel_duration * 0.90)
	_spawn_camera_kick(delta.normalized() * (6.0 + float(layer_intensity) * (1.15 + float(tier) * 0.18)), impact_delay)


func _spawn_fire_beam_layers(source: Vector2, delta: Vector2, duration: float, intensity: int, angle: float) -> void:
	var tier := _fire_vfx_tier(intensity)
	var layer_intensity := maxi(3, intensity)
	var normal := Vector2(-delta.y, delta.x).normalized()
	_spawn_fire_ember_lane(source, delta, 0.0, duration, layer_intensity, angle, maxi(2, tier))
	_spawn_beam_effect(source, delta, "fire", duration * 1.06, layer_intensity, 0.0, 1.16 + float(tier) * 0.12)
	_spawn_status_path_afterimage("fire", source, delta, 0.0, duration, layer_intensity, angle)
	_spawn_status_flipbook("burn", source, Vector2(150 + layer_intensity * 18, 96 + layer_intensity * 9), duration, Color(1.0, 0.58, 0.18, 0.50), 0.0, delta, 0.78, 2.2, angle, 1)
	if tier >= 2:
		_spawn_fire_screen_ember_field(source + delta * 0.50, duration * 1.12, layer_intensity, 0.0, 0.82)
		_spawn_beam_effect(source + normal * 8.0, delta - normal * 5.0, "fire", duration * 0.92, layer_intensity + 1, 0.04, 0.92)
	if tier >= 3:
		_spawn_fire_aurora_layer(source + delta, duration * 1.10, intensity, 0.0, 0.75)
		_spawn_beam_effect(source, delta, "fire", duration * 1.10, layer_intensity + 2, 0.0, 1.74)


func _spawn_fire_ember_lane(source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float, tier: int) -> void:
	if not _atmospheric_vfx_available() or delta.length() <= 1.0:
		return
	var length := delta.length()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var center := source + delta * 0.50
	var lane_height := maxf(104.0 + float(intensity) * 11.0, length * (0.22 + float(tier) * 0.018))
	var lane_length := length * (0.96 + float(tier) * 0.035)
	_spawn_atmospheric_flipbook("embers", center, Vector2(lane_length, lane_height), travel_duration * 1.20, Color(1.0, 0.38, 0.10, 0.48), launch_delay, Vector2.ZERO, 1.02, 1.05, angle, 1)
	if tier >= 2:
		_spawn_atmospheric_flipbook("embers", center + normal * (10.0 + float(intensity) * 1.4), Vector2(lane_length * 0.82, lane_height * 0.66), travel_duration * 0.94, Color(1.0, 0.44, 0.14, 0.32), launch_delay + travel_duration * 0.09, Vector2.ZERO, 0.94, 1.12, angle + 0.05, 1)
	if tier >= 3:
		_spawn_atmospheric_flipbook("embers", center, Vector2(lane_length * 1.18, lane_height * 1.38), travel_duration * 1.28, Color(1.0, 0.22, 0.04, 0.34), launch_delay, Vector2.ZERO, 1.05, 0.72, angle, 2)


func _spawn_fireball_spell_layers(source: Vector2, target: Vector2, delta: Vector2, source_size: Vector2, impact_size: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	var normal := Vector2(-delta.y, delta.x).normalized()
	var fireball_size := Vector2(maxf(230.0, source_size.x * 1.36), maxf(150.0, source_size.y * 0.92))
	_spawn_atmospheric_flipbook("embers", source + delta * 0.48, Vector2(delta.length() * 0.72, 126.0 + float(intensity) * 9.0), travel_duration * 0.98, Color(1.0, 0.36, 0.08, 0.46), launch_delay + travel_duration * 0.02, Vector2.ZERO, 0.92, 1.35, angle, 1)
	_spawn_status_flipbook("burn", source, fireball_size, travel_duration * 1.08, Color(1.0, 0.54, 0.12, 0.76), launch_delay, delta, 0.72, 2.9, angle, 1)
	_spawn_status_flipbook("rage", source - normal * 7.0, fireball_size * 0.62, travel_duration * 0.86, Color(1.0, 0.22, 0.04, 0.52), launch_delay + 0.04, delta + normal * 10.0, 0.66, 3.0, angle + 0.08, 1)
	_spawn_elemental_effect("projectile", source, "fire", fireball_size * Vector2(1.12, 0.92), travel_duration * 1.10, intensity + 1, launch_delay, delta, angle - PI, 2.7, 0.88)
	_spawn_pack_layer("hit_01", source + delta * 0.58, "fire", fireball_size * 0.54, travel_duration * 0.40, intensity + 1, launch_delay + travel_duration * 0.44, angle, 3.1, 0.48)
	_spawn_elemental_effect("area", target, "fire", impact_size * 0.98, travel_duration * 1.18, intensity + 1, launch_delay + travel_duration * 0.84, Vector2.ZERO, angle, 3.2, 0.88)
	_spawn_pack_layer("impact_01", target, "fire", impact_size * 0.96, travel_duration * 0.70, intensity + 1, launch_delay + travel_duration * 0.88, angle, 3.4, 0.76)
	_spawn_fire_spark_spray(target, maxf(impact_size.x, impact_size.y) * 0.78, travel_duration * 0.86, intensity + 1, launch_delay + travel_duration * 0.84, 2)
	_spawn_light(target, Color(1.0, 0.44, 0.08, 1.0), 4.0 + float(intensity) * 0.32, maxf(impact_size.x, impact_size.y) * 1.20, travel_duration * 0.78)


func _spawn_fireball_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, max_size: float) -> void:
	var impact_extent := maxf(impact_size.x, impact_size.y)
	_spawn_elemental_effect("area", center, "fire", impact_size * 1.04, duration * 1.16, intensity + 1, 0.02, Vector2.ZERO, 0.0, 2.8, 0.84)
	_spawn_atmospheric_flipbook("embers", center + Vector2(0.0, -max_size * 0.06), impact_size * Vector2(1.28, 0.82), duration * 0.96, Color(1.0, 0.34, 0.08, 0.42), 0.04, Vector2(0.0, -max_size * 0.12), 1.02, 2.9, 0.0, 1)
	_spawn_status_flipbook("rage", center + Vector2(0.0, -max_size * 0.08), impact_size * 0.50, duration * 0.72, Color(1.0, 0.24, 0.04, 0.52), 0.08, Vector2.ZERO, 1.10, 3.2, 0.0, 1)
	_spawn_fire_spark_spray(center, impact_extent * 0.72, duration * 0.80, intensity + 1, 0.04, 2)
	_spawn_light(center, Color(1.0, 0.42, 0.08, 1.0), 3.8 + float(intensity) * 0.26, impact_extent * 1.16, duration * 0.74)


func _spawn_fire_meteor_attack_layers(target: Vector2, launch_delay: float, travel_duration: float, intensity: int, impact_size: Vector2) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return
	var meteor_delay := launch_delay + travel_duration * 0.12
	var descent_time := travel_duration * 1.02
	for i in range(3):
		var offset_x := (float(i) - 1.0) * impact_size.x * 0.24
		var start := Vector2(target.x + offset_x - impact_size.x * 0.22, maxf(0.0, target.y - impact_size.y * (1.35 + float(i) * 0.10)))
		var end := target + Vector2(offset_x * 0.22, impact_size.y * (0.08 + float(i) * 0.02))
		var move := end - start
		var size := Vector2(impact_size.x * (0.32 + float(i) * 0.04), impact_size.y * 0.24)
		var streak_delay := meteor_delay + travel_duration * (0.06 + float(i) * 0.07)
		_spawn_elemental_effect("projectile", start, "fire", size, descent_time * (0.78 + float(i) * 0.08), intensity + 1, streak_delay, move, move.angle() - PI, 2.6, 0.74)
		_spawn_status_flipbook("burn", start, size * Vector2(0.86, 0.62), descent_time * (0.70 + float(i) * 0.08), Color(1.0, 0.36, 0.06, 0.44), streak_delay + 0.02, move, 0.62, 2.8, move.angle(), 1)
	_spawn_fire_meteor_impact_layers(target, impact_size * 1.26, travel_duration * 1.08, intensity + 2, launch_delay + travel_duration * 0.82, true)


func _spawn_fire_meteor_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, fragmented_wide: bool = false) -> void:
	var extent := maxf(impact_size.x, impact_size.y)
	var vertical_target := impact_size.x > impact_size.y * 1.35
	var base_center := center + Vector2(0.0, impact_size.y * (0.22 if vertical_target else 0.08))
	_spawn_atmospheric_flipbook("fog", base_center + Vector2(0.0, impact_size.y * 0.10), impact_size * Vector2(0.78, 0.58), duration * 1.06, Color(1.0, 0.08, 0.02, 0.12 if vertical_target else 0.18), delay + duration * 0.02, Vector2(0.0, -impact_size.y * 0.08), 1.02, 2.2, 0.0, 1)
	_spawn_atmospheric_flipbook("embers", base_center + Vector2(0.0, -impact_size.y * 0.08), impact_size * Vector2(0.92, 0.72), duration * 0.84, Color(1.0, 0.20, 0.03, 0.22 if vertical_target else 0.32), delay, Vector2(0.0, impact_size.y * 0.04), 0.94, 2.6, 0.0, 1)
	_spawn_status_flipbook("rage", base_center + Vector2(0.0, -impact_size.y * 0.12), impact_size * Vector2(0.62, 0.78), duration * 0.82, Color(1.0, 0.20, 0.03, 0.46 if vertical_target else 0.54), delay + duration * 0.04, Vector2.ZERO, 1.12, 3.2, 0.0, 1)
	if fragmented_wide or vertical_target:
		_spawn_fire_fragmented_impact_cluster(base_center, impact_size, duration, intensity, delay + duration * 0.06, 0.78)
	else:
		_spawn_elemental_effect("area", base_center, "fire", impact_size * Vector2(0.82, 0.86), duration * 1.08, intensity, delay + duration * 0.06, Vector2.ZERO, 0.0, 3.0, 0.78)
		_spawn_pack_layer("big_impact_01", base_center, "fire", impact_size * Vector2(0.76, 0.80), duration * 0.78, intensity, delay + duration * 0.08, 0.0, 3.8, 0.66)
	_spawn_fire_spark_spray(base_center, extent * 1.18, duration * 0.92, intensity, delay + duration * 0.10, 3)
	_spawn_light(base_center, Color(1.0, 0.18, 0.02, 1.0), 5.2 + float(intensity) * 0.42, extent * 1.80, duration * 0.90)


func _spawn_fire_fragmented_impact_cluster(center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, alpha_scale: float = 1.0, rotation: float = 0.0) -> void:
	var width := maxf(120.0, draw_size.x)
	var height := maxf(110.0, draw_size.y)
	var burst_base := clampf(height * 0.44, 92.0, 190.0)
	var offsets := [
		Vector2(-width * 0.34, -height * 0.12),
		Vector2(-width * 0.13, height * 0.02),
		Vector2(width * 0.12, -height * 0.08),
		Vector2(width * 0.32, height * 0.04),
		Vector2(0.0, height * 0.15),
	]
	for i in range(offsets.size()):
		var progress := float(i) / float(maxi(1, offsets.size() - 1))
		var burst_center: Vector2 = center + offsets[i]
		var burst_size := Vector2(
			burst_base * (1.08 + sin(float(i) * 1.7) * 0.12),
			burst_base * (0.78 + cos(float(i) * 1.3) * 0.10)
		)
		var burst_delay := delay + duration * (0.02 + progress * 0.10)
		var burst_rotation := rotation + (-0.24 + progress * 0.48)
		_spawn_pack_layer("impact_01", burst_center, "fire", burst_size, duration * 0.46, intensity, burst_delay, burst_rotation, 3.7, 0.46 * alpha_scale)
		_spawn_pack_layer("hit_01", burst_center + Vector2(0.0, -burst_base * 0.10), "fire", burst_size * 0.58, duration * 0.36, intensity + 1, burst_delay + duration * 0.04, burst_rotation * 0.7, 3.9, 0.42 * alpha_scale)
		_spawn_status_flipbook("burn", burst_center, burst_size * Vector2(0.78, 0.58), duration * 0.68, Color(1.0, 0.44, 0.08, 0.32 * alpha_scale), burst_delay, Vector2(0.0, -height * 0.04), 0.98, 3.2, burst_rotation, 1)
	_spawn_status_flipbook("rage", center + Vector2(0.0, -height * 0.04), Vector2(width * 0.58, height * 0.36), duration * 0.76, Color(1.0, 0.16, 0.02, 0.26 * alpha_scale), delay + duration * 0.05, Vector2.ZERO, 1.04, 3.1, rotation, 1)
	_spawn_atmospheric_flipbook("embers", center + Vector2(0.0, -height * 0.10), Vector2(width * 0.92, height * 0.46), duration * 0.86, Color(1.0, 0.30, 0.05, 0.24 * alpha_scale), delay + duration * 0.02, Vector2(0.0, -height * 0.08), 0.98, 2.8, rotation, 1)


func _spawn_fire_screen_ember_field(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	if not _atmospheric_vfx_available():
		return
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return
	var screen_center := layer_size * 0.5
	var attack_focus_y := clampf(center.y, layer_size.y * 0.10, layer_size.y * 0.52)
	var attack_focus := Vector2(layer_size.x * 0.5, attack_focus_y)
	var full_screen := Vector2(layer_size.x * 1.24, layer_size.y * 1.14)
	var top_screen := Vector2(layer_size.x * 1.16, layer_size.y * 0.58)
	_spawn_atmospheric_flipbook("fog", screen_center, full_screen * Vector2(1.16, 1.04), lifetime * 1.22, Color(1.0, 0.12, 0.03, 0.30 * alpha_scale), delay, Vector2(0.0, -layer_size.y * 0.025), 1.02, -0.90, 0.0, 1)
	_spawn_atmospheric_flipbook("embers", screen_center, full_screen, lifetime * 1.28, Color(1.0, 0.24, 0.04, 0.78 * alpha_scale), delay, Vector2(0.0, -layer_size.y * 0.070), 1.04, -0.45, 0.0, 2)
	_spawn_atmospheric_flipbook("embers", screen_center + Vector2(0.0, layer_size.y * 0.08), full_screen * Vector2(1.10, 0.96), lifetime * 1.08, Color(1.0, 0.48, 0.12, 0.52 * alpha_scale), delay + lifetime * 0.05, Vector2(0.0, -layer_size.y * 0.090), 0.98, 0.20, 0.0, 2)
	_spawn_atmospheric_flipbook("embers", attack_focus, top_screen, lifetime * 1.14, Color(1.0, 0.16, 0.02, 0.64 * alpha_scale), delay + lifetime * 0.02, Vector2(0.0, -layer_size.y * 0.055), 1.03, 0.50, 0.0, 2)
	_spawn_atmospheric_flipbook("embers", attack_focus + Vector2(0.0, -layer_size.y * 0.05), top_screen * Vector2(0.92, 0.66), lifetime * 0.94, Color(1.0, 0.26, 0.04, 0.30 * alpha_scale), delay + lifetime * 0.09, Vector2(0.0, layer_size.y * 0.040), 0.94, 0.38, 0.0, 1)
	_spawn_light(screen_center, Color(1.0, 0.20, 0.03, 1.0), 2.5 + float(intensity) * 0.20, layer_size.x * 1.05, lifetime * 0.78)


func _spawn_fire_spark_spray(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int) -> void:
	if not _atmospheric_vfx_available():
		return
	var count := 6 + mini(18, intensity * 2 + tier * 3)
	for i in range(count):
		var angle := TAU * float(i) / float(count) + sin(float(i) * 1.37) * 0.36
		var direction := Vector2(cos(angle), sin(angle))
		var start := center + direction * radius * (0.08 + float(i % 3) * 0.015)
		var travel := direction * radius * (0.34 + float(i % 5) * 0.055)
		travel.y -= radius * (0.10 + float(i % 4) * 0.025)
		var size := Vector2(52.0 + float(intensity) * 5.0, 34.0 + float(intensity) * 3.0) * (1.0 + float(tier) * 0.08)
		var spark_delay := delay + float(i % 6) * lifetime * 0.018
		var alpha := 0.36 + float(tier) * 0.05
		_spawn_atmospheric_flipbook("embers", start, size, lifetime * (0.48 + float(i % 4) * 0.045), Color(1.0, 0.40, 0.10, alpha), spark_delay, travel, 0.42, 2.6, angle, 1)


func _spawn_fire_aurora_layer(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	if not _atmospheric_vfx_available():
		return
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return
	var focus_y := clampf(center.y, layer_size.y * 0.08, layer_size.y * 0.44)
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var aurora_size := Vector2(layer_size.x * (1.05 + float(maxi(0, intensity - 5)) * 0.035), layer_size.y * (0.34 + float(mini(intensity, 8)) * 0.016))
	_spawn_atmospheric_flipbook("aurora", focus, aurora_size, lifetime * 1.24, Color(1.0, 0.40, 0.16, 0.36 * alpha_scale), delay, Vector2(0.0, -layer_size.y * 0.025), 1.03, -1.85, 0.0, 1)
	_spawn_atmospheric_flipbook("godrays", focus + Vector2(0.0, -layer_size.y * 0.02), Vector2(layer_size.x * 0.92, layer_size.y * 0.30), lifetime * 0.86, Color(1.0, 0.32, 0.08, 0.24 * alpha_scale), delay + lifetime * 0.03, Vector2(0.0, -layer_size.y * 0.02), 0.82, -1.70, 0.0, 1)
	_spawn_atmospheric_flipbook("embers", focus + Vector2(0.0, layer_size.y * 0.02), Vector2(layer_size.x * 0.98, layer_size.y * 0.26), lifetime * 1.08, Color(1.0, 0.22, 0.04, 0.32 * alpha_scale), delay + lifetime * 0.04, Vector2(0.0, -layer_size.y * 0.035), 1.02, -1.55, 0.0, 2)
	var ray_count := 5 + mini(5, intensity)
	for i in range(ray_count):
		var progress := float(i) / float(maxi(1, ray_count - 1))
		var ray_y := focus_y + (progress - 0.50) * layer_size.y * 0.22
		var ray_width := layer_size.x * (0.72 + float(i % 3) * 0.10)
		var ray_delay := delay + lifetime * (0.05 + float(i % 4) * 0.025)
		_spawn_flipbook("light_rays", Vector2(layer_size.x * 0.5, ray_y), Vector2(ray_width, 46.0 + float(intensity) * 4.0), lifetime * 0.52, Color(1.0, 0.34, 0.08, 0.34 * alpha_scale), ray_delay, Vector2(sin(float(i)) * 32.0, -10.0), 0.58, -1.25, -0.18 + sin(float(i)) * 0.20)


func _spawn_ice_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	var tier := _ice_vfx_tier(intensity, screen_wide)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var wide_target := draw_size.x > draw_size.y * 1.35
	var ice_center := center + Vector2(0.0, draw_size.y * (0.16 if wide_target else 0.0))
	var impact_extent := maxf(122.0, base_size * 0.52) if tier == 1 else maxf(172.0, base_size * (0.62 + float(tier) * 0.12))
	var impact_size := Vector2(impact_extent, impact_extent)
	var wind_size := Vector2(
		maxf(draw_size.x * 1.04, impact_extent * (1.18 if tier >= 2 else 0.96)),
		maxf(draw_size.y * (1.52 if wide_target else 0.82), impact_extent * (0.62 if tier >= 2 else 0.48))
	)
	_spawn_atmospheric_flipbook("frost", ice_center, wind_size * Vector2(0.88, 0.74), duration * 1.12, Color(0.74, 0.94, 1.0, 0.24), 0.0, Vector2(0.0, -max_size * 0.04), 1.02, 0.25, 0.0, 1)
	_spawn_status_flipbook("freeze", ice_center, impact_size * (0.46 if tier == 1 else 0.56), duration * 0.92, Color(0.86, 0.98, 1.0, 0.64), 0.0, Vector2.ZERO, 1.08, 1.7, -0.04, 1)
	if tier == 1:
		_spawn_iceball_impact_layers(ice_center, impact_size, duration, layer_intensity, max_size, 0.0)
	elif tier == 2:
		_spawn_windy_ice_block_layers(ice_center, impact_size * Vector2(1.22, 1.02), duration, layer_intensity, 0.0, 0.92)
	else:
		_spawn_ice_blizzard_layers(ice_center, wind_size * Vector2(1.08, 1.20), duration, layer_intensity, 0.0, wide_target)
	var burst_radius := impact_extent * (0.45 if tier == 1 else 0.70 + float(tier) * 0.10)
	_spawn_burst_particles("ice", ice_center, burst_radius, duration * 0.82, layer_intensity)
	_spawn_light(ice_center, Color(0.72, 0.94, 1.0, 1.0), 2.0 + float(layer_intensity) * (0.24 + float(tier) * 0.06), impact_extent * (0.82 + float(tier) * 0.16), duration * 0.74)


func _spawn_ice_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	var tier := _ice_vfx_tier(intensity)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var source_size := spool_size * (0.90 + float(tier) * 0.10)
	var impact_extent := maxf(134.0, source_size.x * 0.78) if tier == 1 else maxf(184.0, source_size.x * (0.98 + float(tier) * 0.12))
	var impact_size := Vector2(impact_extent, impact_extent)
	var impact_delay := launch_delay + travel_duration * 0.84
	_spawn_light(source, core, 2.2 + float(layer_intensity) * 0.24, source_size.x * (1.12 + float(tier) * 0.08), spool_duration * 1.10)
	_spawn_atmospheric_flipbook("frost", source, source_size * Vector2(1.20, 0.92), spool_duration * 1.14, Color(0.72, 0.94, 1.0, 0.34), 0.0, Vector2(0.0, -14.0), 1.04, 0.42, angle, 1)
	_spawn_status_flipbook("freeze", source, source_size * (0.48 if tier == 1 else 0.58), spool_duration * 0.92, Color(0.86, 0.98, 1.0, 0.64), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1)
	if tier == 1:
		_spawn_iceball_travel_layers(source, target, delta, source_size, travel_duration, launch_delay, layer_intensity, angle)
		_spawn_iceball_impact_layers(target, impact_size, travel_duration * 1.02, layer_intensity, impact_extent, impact_delay)
	elif tier == 2:
		_spawn_windy_ice_block_travel_layers(source, target, delta, normal, source_size, travel_duration, launch_delay, layer_intensity, angle)
		_spawn_windy_ice_block_layers(target, impact_size * Vector2(1.20, 1.02), travel_duration * 1.14, layer_intensity, impact_delay, 0.98)
	else:
		_spawn_ice_blizzard_travel_layers(source, target, delta, normal, impact_size, travel_duration, launch_delay, layer_intensity, angle)
		_spawn_ice_blizzard_layers(target, impact_size * Vector2(1.55, 1.18), travel_duration * 1.26, layer_intensity, impact_delay, true)
	_spawn_camera_kick(delta.normalized() * (3.8 + float(layer_intensity) * (0.75 + float(tier) * 0.20)), impact_delay)


func _spawn_iceball_travel_layers(source: Vector2, _target: Vector2, delta: Vector2, source_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float) -> void:
	var ball_size := Vector2(maxf(120.0, source_size.x * 0.82), maxf(82.0, source_size.y * 0.58))
	_spawn_status_path_afterimage("ice", source, delta, launch_delay, travel_duration * 1.04, intensity, angle)
	_spawn_flipbook("ice_projectile", source, ball_size, travel_duration * 1.04, Color(0.86, 0.98, 1.0, 0.88), launch_delay, delta, 0.72, 2.1, angle)
	_spawn_status_flipbook("freeze", source, ball_size * 0.58, travel_duration * 0.90, Color(0.76, 0.94, 1.0, 0.42), launch_delay + travel_duration * 0.04, delta, 0.70, 2.3, angle, 1)
	_spawn_atmospheric_flipbook("frost", source + delta * 0.50, Vector2(delta.length() * 0.48, 74.0 + float(intensity) * 5.0), travel_duration * 0.92, Color(0.70, 0.92, 1.0, 0.26), launch_delay + travel_duration * 0.03, Vector2.ZERO, 0.82, 1.4, angle, 1)
	_spawn_pack_layer("hit_02", source + delta * 0.62, "ice", ball_size * 0.44, travel_duration * 0.36, intensity, launch_delay + travel_duration * 0.50, angle, 2.7, 0.32)


func _spawn_windy_ice_block_travel_layers(source: Vector2, _target: Vector2, delta: Vector2, normal: Vector2, source_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float) -> void:
	var lane_center := source + delta * 0.50
	var lane_length := delta.length() * 0.96
	var block_size := source_size * Vector2(1.12, 0.82)
	_spawn_atmospheric_flipbook("wind", lane_center, Vector2(lane_length, 128.0 + float(intensity) * 12.0), travel_duration * 1.16, Color(0.72, 0.92, 1.0, 0.30), launch_delay, Vector2.ZERO, 1.02, 0.84, angle, 1)
	_spawn_atmospheric_flipbook("snow", lane_center + normal * 10.0, Vector2(lane_length * 0.88, 108.0 + float(intensity) * 9.0), travel_duration * 1.08, Color(0.86, 0.98, 1.0, 0.34), launch_delay + travel_duration * 0.04, Vector2.ZERO, 0.94, 1.0, angle + 0.04, 1)
	# Ice travel should read as cold mass moving through air, not as a laser beam.
	_spawn_flipbook("ice_projectile", source + normal * 4.0, block_size, travel_duration * 1.04, Color(0.86, 0.98, 1.0, 0.78), launch_delay + travel_duration * 0.02, delta, 0.82, 2.7, angle, 0.22)
	_spawn_status_flipbook("freeze", source - normal * 6.0, block_size * Vector2(0.74, 0.64), travel_duration * 1.00, Color(0.82, 0.98, 1.0, 0.46), launch_delay + travel_duration * 0.04, delta + normal * 8.0, 0.76, 2.85, angle - 0.04, 1, -0.28)
	_spawn_flipbook("ice_shards", source + delta * 0.12 - normal * 10.0, block_size * Vector2(0.56, 0.38), travel_duration * 0.76, Color(0.82, 0.98, 1.0, 0.52), launch_delay + travel_duration * 0.16, delta * 0.78 + normal * 16.0, 0.56, 3.05, angle + 0.10)
	_spawn_pack_layer("hit_02", lane_center, "ice", block_size * 0.36, travel_duration * 0.42, intensity, launch_delay + travel_duration * 0.42, angle, 3.15, 0.26)
	for lane_index in [-1, 0, 1]:
		var lane := normal * float(lane_index) * (12.0 + float(intensity) * 1.8)
		var shard_size := source_size * Vector2(0.62, 0.42)
		_spawn_status_flipbook("freeze", source + lane, shard_size, travel_duration * 0.94, Color(0.76, 0.94, 1.0, 0.40), launch_delay + float(lane_index + 1) * 0.035, delta - lane * 0.32, 0.78, 2.2, angle + float(lane_index) * 0.08, 1)
		_spawn_flipbook("ice_shards", source + lane + delta * 0.16, shard_size * 0.82, travel_duration * 0.74, Color(0.78, 0.96, 1.0, 0.46), launch_delay + float(lane_index + 1) * 0.040, delta * 0.72 - lane * 0.20, 0.58, 2.4, angle + float(lane_index) * 0.10)
	_spawn_status_path_afterimage("ice", source, delta, launch_delay, travel_duration * 1.12, intensity, angle)


func _spawn_ice_blizzard_travel_layers(source: Vector2, target: Vector2, delta: Vector2, normal: Vector2, impact_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float) -> void:
	var layer_size := _vfx_layer_size()
	var lane_center := source + delta * 0.50
	_spawn_windy_ice_block_travel_layers(source, target, delta, normal, impact_size * 0.62, travel_duration, launch_delay, intensity, angle)
	if layer_size.x > 1.0 and layer_size.y > 1.0:
		var focus_y := clampf(target.y, layer_size.y * 0.08, layer_size.y * 0.50)
		var focus := Vector2(layer_size.x * 0.5, focus_y)
		_spawn_atmospheric_flipbook("snow", focus, Vector2(layer_size.x * 1.16, layer_size.y * 0.62), travel_duration * 1.26, Color(0.82, 0.96, 1.0, 0.50), launch_delay, Vector2(0.0, -layer_size.y * 0.05), 1.02, -0.80, 0.0, 2)
		_spawn_atmospheric_flipbook("frost", focus + Vector2(0.0, layer_size.y * 0.04), Vector2(layer_size.x * 1.02, layer_size.y * 0.48), travel_duration * 1.12, Color(0.58, 0.86, 1.0, 0.34), launch_delay + travel_duration * 0.06, Vector2(0.0, -layer_size.y * 0.03), 0.96, -0.55, 0.0, 1)
	for i in range(5 + mini(5, intensity)):
		var progress := float(i) / float(maxi(1, 4 + mini(5, intensity)))
		var start := lane_center + Vector2((progress - 0.5) * impact_size.x * 1.25, -impact_size.y * (0.72 + 0.10 * float(i % 3)))
		var end := target + Vector2((progress - 0.5) * impact_size.x * 0.46, impact_size.y * (0.05 + 0.02 * float(i % 2)))
		var move := end - start
		_spawn_flipbook("ice_shards", start, impact_size * Vector2(0.28, 0.18), travel_duration * 0.74, Color(0.86, 0.98, 1.0, 0.56), launch_delay + travel_duration * (0.10 + progress * 0.18), move, 0.58, 2.8, move.angle())


func _spawn_iceball_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, max_size: float, delay: float) -> void:
	var extent := maxf(impact_size.x, impact_size.y)
	_spawn_flipbook("ice_impact", center, impact_size * 0.66, duration * 0.72, Color(0.86, 0.98, 1.0, 0.72), delay, Vector2.ZERO, 0.86, 2.8, 0.05)
	_spawn_flipbook("ice_shards", center + Vector2(-extent * 0.08, -extent * 0.04), impact_size * 0.48, duration * 0.56, Color(0.80, 0.96, 1.0, 0.54), delay + duration * 0.06, Vector2(extent * 0.10, -extent * 0.08), 0.56, 3.0, -0.18)
	_spawn_status_flipbook("freeze", center, impact_size * 0.46, duration * 0.82, Color(0.84, 0.98, 1.0, 0.48), delay + duration * 0.02, Vector2.ZERO, 0.96, 3.1, -0.06, 1)
	_spawn_pack_layer("impact_02", center, "ice", impact_size * 0.46, duration * 0.48, intensity, delay + duration * 0.08, 0.0, 3.2, 0.34)
	_spawn_atmospheric_flipbook("frost", center + Vector2(0.0, -max_size * 0.04), impact_size * Vector2(0.92, 0.56), duration * 0.72, Color(0.70, 0.92, 1.0, 0.24), delay + duration * 0.04, Vector2(0.0, -max_size * 0.08), 0.74, 2.6, 0.0, 1)
	_spawn_light(center, Color(0.70, 0.94, 1.0, 1.0), 1.8 + float(intensity) * 0.22, extent * 0.92, duration * 0.58, delay)


func _spawn_windy_ice_block_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, alpha_scale: float) -> void:
	var extent := maxf(impact_size.x, impact_size.y)
	var block_size := impact_size * Vector2(0.76, 0.66)
	_spawn_atmospheric_flipbook("wind", center, impact_size * Vector2(1.32, 0.72), duration * 1.02, Color(0.68, 0.92, 1.0, 0.32 * alpha_scale), delay, Vector2(0.0, -extent * 0.04), 1.02, 2.2, 0.0, 1)
	_spawn_atmospheric_flipbook("frost", center + Vector2(0.0, -extent * 0.04), impact_size * Vector2(1.02, 0.76), duration * 1.08, Color(0.72, 0.94, 1.0, 0.36 * alpha_scale), delay + duration * 0.02, Vector2(0.0, -extent * 0.05), 1.00, 2.4, 0.0, 1)
	_spawn_status_flipbook("freeze", center, block_size, duration * 0.98, Color(0.86, 0.98, 1.0, 0.62 * alpha_scale), delay, Vector2.ZERO, 1.08, 2.8, 0.0, 1)
	_spawn_status_flipbook("slow", center + Vector2(0.0, -extent * 0.12), block_size * Vector2(0.74, 0.58), duration * 0.82, Color(0.54, 0.88, 1.0, 0.42 * alpha_scale), delay + duration * 0.08, Vector2.ZERO, 0.94, 3.1, 0.12, 1)
	_spawn_flipbook("ice_impact", center, block_size * 0.84, duration * 0.76, Color(0.82, 0.98, 1.0, 0.58 * alpha_scale), delay + duration * 0.05, Vector2.ZERO, 0.94, 3.0, -0.04)
	for i in range(4 + mini(4, intensity)):
		var progress := float(i) / float(maxi(1, 3 + mini(4, intensity)))
		var offset := Vector2((progress - 0.5) * impact_size.x * 0.68, sin(float(i) * 1.7) * impact_size.y * 0.12)
		_spawn_flipbook("ice_shards", center + offset, impact_size * Vector2(0.22, 0.16), duration * 0.48, Color(0.82, 0.98, 1.0, 0.48 * alpha_scale), delay + duration * (0.08 + progress * 0.14), offset.normalized() * extent * 0.10 + Vector2(0.0, -extent * 0.08), 0.54, 3.2, -0.35 + progress * 0.70)
	_spawn_pack_layer("impact_02", center, "ice", impact_size * 0.44, duration * 0.58, intensity, delay + duration * 0.10, 0.0, 3.3, 0.44 * alpha_scale)
	_spawn_light(center, Color(0.66, 0.92, 1.0, 1.0), 2.0 + float(intensity) * 0.26, extent * 1.04, duration * 0.66, delay)


func _spawn_ice_blizzard_layers(center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, wide_target: bool) -> void:
	var layer_size := _vfx_layer_size()
	var extent := maxf(draw_size.x, draw_size.y)
	if layer_size.x > 1.0 and layer_size.y > 1.0:
		var focus_y := clampf(center.y, layer_size.y * 0.08, layer_size.y * 0.52)
		var focus := Vector2(layer_size.x * 0.5, focus_y)
		var blizzard_size := Vector2(layer_size.x * 1.16, layer_size.y * (0.62 if wide_target else 0.52))
		_spawn_atmospheric_flipbook("snow", focus, blizzard_size, duration * 1.34, Color(0.86, 0.98, 1.0, 0.54), delay, Vector2(0.0, -layer_size.y * 0.06), 1.02, -1.0, 0.0, 2)
		_spawn_atmospheric_flipbook("wind", focus + Vector2(0.0, layer_size.y * 0.02), blizzard_size * Vector2(1.08, 0.72), duration * 1.12, Color(0.62, 0.88, 1.0, 0.36), delay + duration * 0.04, Vector2(0.0, -layer_size.y * 0.035), 0.98, -0.72, 0.0, 1)
		_spawn_atmospheric_flipbook("frost", focus + Vector2(0.0, -layer_size.y * 0.02), blizzard_size * Vector2(0.92, 0.62), duration * 1.20, Color(0.50, 0.84, 1.0, 0.30), delay + duration * 0.08, Vector2(0.0, -layer_size.y * 0.025), 0.96, -0.58, 0.0, 1)
	_spawn_windy_ice_block_layers(center, draw_size * Vector2(0.72, 0.62), duration * 0.88, intensity, delay + duration * 0.06, 0.92)
	for i in range(7 + mini(7, intensity)):
		var progress := float(i) / float(maxi(1, 6 + mini(7, intensity)))
		var start := center + Vector2((progress - 0.5) * draw_size.x * 1.06, -draw_size.y * (0.42 + 0.08 * float(i % 4)))
		var move := Vector2((0.5 - progress) * draw_size.x * 0.18, draw_size.y * (0.34 + 0.04 * float(i % 3)))
		_spawn_flipbook("ice_shards", start, Vector2(extent * 0.16, extent * 0.10), duration * 0.52, Color(0.88, 1.0, 1.0, 0.52), delay + duration * (0.04 + progress * 0.20), move, 0.54, 3.4, -0.52 + progress * 1.04)
	_spawn_pack_layer("big_impact_02", center, "ice", draw_size * Vector2(0.38, 0.34), duration * 0.58, intensity, delay + duration * 0.12, 0.0, 3.6, 0.38)
	_spawn_light(center, Color(0.72, 0.94, 1.0, 1.0), 2.8 + float(intensity) * 0.32, extent * 1.18, duration * 0.74, delay)


func _spawn_earth_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	var tier := _earth_vfx_tier(intensity, screen_wide)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var wide_target := draw_size.x > draw_size.y * 1.35
	var earth_center := center + Vector2(0.0, draw_size.y * (0.18 if wide_target else 0.08))
	var local_extent := maxf(128.0, draw_size.y * (0.74 if wide_target else 0.92))
	var impact_extent := local_extent if tier == 1 else maxf(local_extent * 1.36, minf(base_size * 0.48, max_size * (0.74 + float(tier) * 0.20)))
	if tier >= 3:
		impact_extent = maxf(impact_extent, max_size * 1.05)
	var impact_size := Vector2(impact_extent, impact_extent)
	_spawn_earth_quake_impact_layers(earth_center, impact_size, duration, layer_intensity, 0.0, tier, screen_wide)
	if tier >= 3:
		var target_tornado_size := Vector2(draw_size.x * 0.96, draw_size.y * (0.86 if wide_target else 0.92))
		_spawn_earth_tornado_atmosphere(earth_center, target_tornado_size, duration * 1.16, layer_intensity, duration * 0.04, true)
	_spawn_burst_particles("earth", earth_center, impact_extent * (0.56 if tier == 1 else 0.82 + float(tier) * 0.08), duration * 0.82, layer_intensity)
	_spawn_light(earth_center, Color(0.92, 0.76, 0.48, 1.0), 2.1 + float(layer_intensity) * (0.24 + float(tier) * 0.06), impact_extent * (0.86 + float(tier) * 0.15), duration * 0.70)


func _spawn_earth_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	var tier := _earth_vfx_tier(intensity)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var source_size := spool_size * (0.92 + float(tier) * 0.10)
	var impact_extent := maxf(140.0, source_size.x * 0.78) if tier == 1 else maxf(196.0, source_size.x * (1.02 + float(tier) * 0.12))
	var impact_size := Vector2(impact_extent, impact_extent)
	var impact_delay := launch_delay + travel_duration * 0.84
	_spawn_light(source, core, 2.1 + float(layer_intensity) * 0.24, source_size.x * (1.16 + float(tier) * 0.08), spool_duration * 1.08)
	_spawn_earth_spool_layers(source, source_size, spool_duration, layer_intensity, tier, angle)
	_spawn_earth_fracture_travel_layers(source, target, delta, normal, source_size, travel_duration, launch_delay, layer_intensity, angle, tier)
	_spawn_earth_quake_impact_layers(target, impact_size, travel_duration * 1.16, layer_intensity, impact_delay, tier, false)
	if tier >= 3:
		_spawn_earth_tornado_atmosphere(target, impact_size * Vector2(1.08, 0.58), travel_duration * 1.34, layer_intensity, impact_delay + travel_duration * 0.06, true)
	_spawn_camera_kick(delta.normalized() * (4.4 + float(layer_intensity) * (0.85 + float(tier) * 0.18)), impact_delay)


func _spawn_earth_spool_layers(source: Vector2, source_size: Vector2, spool_duration: float, intensity: int, tier: int, angle: float) -> void:
	var ground_center := source + Vector2(0.0, source_size.y * 0.16)
	var dust_size := source_size * (Vector2(1.10, 0.46) if tier == 1 else Vector2(1.64, 0.62))
	var tornado_size := source_size * (Vector2(0.66, 0.78) if tier == 1 else Vector2(0.86, 0.98))
	_spawn_tornado_scene(source + Vector2(0.0, source_size.y * 0.08), tornado_size, spool_duration * 1.08, intensity, 0.0, Vector2.ZERO, 1.30, "tornado poison")
	_spawn_atmospheric_flipbook("bubbles", ground_center + Vector2(0.0, source_size.y * 0.03), source_size * Vector2(0.74 if tier == 1 else 1.00, 0.38 if tier == 1 else 0.50), spool_duration * 0.86, Color(0.54, 1.0, 0.24, 0.28 if tier == 1 else 0.42), 0.04, Vector2(0.0, -source_size.y * 0.08), 0.70, 1.18, angle, 1)
	_spawn_status_flipbook("poison", source + Vector2(0.0, source_size.y * 0.02), source_size * (0.34 if tier == 1 else 0.48), spool_duration * 0.96, Color(0.64, 1.0, 0.24, 0.34 if tier == 1 else 0.46), 0.02, Vector2.ZERO, 1.04, 1.38, angle, 1)
	_spawn_status_flipbook("weaken", source + Vector2(0.0, source_size.y * 0.07), source_size * Vector2(0.58, 0.36), spool_duration * 0.86, Color(0.70, 1.0, 0.28, 0.30 if tier == 1 else 0.42), 0.10, Vector2(0.0, -source_size.y * 0.04), 0.86, 1.46, angle + 0.12, 1)
	_spawn_flipbook("dust_puff", ground_center + Vector2(0.0, source_size.y * 0.10), dust_size, spool_duration * 1.02, Color(0.52, 0.42, 0.30, 0.40 if tier == 1 else 0.56), 0.04, Vector2(0.0, -source_size.y * 0.09), 0.72, 0.95, angle)
	_spawn_flipbook("shockwave_ring", ground_center, source_size * Vector2(0.92 + float(tier) * 0.20, 0.44 + float(tier) * 0.08), spool_duration * 0.66, Color(0.66, 1.0, 0.30, 0.42 if tier == 1 else 0.58), 0.08, Vector2.ZERO, 1.24, 1.06, angle)
	_spawn_pack_layer("hit_01", source + Vector2(0.0, source_size.y * 0.02), "earth", source_size * (0.34 if tier == 1 else 0.56), spool_duration * 0.48, intensity, 0.14, angle, 1.72, 0.36 if tier == 1 else 0.56)
	_spawn_earth_debris_spray(ground_center, source_size.x * (0.46 if tier == 1 else 0.72), spool_duration * 0.78, intensity, 0.06, tier, angle)
	if tier >= 2:
		_spawn_atmospheric_flipbook("rain_splash", ground_center + Vector2(0.0, source_size.y * 0.14), source_size * Vector2(1.08, 0.48), spool_duration * 0.74, Color(0.54, 0.92, 0.30, 0.30), 0.10, Vector2(0.0, -source_size.y * 0.04), 0.74, 1.32, angle, 1)
		_spawn_status_flipbook("regen", source + Vector2(-source_size.x * 0.08, -source_size.y * 0.04), source_size * 0.36, spool_duration * 0.72, Color(0.54, 1.0, 0.30, 0.34), 0.18, Vector2(source_size.x * 0.08, -source_size.y * 0.08), 0.82, 1.86, angle - 0.16, 1)
		_spawn_pack_layer("hit_02", source + Vector2(source_size.x * 0.10, -source_size.y * 0.08), "earth", source_size * 0.48, spool_duration * 0.46, intensity + 1, 0.24, angle + 0.20, 1.92, 0.46)
		_spawn_flipbook("dust_puff", ground_center + Vector2(0.0, source_size.y * 0.08), source_size * Vector2(1.88, 0.66), spool_duration * 0.88, Color(0.42, 0.34, 0.24, 0.38), 0.12, Vector2(0.0, -source_size.y * 0.12), 0.80, 1.12, angle)
		_spawn_burst_particles("earth", source + Vector2(0.0, source_size.y * 0.08), source_size.x * 0.82, spool_duration * 0.64, intensity + 2)
	if tier >= 3:
		_spawn_tornado_scene(source + Vector2(source_size.x * 0.10, source_size.y * 0.04), source_size * Vector2(0.96, 1.06), spool_duration * 0.92, intensity + 2, 0.12, Vector2.ZERO, 1.45, "tornado poison")
		_spawn_atmospheric_flipbook("magic_wind", source + Vector2(0.0, source_size.y * 0.02), source_size * Vector2(1.72, 0.82), spool_duration * 1.02, Color(0.48, 1.0, 0.22, 0.26), 0.08, Vector2(0.0, -source_size.y * 0.12), 0.92, 0.82, angle, 1)
		_spawn_status_flipbook("shock", source + Vector2(source_size.x * 0.08, -source_size.y * 0.04), source_size * 0.34, spool_duration * 0.56, Color(0.78, 1.0, 0.34, 0.34), 0.26, Vector2(-source_size.x * 0.06, source_size.y * 0.02), 0.72, 2.05, angle + 0.24, 1)
		_spawn_earth_debris_spray(ground_center, source_size.x * 0.92, spool_duration * 0.68, intensity + 2, 0.16, 3, angle)


func _spawn_earth_debris_spray(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int, angle: float) -> void:
	var count := (5 if tier == 1 else 11) + mini(8, intensity)
	for i in range(count):
		var ratio := (float(i) + 0.5) / float(count)
		var theta := angle + (ratio - 0.5) * PI * 1.38 + sin(float(i) * 1.73) * 0.22
		var direction := Vector2(cos(theta), sin(theta) * 0.48 - 0.34).normalized()
		var key := "dust_puff" if i % 3 == 0 else "stone_chunks"
		var size_base := 26.0 + float(intensity) * 3.6 + float(tier) * 5.0
		var size := Vector2(size_base * 1.34, size_base * 0.86) if key == "dust_puff" else Vector2(size_base * 0.90, size_base * 1.18)
		var start := center + direction * radius * (0.08 + float(i % 4) * 0.025)
		var travel := direction * radius * (0.30 + float(i % 5) * 0.055 + float(tier) * 0.045) + Vector2(0.0, -radius * (0.10 + float(tier) * 0.035))
		var alpha := 0.28 + float(tier) * 0.06 if key == "dust_puff" else 0.48 + float(tier) * 0.05
		_spawn_flipbook(key, start, size, lifetime * (0.42 + float(i % 4) * 0.045), Color(0.64, 0.54, 0.38, alpha), delay + float(i % 6) * lifetime * 0.018, travel, 0.40, 2.45 + float(tier) * 0.18, theta, 0.56)


func _spawn_earth_fracture_travel_layers(source: Vector2, _target: Vector2, delta: Vector2, normal: Vector2, source_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float, tier: int) -> void:
	var lane_center := source + delta * 0.50 + Vector2(0.0, 18.0)
	var lane_length := delta.length() * (0.92 + float(tier) * 0.04)
	var lane_height := (76.0 if tier == 1 else 104.0) + float(intensity) * 11.0 + float(tier) * 16.0
	_spawn_atmospheric_flipbook("caustics", lane_center, Vector2(lane_length, lane_height), travel_duration * 1.22, Color(0.54, 1.0, 0.22, 0.54 if tier == 1 else 0.72), launch_delay, Vector2(0.0, 8.0), 1.04, 1.20, angle, 1)
	_spawn_flipbook("dust_puff", lane_center + Vector2(0.0, lane_height * 0.18), Vector2(lane_length * 0.68, lane_height * 0.34), travel_duration * 0.92, Color(0.48, 0.38, 0.26, 0.22 if tier == 1 else 0.34), launch_delay + travel_duration * 0.08, Vector2(0.0, -12.0), 0.78, 1.02, angle)
	var vein_count := 3 + mini(4, tier + int(floor(float(intensity) / 3.0)))
	for i in range(vein_count):
		var progress := (float(i) + 0.42) / float(vein_count + 1)
		var wave := sin(progress * PI)
		var point := source + delta * progress + normal * sin(float(i) * 1.81) * (12.0 + float(tier) * 4.0) * wave + Vector2(0.0, 20.0 + wave * 8.0)
		var vein_size := Vector2(58.0 + float(intensity) * 6.0, 34.0 + float(intensity) * 3.0) * (1.0 + float(tier) * 0.08)
		_spawn_status_flipbook("weaken", point, vein_size, travel_duration * 0.42, Color(0.62, 1.0, 0.26, 0.34 if tier == 1 else 0.46), launch_delay + travel_duration * (0.12 + progress * 0.50), Vector2(0.0, -18.0 - float(tier) * 5.0), 0.50, 2.22, angle + sin(float(i)) * 0.24, 1)
	if tier >= 2:
		_spawn_atmospheric_flipbook("caustics", lane_center + normal * (16.0 + float(intensity) * 1.4), Vector2(lane_length * 0.82, lane_height * 0.66), travel_duration * 1.02, Color(0.76, 1.0, 0.36, 0.42), launch_delay + travel_duration * 0.08, Vector2(0.0, 12.0), 0.96, 1.05, angle + 0.08, 1)
		_spawn_atmospheric_flipbook("magic_wind", lane_center - normal * (12.0 + float(intensity)), Vector2(lane_length * 0.72, lane_height * 0.74), travel_duration * 0.98, Color(0.46, 0.94, 0.24, 0.26), launch_delay + travel_duration * 0.06, Vector2(0.0, -10.0), 0.90, 1.18, angle - 0.06, 1)
		_spawn_pack_layer("hit_01", lane_center + normal * 12.0, "earth", source_size * 0.46, travel_duration * 0.42, intensity + 1, launch_delay + travel_duration * 0.36, angle, 2.85, 0.38)
	if tier >= 3:
		_spawn_atmospheric_flipbook("fog", lane_center + Vector2(0.0, lane_height * 0.20), Vector2(lane_length * 1.02, lane_height * 0.58), travel_duration * 1.12, Color(0.40, 0.34, 0.24, 0.24), launch_delay + travel_duration * 0.04, Vector2(0.0, -18.0), 0.90, 0.92, angle, 1)
		_spawn_atmospheric_flipbook("caustics", lane_center, Vector2(lane_length * 1.08, lane_height * 0.92), travel_duration * 1.10, Color(0.46, 1.0, 0.18, 0.34), launch_delay + travel_duration * 0.14, Vector2(0.0, 14.0), 0.92, 1.32, angle - 0.04, 1)
	var chunk_count := (4 if tier == 1 else 10) + mini(8, intensity)
	for i in range(chunk_count):
		var progress := (float(i) + 0.30) / float(chunk_count)
		var offset := normal * sin(float(i) * 1.74) * (18.0 + float(tier) * 7.0) + Vector2(0.0, 18.0 + sin(float(i)) * 8.0)
		var start := source + delta * progress + offset
		var move := normal * sin(float(i) * 2.10) * (22.0 + float(intensity) * 2.2) + Vector2(0.0, -34.0 - float(tier) * 10.0)
		var key := "dust_puff" if tier >= 2 and i % 3 == 0 else "stone_chunks"
		var particle_size := Vector2(66.0 + float(intensity) * 7.0, 42.0 + float(intensity) * 4.0) if key == "dust_puff" else Vector2(44.0 + float(intensity) * 5.0, 56.0 + float(intensity) * 5.0)
		var alpha := 0.34 if key == "dust_puff" else 0.54
		_spawn_flipbook(key, start, particle_size, travel_duration * (0.40 if key == "dust_puff" else 0.46), Color(0.66, 0.58, 0.42, alpha), launch_delay + travel_duration * (0.10 + progress * 0.42), move, 0.54, 2.6, angle + sin(float(i)) * 0.42, 0.48)


func _spawn_earth_quake_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, tier: int, screen_wide: bool) -> void:
	var extent := maxf(impact_size.x, impact_size.y)
	var ground_center := center + Vector2(0.0, extent * 0.12)
	_spawn_atmospheric_flipbook("fog", ground_center + Vector2(0.0, extent * 0.04), impact_size * Vector2(0.92 if tier == 1 else 1.12, 0.46 if tier == 1 else 0.58), duration * 0.92, Color(0.42, 0.34, 0.22, 0.20 if tier == 1 else 0.30), delay + duration * 0.02, Vector2(0.0, -extent * 0.08), 0.78, 1.72, 0.0, 1)
	_spawn_atmospheric_flipbook("rain_splash", ground_center + Vector2(0.0, extent * 0.06), impact_size * Vector2(0.74 if tier == 1 else 1.00, 0.36 if tier == 1 else 0.46), duration * 0.70, Color(0.54, 0.84, 0.30, 0.26 if tier == 1 else 0.34), delay + duration * 0.06, Vector2(0.0, -extent * 0.06), 0.62, 2.10, 0.0, 1)
	_spawn_atmospheric_flipbook("bubbles", ground_center + Vector2(0.0, -extent * 0.02), impact_size * Vector2(0.42 if tier == 1 else 0.58, 0.34 if tier == 1 else 0.44), duration * 0.62, Color(0.50, 1.0, 0.24, 0.24 if tier == 1 else 0.34), delay + duration * 0.10, Vector2(0.0, -extent * 0.16), 0.54, 2.42, 0.0, 1)
	_spawn_status_flipbook("weaken", center + Vector2(0.0, extent * 0.02), impact_size * Vector2(0.42 if tier == 1 else 0.54, 0.36 if tier == 1 else 0.44), duration * 0.78, Color(0.66, 1.0, 0.28, 0.34 if tier == 1 else 0.46), delay + duration * 0.04, Vector2(0.0, -extent * 0.04), 0.78, 2.78, 0.06, 1)
	if tier == 1:
		_spawn_status_flipbook("poison", center + Vector2(0.0, extent * 0.02), impact_size * Vector2(0.34, 0.30), duration * 0.64, Color(0.56, 1.0, 0.22, 0.30), delay + duration * 0.10, Vector2(0.0, -extent * 0.05), 0.64, 2.86, -0.10, 1)
	_spawn_flipbook("shockwave_ring", center + Vector2(0.0, extent * 0.08), impact_size * Vector2(0.88 if tier == 1 else 1.02, 0.50 if tier == 1 else 0.56), duration * 0.62, Color(0.78, 1.0, 0.36, 0.48 if tier == 1 else 0.56), delay, Vector2.ZERO, 1.30 if tier == 1 else 1.38, 2.1, 0.0)
	_spawn_pack_layer("impact_01", center + Vector2(0.0, extent * 0.08), "earth", impact_size * (0.48 if tier == 1 else 0.70), duration * 0.58, intensity, delay + duration * 0.04, 0.0, 3.15, 0.50 if tier == 1 else 0.72)
	_spawn_pack_layer("hit_01", center + Vector2(-extent * 0.12, -extent * 0.02), "earth", impact_size * (0.34 if tier == 1 else 0.48), duration * 0.44, intensity + 1, delay + duration * 0.12, -0.22, 3.35, 0.42 if tier == 1 else 0.58)
	_spawn_pack_layer("hit_02", center + Vector2(extent * 0.10, extent * 0.02), "earth", impact_size * (0.28 if tier == 1 else 0.42), duration * 0.38, intensity + 1, delay + duration * 0.20, 0.18, 3.42, 0.36 if tier == 1 else 0.50)
	if tier == 1 or (tier == 2 and intensity <= 3):
		_spawn_pack_layer("impact_02", center + Vector2(-extent * 0.06, extent * 0.06), "earth", impact_size * (0.46 if tier == 1 else 0.58), duration * 0.46, intensity + 1, delay + duration * 0.22, -0.16, 3.48, 0.42 if tier == 1 else 0.54)
		_spawn_flipbook("shockwave_ring", center + Vector2(0.0, extent * 0.16), impact_size * Vector2(1.12 if tier == 1 else 1.26, 0.42), duration * 0.48, Color(0.64, 1.0, 0.28, 0.36 if tier == 1 else 0.46), delay + duration * 0.18, Vector2.ZERO, 1.18, 2.50, -0.02)
	_spawn_flipbook("dust_puff", center + Vector2(0.0, extent * 0.18), impact_size * Vector2(0.78 if tier == 1 else 1.00, 0.40 if tier == 1 else 0.48), duration * 0.82, Color(0.58, 0.44, 0.26, 0.36 if tier == 1 else 0.44), delay + duration * 0.08, Vector2(0.0, -extent * 0.10), 0.72, 2.35, 0.0)
	var impact_chunk_count := (2 if tier == 1 else 5) + mini(6, intensity)
	for i in range(impact_chunk_count):
		var progress := float(i) / float(maxi(1, impact_chunk_count - 1))
		var offset := Vector2((progress - 0.5) * impact_size.x * (0.78 if screen_wide else 0.58), sin(float(i) * 1.5) * impact_size.y * 0.10)
		_spawn_flipbook("stone_chunks", center + offset + Vector2(0.0, extent * 0.04), impact_size * Vector2(0.16, 0.18), duration * 0.52, Color(0.68, 0.58, 0.40, 0.58), delay + duration * (0.06 + progress * 0.16), offset.normalized() * extent * 0.12 + Vector2(0.0, -extent * 0.12), 0.54, 3.3, -0.32 + progress * 0.64, 0.50)
	if tier >= 2:
		_spawn_status_flipbook("poison", center + Vector2(-extent * 0.04, extent * 0.02), impact_size * Vector2(0.52, 0.42), duration * 0.78, Color(0.58, 1.0, 0.24, 0.40), delay + duration * 0.05, Vector2(extent * 0.04, -extent * 0.05), 0.82, 3.05, -0.08, 1)
		_spawn_status_flipbook("shock", center + Vector2(extent * 0.08, -extent * 0.04), impact_size * Vector2(0.28, 0.24), duration * 0.48, Color(0.84, 1.0, 0.36, 0.36), delay + duration * 0.16, Vector2(-extent * 0.05, extent * 0.02), 0.60, 3.42, 0.22, 1)
		_spawn_atmospheric_flipbook("rain_splash", ground_center + Vector2(-extent * 0.05, extent * 0.02), impact_size * Vector2(1.12, 0.44), duration * 0.62, Color(0.48, 0.74, 0.26, 0.30), delay + duration * 0.12, Vector2(extent * 0.04, -extent * 0.08), 0.66, 2.38, 0.04, 1)
		_spawn_atmospheric_flipbook("bubbles", center + Vector2(extent * 0.06, -extent * 0.02), impact_size * Vector2(0.62, 0.46), duration * 0.58, Color(0.54, 1.0, 0.22, 0.30), delay + duration * 0.16, Vector2(-extent * 0.04, -extent * 0.18), 0.52, 3.06, -0.08, 1)
		_spawn_pack_layer("impact_02", center + Vector2(extent * 0.10, -extent * 0.04), "earth", impact_size * 0.62, duration * 0.52, intensity + 1, delay + duration * 0.12, 0.18, 3.50, 0.60)
		_spawn_pack_layer("big_impact_01", center + Vector2(0.0, extent * 0.04), "earth", impact_size * 0.44, duration * 0.48, intensity + 1, delay + duration * 0.22, -0.08, 3.58, 0.34)
		_spawn_flipbook("shockwave_ring", center + Vector2(0.0, extent * 0.14), impact_size * Vector2(1.30, 0.48), duration * 0.56, Color(0.76, 1.0, 0.38, 0.42), delay + duration * 0.08, Vector2.ZERO, 1.24, 2.55, 0.04)
		_spawn_flipbook("dust_puff", center + Vector2(0.0, extent * 0.24), impact_size * Vector2(1.28, 0.42), duration * 0.74, Color(0.42, 0.32, 0.20, 0.30), delay + duration * 0.14, Vector2(0.0, -extent * 0.08), 0.76, 2.05, 0.0)
		_spawn_atmospheric_flipbook("magic_wind", center + Vector2(0.0, extent * 0.04), impact_size * Vector2(0.92, 0.44), duration * 0.74, Color(0.48, 1.0, 0.22, 0.24), delay + duration * 0.14, Vector2(0.0, -extent * 0.06), 0.78, 2.72, 0.0, 1)
		_spawn_burst_particles("earth", center, extent * 0.64, duration * 0.70, intensity + 1)
	if tier >= 3:
		_spawn_atmospheric_flipbook("storm", center + Vector2(0.0, extent * 0.02), impact_size * Vector2(0.84, 0.48), duration * 0.72, Color(0.42, 0.58, 0.36, 0.20), delay + duration * 0.18, Vector2(0.0, -extent * 0.06), 0.72, 2.52, 0.0, 1)
		_spawn_atmospheric_flipbook("rain_splash", ground_center + Vector2(0.0, extent * 0.04), impact_size * Vector2(1.42, 0.62), duration * 0.78, Color(0.52, 0.84, 0.28, 0.40), delay + duration * 0.08, Vector2(0.0, -extent * 0.12), 0.62, 3.34, 0.0, 1)
		_spawn_atmospheric_flipbook("fog", ground_center + Vector2(0.0, extent * 0.10), impact_size * Vector2(1.28, 0.54), duration * 0.90, Color(0.34, 0.28, 0.20, 0.28), delay + duration * 0.04, Vector2(0.0, -extent * 0.10), 0.78, 2.58, 0.0, 1)
		_spawn_atmospheric_flipbook("bubbles", center + Vector2(0.0, -extent * 0.06), impact_size * Vector2(0.78, 0.56), duration * 0.64, Color(0.48, 1.0, 0.20, 0.34), delay + duration * 0.20, Vector2(0.0, -extent * 0.20), 0.50, 3.62, 0.0, 1)
		_spawn_pack_layer("big_impact_02", center + Vector2(-extent * 0.08, -extent * 0.02), "earth", impact_size * 0.52, duration * 0.56, intensity + 2, delay + duration * 0.26, 0.16, 3.76, 0.46)
		_spawn_flipbook("shockwave_ring", center + Vector2(0.0, extent * 0.18), impact_size * Vector2(1.44, 0.54), duration * 0.64, Color(0.62, 1.0, 0.28, 0.42), delay + duration * 0.20, Vector2.ZERO, 1.20, 3.02, 0.06)
		_spawn_earth_debris_spray(center + Vector2(0.0, extent * 0.08), extent * 0.58, duration * 0.70, intensity + 2, delay + duration * 0.18, 3, 0.0)
	_spawn_light(center, Color(0.92, 0.74, 0.44, 1.0), 2.0 + float(intensity) * (0.24 + float(tier) * 0.05), extent * (0.88 + float(tier) * 0.12), duration * 0.58, delay)


func _spawn_earth_tornado_atmosphere(center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, _screen_wide: bool) -> void:
	var layer_size := _vfx_layer_size()
	var focus := center
	var max_width := layer_size.x * 0.86 if layer_size.x > 1.0 else draw_size.x
	var max_height := clampf(layer_size.y * 0.13, 96.0, 130.0) if layer_size.y > 1.0 else draw_size.y
	var atmosphere_size := Vector2(minf(draw_size.x, max_width), minf(draw_size.y, max_height))
	_spawn_atmospheric_flipbook("tornado", focus + Vector2(0.0, atmosphere_size.y * 0.02), atmosphere_size, duration * 1.18, Color(0.62, 0.62, 0.56, 0.44), delay, Vector2.ZERO, 1.03, 0.70, 0.0, 2)
	_spawn_atmospheric_flipbook("fog", focus + Vector2(0.0, atmosphere_size.y * 0.24), atmosphere_size * Vector2(0.96, 0.42), duration * 1.10, Color(0.34, 0.28, 0.20, 0.30), delay + duration * 0.04, Vector2(0.0, -atmosphere_size.y * 0.06), 0.82, 0.88, 0.0, 1)
	_spawn_atmospheric_flipbook("rain_splash", focus + Vector2(0.0, atmosphere_size.y * 0.36), atmosphere_size * Vector2(0.86, 0.30), duration * 0.76, Color(0.50, 0.80, 0.26, 0.28), delay + duration * 0.10, Vector2(0.0, -atmosphere_size.y * 0.05), 0.62, 1.18, 0.0, 1)
	_spawn_atmospheric_flipbook("bubbles", focus + Vector2(0.0, atmosphere_size.y * 0.06), atmosphere_size * Vector2(0.38, 0.30), duration * 0.66, Color(0.46, 1.0, 0.20, 0.28), delay + duration * 0.16, Vector2(0.0, -atmosphere_size.y * 0.16), 0.52, 1.32, 0.0, 1)
	_spawn_status_flipbook("weaken", focus + Vector2(0.0, atmosphere_size.y * 0.02), atmosphere_size * Vector2(0.24, 0.22), duration * 0.58, Color(0.70, 1.0, 0.28, 0.32), delay + duration * 0.16, Vector2(0.0, -atmosphere_size.y * 0.10), 0.58, 1.48, 0.12, 1)
	_spawn_flipbook("dust_puff", focus + Vector2(0.0, atmosphere_size.y * 0.30), atmosphere_size * Vector2(0.82, 0.28), duration * 1.00, Color(0.50, 0.42, 0.32, 0.28), delay + duration * 0.08, Vector2(0.0, -atmosphere_size.y * 0.08), 0.78, 1.05, 0.0)
	_spawn_burst_particles("earth", focus + Vector2(0.0, atmosphere_size.y * 0.12), maxf(atmosphere_size.x, atmosphere_size.y) * 0.22, duration * 0.72, intensity + 1)


func _spawn_status_armor_linger(center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var size := draw_size * (1.0 + float(intensity) * 0.035)
	_spawn_shield_scene(center, size * Vector2(0.86, 0.48), lifetime * 1.04, intensity, 0.0, Vector2.ZERO, 1.8)
	_spawn_status_flipbook("shield", center, size * Vector2(0.92, 0.58), lifetime * 1.12, Color(0.86, 0.96, 1.0, 0.76), 0.0, Vector2.ZERO, 1.06, 2.1, 0.0, 2)
	_spawn_status_flipbook("armor", center + Vector2(0.0, -draw_size.y * 0.06), size * Vector2(0.48, 0.40), lifetime * 0.78, Color(0.58, 0.84, 1.0, 0.52), lifetime * 0.08, Vector2.ZERO, 0.95, 2.5, 0.0, 1)
	_spawn_light(center, Color(0.80, 0.94, 1.0, 1.0), 2.4 + float(intensity) * 0.22, draw_size.x * 0.82, lifetime)


func _spawn_status_cast_recipe(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color, accent: Color) -> void:
	var clean_kind := _clean_kind(kind)
	var spool_duration := maxf(0.62, spool_lifetime * 1.46)
	var travel_duration := maxf(0.46, travel_lifetime * 1.34)
	var launch_delay := maxf(0.42, spool_duration * 0.80)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var travel_size := Vector2(128 + intensity * 16, 106 + intensity * 10)
	if clean_kind == "fire":
		_spawn_fire_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)
		return
	if clean_kind == "ice":
		_spawn_ice_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)
		return
	if clean_kind == "earth":
		_spawn_earth_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)
		return
	_spawn_light(source, core, 2.1 + float(intensity) * 0.24, spool_size.x * 1.32, spool_duration * 1.08)
	_spawn_atmospheric_travel(clean_kind, source, delta, launch_delay, travel_duration, intensity, angle)
	match clean_kind:
		"fire":
			_spawn_status_flipbook("burn", source, spool_size * 0.52, spool_duration * 0.88, Color(1.0, 0.88, 0.52, 0.68), 0.0, Vector2.ZERO, 1.10, 1.0, angle, 1)
			_spawn_flame_scene(source, spool_size * 0.82, spool_duration * 1.10, intensity, 0.0, Vector2(0.0, -16.0), 1.5, 0.95)
			_spawn_status_path_afterimage("fire", source, delta, launch_delay, travel_duration, intensity, angle)
			_spawn_beam_effect(source, delta, "fire", travel_duration * 0.86, intensity, launch_delay, 1.0)
			_spawn_status_flipbook("burn", source, travel_size * Vector2(0.56, 0.48), travel_duration, Color(1.0, 0.74, 0.34, 0.48), launch_delay, delta, 0.78, 2.4, angle, 1)
			_spawn_flame_scene(target, spool_size * (1.08 + float(intensity) * 0.04), travel_duration * 1.14, intensity, launch_delay + travel_duration * 0.82, Vector2.ZERO, 2.8, 0.90)
			_spawn_status_flipbook("rage", target, spool_size * (0.42 + float(intensity) * 0.018), travel_duration * 0.92, Color(1.0, 0.36, 0.12, 0.50), launch_delay + travel_duration * 0.84, Vector2.ZERO, 1.10, 3.0, angle, 1)
		"ice":
			_spawn_status_flipbook("freeze", source, spool_size * 0.52, spool_duration * 0.94, Color(0.84, 0.98, 1.0, 0.64), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1)
			_spawn_status_flipbook("slow", source + normal * 10.0, spool_size * 0.34, spool_duration * 0.82, Color(0.54, 0.88, 1.0, 0.42), 0.08, Vector2.ZERO, 0.94, 1.5, angle, 1)
			_spawn_status_path_afterimage("ice", source, delta, launch_delay, travel_duration * 1.10, intensity, angle)
			_spawn_windy_ice_block_travel_layers(source, source + delta, delta, normal, travel_size, travel_duration, launch_delay, intensity, angle)
			for lane_index in [-1, 1]:
				var lane := normal * float(lane_index) * (13.0 + float(intensity) * 2.0)
				_spawn_status_flipbook("freeze", source + lane, travel_size * Vector2(0.42, 0.38), travel_duration * 0.96, Color(0.76, 0.94, 1.0, 0.40), launch_delay + (0.05 if lane_index > 0 else 0.0), delta - lane * 0.35, 0.78, 2.2, angle + float(lane_index) * 0.10, 1)
			_spawn_status_flipbook("freeze", target, spool_size * (0.52 + float(intensity) * 0.018), travel_duration * 1.12, Color(0.82, 0.98, 1.0, 0.66), launch_delay + travel_duration * 0.86, Vector2.ZERO, 1.12, 3.0, angle, 1)
		"earth":
			_spawn_atmospheric_flipbook("bubbles", source + Vector2(0.0, 16.0), spool_size * Vector2(0.72, 0.40), spool_duration * 0.86, Color(0.54, 1.0, 0.24, 0.34), 0.0, Vector2(0.0, -12.0), 0.70, 1.0, angle, 1)
			_spawn_flipbook("dust_puff", source + Vector2(0.0, 22.0), spool_size * Vector2(0.94, 0.42), spool_duration, Color(0.50, 0.40, 0.28, 0.34), 0.08, Vector2(0.0, -12.0), 0.82, 1.4, angle)
			_spawn_status_path_afterimage("earth", source, delta, launch_delay * 0.74, travel_duration * 1.30, intensity + 1, angle)
			_spawn_flipbook("dust_puff", source, travel_size * Vector2(0.58, 0.34), travel_duration * 1.02, Color(0.58, 0.46, 0.30, 0.38), launch_delay, delta, 0.88, 2.2, angle)
			_spawn_flipbook("dust_puff", target + Vector2(0.0, 18.0), spool_size * Vector2(1.06, 0.42), travel_duration * 0.88, Color(0.48, 0.36, 0.24, 0.34), launch_delay + travel_duration * 0.86, Vector2(0.0, -18.0), 0.76, 2.6, angle)
			_spawn_flipbook("stone_chunks", target + Vector2(0.0, 10.0), spool_size * (0.34 + float(intensity) * 0.014), travel_duration * 0.72, Color(0.68, 0.58, 0.40, 0.54), launch_delay + travel_duration * 0.90, Vector2.ZERO, 1.02, 3.0, angle)
		"heart":
			_spawn_status_flipbook("heal", source, spool_size * 0.48, spool_duration * 0.90, Color(0.82, 1.0, 0.76, 0.60), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1)
			_spawn_status_path_afterimage("heart", source, delta, launch_delay, travel_duration * 1.16, intensity, angle)
			for lane_index in [-1, 0, 1]:
				var lane := normal * float(lane_index) * (10.0 + float(intensity))
				_spawn_status_flipbook("regen", source + lane, travel_size * Vector2(0.34, 0.42), travel_duration * 1.02, Color(0.56, 1.0, 0.62, 0.38), launch_delay + float(lane_index + 1) * 0.035, delta - lane * 0.30, 0.78, 2.2, angle, 1)
			_spawn_status_flipbook("heal", target, spool_size * (0.50 + float(intensity) * 0.018), travel_duration * 1.10, Color(0.82, 1.0, 0.76, 0.62), launch_delay + travel_duration * 0.84, Vector2(0.0, -20.0), 1.08, 3.0, angle, 1)
		"armor":
			_spawn_status_flipbook("shield", source, spool_size * 0.48, spool_duration * 0.86, Color(0.84, 0.96, 1.0, 0.58), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1)
			_spawn_beam_effect(source, delta, "armor", travel_duration * 0.86, intensity, launch_delay, 0.74)
			_spawn_status_flipbook("shield", source, travel_size * Vector2(0.34, 0.38), travel_duration * 0.94, Color(0.66, 0.88, 1.0, 0.36), launch_delay, delta, 0.80, 2.2, angle, 1)
			_spawn_shield_scene(target, spool_size * (0.84 + float(intensity) * 0.035), travel_duration * 1.28, intensity, launch_delay + travel_duration * 0.82, Vector2.ZERO, 3.0)
			_spawn_status_flipbook("armor", target, spool_size * (0.40 + float(intensity) * 0.014), travel_duration * 0.94, Color(0.72, 0.90, 1.0, 0.42), launch_delay + travel_duration * 0.88, Vector2.ZERO, 1.04, 3.2, angle, 1)
		"gold":
			_spawn_status_flipbook("blessed", source, spool_size * 0.46, spool_duration * 0.86, Color(1.0, 0.90, 0.38, 0.60), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1)
			_spawn_beam_effect(source, delta, "gold", travel_duration * 0.78, intensity, launch_delay, 0.70)
			_spawn_status_flipbook("haste", source, travel_size * Vector2(0.36, 0.34), travel_duration * 0.86, Color(1.0, 0.92, 0.32, 0.38), launch_delay, delta, 0.80, 2.2, angle, 1)
			_spawn_status_flipbook("blessed", target, spool_size * (0.44 + float(intensity) * 0.014), travel_duration * 0.90, Color(1.0, 0.86, 0.32, 0.58), launch_delay + travel_duration * 0.82, Vector2.ZERO, 1.08, 3.0, angle, 1)
			_spawn_coin_rain(target, spool_size.x, travel_duration * 1.28, intensity, false)
		_:
			_spawn_status_flipbook(_status_sheet_key(clean_kind), source, spool_size, spool_duration, Color(core.r, core.g, core.b, 0.88), 0.0, Vector2.ZERO, 1.12, 1.0, angle, 1)
			_spawn_status_flipbook(_status_sheet_key(clean_kind), source, travel_size, travel_duration, Color(accent.r, accent.g, accent.b, 0.72), launch_delay, delta, 0.86, 2.2, angle, 1)
			_spawn_status_flipbook(_status_sheet_key(clean_kind), target, spool_size, travel_duration * 1.14, Color(core.r, core.g, core.b, 0.90), launch_delay + travel_duration * 0.86, Vector2.ZERO, 1.12, 3.0, angle, 1)
	_spawn_camera_kick(delta.normalized() * (5.0 + float(intensity) * 1.1), launch_delay + travel_duration * 0.90)


func _spawn_status_beam_recipe(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	var clean_kind := _clean_kind(kind)
	var duration := maxf(0.34, lifetime * 1.20)
	if clean_kind == "fire":
		_spawn_fire_beam_layers(source, delta, duration, intensity, angle)
		return
	if clean_kind == "ice":
		var normal := Vector2(-delta.y, delta.x).normalized()
		var travel_size := Vector2(150.0 + float(intensity) * 16.0, 116.0 + float(intensity) * 10.0)
		_spawn_windy_ice_block_travel_layers(source, source + delta, delta, normal, travel_size, duration, 0.0, intensity, angle)
		return
	if clean_kind == "earth":
		var normal := Vector2(-delta.y, delta.x).normalized()
		var travel_size := Vector2(152.0 + float(intensity) * 18.0, 110.0 + float(intensity) * 9.0)
		_spawn_earth_fracture_travel_layers(source, source + delta, delta, normal, travel_size, duration, 0.0, intensity, angle, _earth_vfx_tier(intensity))
		return
	_spawn_atmospheric_travel(clean_kind, source, delta, 0.0, duration, intensity, angle)
	_spawn_beam_effect(source, delta, clean_kind, duration, intensity, 0.0, 0.72)
	_spawn_status_path_afterimage(clean_kind, source, delta, 0.0, duration, intensity, angle)
	_spawn_status_flipbook(_status_sheet_key(clean_kind), source, Vector2(112 + intensity * 9, 88 + intensity * 6), duration, Color(1, 1, 1, 0.58), 0.0, delta, 0.74, 2.2, angle, 1)


func _spawn_status_path_afterimage(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	var clean_kind := _clean_kind(kind)
	var count := 4 + mini(7, intensity)
	var normal := Vector2(-delta.y, delta.x).normalized()
	for i in range(count):
		var progress := (float(i) + 0.35) / float(count + 1)
		var wave := sin(progress * PI)
		var lane := normal * sin(float(i) * 1.65) * (9.0 + float(intensity) * 1.9) * wave
		if clean_kind == "earth":
			lane += Vector2(0.0, 16.0 * wave)
		elif clean_kind == "ice":
			lane += normal * float(i % 2 * 2 - 1) * 7.0
		elif clean_kind == "heart":
			lane += Vector2(0.0, -10.0 * wave)
		var point := source + delta * progress + lane
		var delay := launch_delay + travel_duration * progress * 0.70
		var size := Vector2(58 + intensity * 7, 58 + intensity * 6)
		var alpha := 0.46
		if clean_kind == "fire":
			size *= Vector2(1.04, 0.86)
			alpha = 0.54
		elif clean_kind == "earth":
			size *= Vector2(1.28, 0.72)
			alpha = 0.56
		elif clean_kind == "ice":
			size *= Vector2(0.92, 1.08)
			alpha = 0.44
		elif clean_kind == "heart":
			size *= Vector2(0.76, 1.08)
			alpha = 0.40
		_spawn_status_flipbook(_status_trail_key(clean_kind), point, size, travel_duration * 0.48, Color(1, 1, 1, alpha), delay, Vector2.ZERO, 0.58, 1.4, angle + sin(float(i)) * 0.18, 1)


func _spawn_status_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0:
		return
	var clean_kind := _clean_kind(kind)
	var offensive := clean_kind in ["fire", "ice", "earth", "damage"]
	var focus_y := clampf(center.y, layer_size.y * (0.08 if offensive else 0.38), layer_size.y * (0.42 if offensive else 0.86))
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var colors := _kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	var sheet_key := _status_sheet_key(clean_kind)
	var wide_size := Vector2(layer_size.x * 0.78, layer_size.y * (0.32 if offensive else 0.42))
	_spawn_status_flipbook(sheet_key, focus, wide_size, lifetime * 1.04, Color(1, 1, 1, 0.46), 0.0, Vector2.ZERO, 1.06, -1.2, 0.0, 1)
	_spawn_light(focus, core, 3.2 + float(intensity) * 0.28, layer_size.x * 0.70, lifetime * 0.72)
	var burst_count := 4 + mini(6, intensity)
	for i in range(burst_count):
		var x := layer_size.x * (0.14 + float(i) / float(maxi(1, burst_count - 1)) * 0.72)
		var y := focus_y + sin(float(i) * 1.7) * layer_size.y * 0.052
		var delay := lifetime * (0.04 + float(i % 4) * 0.035)
		_spawn_status_flipbook(_status_trail_key(clean_kind), Vector2(x, y), wide_size * 0.22, lifetime * 0.62, Color(1, 1, 1, 0.42), delay, Vector2(sin(float(i)) * 28.0, -8.0), 0.76, 2.1, sin(float(i)) * 0.28, 1)
	if clean_kind == "gold":
		_spawn_coin_rain(focus, layer_size.x * 0.34, lifetime * 1.2, intensity, true)


func _spawn_atmospheric_replay_layer(kind: String, center: Vector2, max_size: float, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	if not _atmospheric_vfx_available():
		return
	var clean_kind := _clean_kind(kind)
	var key := _atmospheric_impact_key(clean_kind)
	var colors := _kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	var accent: Color = colors.get("accent", Color.WHITE)
	var wide := Vector2(base_size * (1.26 if screen_wide else 0.82), base_size * (0.74 if screen_wide else 0.48))
	if clean_kind in ["heart", "armor", "gold"]:
		wide = Vector2(base_size * (1.05 if screen_wide else 0.72), base_size * (0.88 if screen_wide else 0.62))
	if clean_kind == "earth":
		wide *= Vector2(1.12, 0.76)
	_spawn_atmospheric_flipbook(key, center, wide, lifetime * 1.06, Color(core.r, core.g, core.b, 0.34), 0.0, Vector2.ZERO, 1.04, 0.55, 0.0, 1)
	if intensity >= 5:
		var secondary := _atmospheric_secondary_key(clean_kind)
		_spawn_atmospheric_flipbook(secondary, center + Vector2(0.0, -max_size * 0.10), wide * Vector2(1.12, 0.76), lifetime * 0.88, Color(accent.r, accent.g, accent.b, 0.24), lifetime * 0.04, Vector2(0.0, -max_size * 0.06), 0.96, 0.42, sin(float(intensity)) * 0.10, 1)


func _spawn_atmospheric_travel(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	if not _atmospheric_vfx_available() or delta.length() <= 1.0:
		return
	var clean_kind := _clean_kind(kind)
	var colors := _kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	var accent: Color = colors.get("accent", Color.WHITE)
	var length := delta.length()
	var lane_height := maxf(78.0 + float(intensity) * 12.0, length * (0.18 + float(intensity) * 0.008))
	var lane_length := length * (0.92 + float(intensity) * 0.035)
	var center := source + delta * 0.50
	if clean_kind == "earth":
		lane_height *= 1.16
		center += Vector2(0.0, 16.0)
	elif clean_kind == "heart":
		center += Vector2(0.0, -12.0)
	elif clean_kind == "armor":
		lane_height *= 1.08
	var key := _atmospheric_travel_key(clean_kind)
	_spawn_atmospheric_flipbook(key, center, Vector2(lane_length, lane_height), travel_duration * 1.20, Color(core.r, core.g, core.b, 0.46), launch_delay, Vector2.ZERO, 1.02, 1.15, angle, 1)
	if intensity >= 4:
		var secondary_key := _atmospheric_secondary_key(clean_kind)
		var normal := Vector2(-delta.y, delta.x).normalized()
		_spawn_atmospheric_flipbook(secondary_key, center + normal * (10.0 + float(intensity) * 1.8), Vector2(lane_length * 0.86, lane_height * 0.72), travel_duration * 1.00, Color(accent.r, accent.g, accent.b, 0.32), launch_delay + travel_duration * 0.10, Vector2.ZERO, 0.96, 1.0, angle + 0.05, 1)
	if intensity >= 7:
		_spawn_atmospheric_flipbook(key, center, Vector2(lane_length * 1.20, lane_height * 1.28), travel_duration * 1.32, Color(core.r, core.g, core.b, 0.26), launch_delay, Vector2.ZERO, 1.04, 0.80, angle, 1)


func _spawn_atmospheric_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, target_scale: float = 1.0, z: float = 0.0, rotation: float = 0.0, loops: int = 1) -> Sprite3D:
	if not _ensure_overlay():
		return null
	var texture := _atmospheric_texture(sheet_key)
	if texture == null:
		return null
	var sprite := Sprite3D.new()
	sprite.name = "AtmosphericVfx_%s" % sheet_key
	sprite.texture = texture
	sprite.hframes = ATMOSPHERIC_FRAMES
	sprite.vframes = 1
	sprite.frame = 0
	sprite.centered = true
	sprite.pixel_size = 1.0
	sprite.modulate = Color(color.r, color.g, color.b, 0.0 if delay > 0.0 else color.a)
	var cell_size := Vector2(float(texture.get_width()) / float(ATMOSPHERIC_FRAMES), float(texture.get_height()))
	sprite.scale = Vector3(draw_size.x / cell_size.x, draw_size.y / cell_size.y, 1.0)
	sprite.position = _screen_to_world_position(center_local, z)
	sprite.rotation = Vector3(0.0, 0.0, _screen_to_world_rotation(rotation))
	_root_3d.add_child(sprite)
	_tween_atmospheric_sprite3d(sprite, lifetime, target_scale, delay, move_offset, color.a, maxi(1, loops))
	return sprite


func _tween_atmospheric_sprite3d(sprite: Sprite3D, lifetime: float, target_scale: float, delay: float, move_offset: Vector2, target_alpha: float, loops: int) -> void:
	if sprite == null:
		return
	var duration := maxf(0.12, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		sprite.queue_free()
		return
	var start_scale := sprite.scale
	var start_position := sprite.position
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_property(sprite, "modulate:a", target_alpha, 0.08).set_delay(delay)
	var total_frames := ATMOSPHERIC_FRAMES * maxi(1, loops) - 1
	tween.tween_method(func(value: float) -> void:
		if is_instance_valid(sprite):
			sprite.frame = int(floor(value)) % ATMOSPHERIC_FRAMES
	, 0.0, float(total_frames), duration).set_delay(delay)
	tween.tween_property(sprite, "scale", start_scale * target_scale, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if move_offset != Vector2.ZERO:
		tween.tween_property(sprite, "position", start_position + _screen_to_world_offset(move_offset), duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	tween.tween_property(sprite, "modulate:a", 0.0, duration * 0.42).set_delay(delay + duration * 0.58)
	tween.finished.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.queue_free()
	)


func _spawn_status_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, target_scale: float = 1.0, z: float = 0.0, rotation: float = 0.0, loops: int = 1, spin: float = 0.0) -> Sprite3D:
	if not _ensure_overlay():
		return null
	var texture := _status_texture(sheet_key)
	if texture == null:
		return null
	var sprite := Sprite3D.new()
	sprite.name = "StatusVfx_%s" % sheet_key
	sprite.texture = texture
	sprite.hframes = GRID_COLUMNS
	sprite.vframes = GRID_ROWS
	sprite.frame = 0
	sprite.centered = true
	sprite.pixel_size = 1.0
	sprite.modulate = Color(color.r, color.g, color.b, 0.0 if delay > 0.0 else color.a)
	var cell_size := Vector2(float(texture.get_width()) / float(GRID_COLUMNS), float(texture.get_height()) / float(GRID_ROWS))
	sprite.scale = Vector3(draw_size.x / cell_size.x, draw_size.y / cell_size.y, 1.0)
	sprite.position = _screen_to_world_position(center_local, z)
	sprite.rotation = Vector3(0.0, 0.0, _screen_to_world_rotation(rotation))
	_root_3d.add_child(sprite)
	_tween_status_sprite3d(sprite, lifetime, target_scale, delay, move_offset, spin, color.a, maxi(1, loops))
	return sprite


func _tween_status_sprite3d(sprite: Sprite3D, lifetime: float, target_scale: float, delay: float, move_offset: Vector2, spin: float, target_alpha: float, loops: int) -> void:
	if sprite == null:
		return
	var duration := maxf(0.12, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		sprite.queue_free()
		return
	var start_scale := sprite.scale
	var start_position := sprite.position
	var start_rotation := sprite.rotation.z
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_property(sprite, "modulate:a", target_alpha, 0.06).set_delay(delay)
	var total_frames := PRIMARY_FRAMES * maxi(1, loops) - 1
	tween.tween_method(func(value: float) -> void:
		if is_instance_valid(sprite):
			sprite.frame = int(floor(value)) % PRIMARY_FRAMES
	, 0.0, float(total_frames), duration).set_delay(delay)
	tween.tween_property(sprite, "scale", start_scale * target_scale, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if move_offset != Vector2.ZERO:
		tween.tween_property(sprite, "position", start_position + _screen_to_world_offset(move_offset), duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	if not is_zero_approx(spin):
		tween.tween_property(sprite, "rotation:z", start_rotation - spin, duration).set_delay(delay)
	tween.tween_property(sprite, "modulate:a", 0.0, duration * 0.44).set_delay(delay + duration * 0.58)
	tween.finished.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.queue_free()
	)


func _spawn_flame_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0, alpha: float = 1.0) -> Node3D:
	if not _ensure_overlay():
		return null
	var scene := _flame_scene()
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "FlamePackVfx"
	effect.position = _screen_to_world_position(center_local, z)
	var longest := maxf(draw_size.x, draw_size.y)
	effect.scale = Vector3.ONE * maxf(18.0, longest / 4.4)
	effect.visible = delay <= 0.0
	_root_3d.add_child(effect)
	_set_node_property_if_present(effect, "autoplay", false)
	_set_node_property_if_present(effect, "audio_playing", false)
	_set_node_property_if_present(effect, "volume_db", -80.0)
	_set_node_property_if_present(effect, "primary_color", Color(1.0, 0.78, 0.28, alpha))
	_set_node_property_if_present(effect, "secondary_color", Color(1.0, 0.20, 0.04, alpha))
	_set_node_property_if_present(effect, "light_color", Color(1.0, 0.58, 0.18, alpha))
	_set_node_property_if_present(effect, "emission", 5.2 + float(intensity) * 0.34)
	_set_node_property_if_present(effect, "light_energy", 3.6 + float(intensity) * 0.34)
	_set_node_property_if_present(effect, "particles_amount", mini(96, 34 + intensity * 8))
	_set_node_property_if_present(effect, "lifetime", maxf(0.35, lifetime * 0.58))
	_set_node_property_if_present(effect, "speed_scale", 0.72 + float(intensity) * 0.025)
	_animate_imported_node(effect, lifetime, delay, move_offset, 1.06, 0.0)
	return effect


func _spawn_beam_effect(source_local: Vector2, delta: Vector2, kind: String, lifetime: float, intensity: int, delay: float = 0.0, radius_scale: float = 1.0) -> Node3D:
	if not _ensure_overlay():
		return null
	var scene := _beam_scene()
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "BeamPackVfx_%s" % kind
	effect.position = _screen_to_world_position(source_local, 2.0)
	effect.visible = delay <= 0.0
	_root_3d.add_child(effect)
	var world_delta := _screen_to_world_offset(delta)
	if world_delta.length() > 0.1:
		effect.look_at(effect.position + world_delta.normalized(), Vector3.UP)
	var colors := _elemental_kind_colors(kind)
	var primary: Color = colors.get("primary", Color.WHITE)
	var secondary: Color = colors.get("secondary", primary)
	var tertiary: Color = colors.get("tertiary", secondary)
	_set_node_property_if_present(effect, "primary_color", primary)
	_set_node_property_if_present(effect, "secondary_color", secondary)
	_set_node_property_if_present(effect, "tertiary_color", tertiary)
	_set_node_property_if_present(effect, "emission", 3.0 + float(intensity) * 0.28)
	_set_node_property_if_present(effect, "beam_length", maxf(4.0, delta.length()))
	_set_node_property_if_present(effect, "beam_radius", (3.0 + float(intensity) * 0.42) * radius_scale)
	_set_node_property_if_present(effect, "start_radius", (10.0 + float(intensity) * 1.4) * radius_scale)
	_set_node_property_if_present(effect, "start_flare", 0.62 + float(intensity) * 0.025)
	_set_node_property_if_present(effect, "pulse_strength", 0.08 + float(intensity) * 0.014)
	_set_node_property_if_present(effect, "start_amount", mini(96, 28 + intensity * 8))
	_set_node_property_if_present(effect, "end_amount", mini(96, 24 + intensity * 7))
	_set_node_property_if_present(effect, "audio_playing", false)
	_set_node_property_if_present(effect, "audio_autoplay", false)
	_set_node_property_if_present(effect, "volume_db", -80.0)
	_set_node_property_if_present(effect, "open_amount", 0.0)
	_animate_beam_node(effect, lifetime, delay)
	return effect


func _spawn_shield_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0) -> Node3D:
	if not _ensure_overlay():
		return null
	var scene := _shield_scene()
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "ShieldPackVfx"
	effect.position = _screen_to_world_position(center_local, z)
	effect.scale = Vector3(maxf(32.0, draw_size.x * 0.50), maxf(28.0, draw_size.y * 0.50), 1.0)
	effect.visible = delay <= 0.0
	_root_3d.add_child(effect)
	_prepare_imported_scene(effect, "")
	_scale_imported_particles(effect, mini(48, 8 + intensity * 4))
	_animate_imported_node(effect, lifetime, delay, move_offset, 1.08, 0.0)
	return effect


func _spawn_tornado_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0, keep_child_name: String = "") -> Node3D:
	if not _ensure_overlay():
		return null
	var scene := _tornado_scene()
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "TornadoPackVfx_%s" % keep_child_name
	effect.position = _screen_to_world_position(center_local, z)
	var longest := maxf(draw_size.x, draw_size.y)
	effect.scale = Vector3.ONE * maxf(10.0, longest / 8.0)
	effect.visible = delay <= 0.0
	_root_3d.add_child(effect)
	_prepare_imported_scene(effect, keep_child_name)
	_scale_imported_particles(effect, mini(70, 18 + intensity * 6))
	_animate_imported_node(effect, lifetime, delay, move_offset, 1.12, 0.0)
	return effect


func _prepare_imported_scene(root: Node3D, keep_child_name: String) -> void:
	for child in root.get_children():
		if child is Camera3D or child is WorldEnvironment:
			child.queue_free()
			continue
		if keep_child_name != "" and child is Node3D:
			child.visible = child.name == keep_child_name
			if child.name == keep_child_name:
				child.position += Vector3(-5.6, 1.0, 3.9)


func _scale_imported_particles(root: Node, amount: int) -> void:
	if root is GPUParticles3D:
		root.amount = amount
		root.emitting = true
	for child in root.get_children():
		_scale_imported_particles(child, amount)


func _animate_imported_node(effect: Node3D, lifetime: float, delay: float, move_offset: Vector2, target_scale: float, spin: float) -> void:
	if effect == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		effect.queue_free()
		return
	var duration := maxf(0.14, lifetime)
	var start_scale := effect.scale
	var start_position := effect.position
	var start_rotation := effect.rotation.z
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_callback(func() -> void:
			if is_instance_valid(effect):
				effect.visible = true
		).set_delay(delay)
	tween.tween_property(effect, "scale", start_scale * target_scale, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if move_offset != Vector2.ZERO:
		tween.tween_property(effect, "position", start_position + _screen_to_world_offset(move_offset), duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	if not is_zero_approx(spin):
		tween.tween_property(effect, "rotation:z", start_rotation - spin, duration).set_delay(delay)
	tween.finished.connect(func() -> void:
		if is_instance_valid(effect):
			effect.queue_free()
	)


func _animate_beam_node(effect: Node3D, lifetime: float, delay: float) -> void:
	if effect == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		effect.queue_free()
		return
	var duration := maxf(0.16, lifetime)
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_callback(func() -> void:
			if is_instance_valid(effect):
				effect.visible = true
		).set_delay(delay)
	tween.tween_property(effect, "open_amount", 1.0, duration * 0.28).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.tween_property(effect, "open_amount", 0.0, duration * 0.34).set_delay(delay + duration * 0.66).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN as Tween.EaseType)
	tween.finished.connect(func() -> void:
		if is_instance_valid(effect):
			effect.queue_free()
	)


func _status_sheet_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "burn"
		"ice":
			return "freeze"
		"earth":
			return "poison"
		"heart":
			return "heal"
		"armor":
			return "shield"
		"gold":
			return "blessed"
		"damage":
			return "bleed"
	return "shock"


func _status_trail_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "rage"
		"ice":
			return "slow"
		"earth":
			return "weaken"
		"heart":
			return "regen"
		"armor":
			return "armor"
		"gold":
			return "haste"
		"damage":
			return "stun"
	return _status_sheet_key(kind)


func _atmospheric_travel_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "embers"
		"ice":
			return "snow"
		"earth":
			return "caustics"
		"heart":
			return "magic_wind"
		"armor":
			return "godrays"
		"gold":
			return "meteor"
		"damage":
			return "storm"
	return "magic_wind"


func _atmospheric_impact_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "embers"
		"ice":
			return "frost"
		"earth":
			return "rain_splash"
		"heart":
			return "fireflies"
		"armor":
			return "godrays"
		"gold":
			return "fireflies"
		"damage":
			return "storm"
	return "fog"


func _atmospheric_secondary_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "meteor"
		"ice":
			return "frost"
		"earth":
			return "bubbles"
		"heart":
			return "godrays"
		"armor":
			return "caustics"
		"gold":
			return "godrays"
		"damage":
			return "embers"
	return "fog"


func _spawn_elemental_replay_recipe(kind: String, center: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	var clean_kind := _clean_kind(kind)
	var area_size := Vector2(base_size, base_size) * (1.35 if screen_wide else 0.86)
	match clean_kind:
		"fire":
			_spawn_elemental_effect("area", center, "fire", area_size * 1.10, duration * 1.32, intensity, 0.0, Vector2.ZERO, 0.0, 0.45, 0.96)
			_spawn_elemental_effect("projectile", center + Vector2(-max_size * 0.62, max_size * 0.16), "fire", Vector2(base_size * 0.88, base_size * 0.36), duration * 0.54, intensity, 0.02, Vector2(max_size * 1.18, -max_size * 0.18), -0.12, 1.8, 0.76)
			_spawn_elemental_effect("cast", center + Vector2(0.0, -max_size * 0.22), "fire", area_size * 0.56, duration * 0.82, intensity, 0.06, Vector2.ZERO, 0.0, 1.4, 0.72)
			_spawn_pack_layer(_pack_impact_scene_key("fire", intensity, screen_wide), center, "fire", area_size * 0.52, duration * 0.58, intensity, 0.05, 0.10, 2.0, 0.62)
			_spawn_pack_layer("hit_01", center + Vector2(max_size * 0.12, -max_size * 0.08), "fire", area_size * 0.32, duration * 0.44, intensity, 0.14, -0.35, 2.4, 0.58)
		"ice":
			_spawn_elemental_effect("area", center, "ice", area_size * 0.92, duration * 1.48, intensity, 0.0, Vector2.ZERO, 0.0, 0.40, 0.86)
			_spawn_elemental_effect("projectile", center + Vector2(-max_size * 0.58, -max_size * 0.12), "ice", Vector2(base_size * 0.74, base_size * 0.28), duration * 0.70, intensity, 0.04, Vector2(max_size * 1.08, max_size * 0.08), -0.04, 1.7, 0.60)
			_spawn_elemental_effect("projectile", center + Vector2(max_size * 0.46, max_size * 0.10), "ice", Vector2(base_size * 0.48, base_size * 0.22), duration * 0.62, intensity, 0.13, Vector2(-max_size * 0.52, -max_size * 0.04), PI - 0.10, 1.6, 0.42)
			_spawn_elemental_effect("cast", center + Vector2(0.0, max_size * 0.08), "ice", area_size * 0.34, duration * 0.92, intensity, 0.10, Vector2(0.0, max_size * 0.14), 0.0, 1.2, 0.52)
			_spawn_pack_layer("impact_02", center, "ice", area_size * 0.48, duration * 0.74, intensity, 0.10, 0.0, 2.1, 0.50)
			_spawn_pack_layer("hit_02", center + Vector2(-max_size * 0.10, -max_size * 0.10), "ice", area_size * 0.28, duration * 0.50, intensity, 0.20, 0.45, 2.5, 0.42)
		"earth":
			var ground_effect := _spawn_elemental_effect("area", center + Vector2(0.0, max_size * 0.16), "earth", area_size * 0.92, duration * 1.50, intensity, 0.0, Vector2.ZERO, 0.0, 0.28, 0.82)
			_stretch_effect(ground_effect, Vector3(1.55, 0.52, 1.0))
			for i in range(5 + mini(5, intensity)):
				var progress := float(i) / float(maxi(1, 4 + mini(5, intensity)))
				var offset := Vector2((progress - 0.5) * max_size * 1.8, max_size * (0.42 - progress * 0.32))
				var crack := _spawn_elemental_effect("area", center + offset, "earth", area_size * Vector2(0.20, 0.16), duration * 0.52, intensity, duration * (0.04 + progress * 0.18), Vector2.ZERO, sin(float(i)) * 0.42, 1.1, 0.54)
				_stretch_effect(crack, Vector3(1.80, 0.38, 1.0))
			_spawn_pack_layer("impact_01", center + Vector2(0.0, max_size * 0.10), "earth", area_size * 0.44, duration * 0.72, intensity, 0.16, 0.0, 2.0, 0.44)
		"heart":
			_spawn_elemental_effect("area", center, "heart", area_size * Vector2(0.78, 1.10), duration * 1.44, intensity, 0.0, Vector2(0.0, -max_size * 0.16), 0.0, 0.45, 0.76)
			for i in range(4 + mini(4, intensity)):
				var x := (float(i) - 1.5) * max_size * 0.18
				_spawn_elemental_effect("cast", center + Vector2(x, max_size * 0.28), "heart", area_size * 0.22, duration * 0.86, intensity, duration * (0.03 + float(i) * 0.035), Vector2(0.0, -max_size * (0.42 + float(i % 2) * 0.12)), 0.0, 1.5, 0.52)
			_spawn_pack_layer("hit_02", center + Vector2(0.0, -max_size * 0.06), "heart", area_size * 0.30, duration * 0.58, intensity, 0.18, 0.0, 2.3, 0.36)
		"armor":
			var shell := _spawn_elemental_effect("area", center, "armor", area_size * Vector2(1.06, 0.86), duration * 1.52, intensity, 0.0, Vector2.ZERO, 0.0, 0.55, 0.78)
			_stretch_effect(shell, Vector3(1.25, 0.74, 1.0))
			_spawn_elemental_effect("cast", center + Vector2(0.0, -max_size * 0.12), "armor", area_size * 0.38, duration * 0.82, intensity, 0.08, Vector2.ZERO, 0.0, 1.5, 0.54)
			_spawn_pack_layer("impact_02", center, "armor", area_size * 0.48, duration * 0.64, intensity, 0.10, 0.0, 2.1, 0.46)
		"gold":
			_spawn_elemental_effect("area", center, "gold", area_size * 0.92, duration * 1.24, intensity, 0.0, Vector2.ZERO, 0.0, 0.42, 0.78)
			for i in range(4 + mini(5, intensity)):
				var offset := Vector2(sin(float(i) * 1.7) * max_size * 0.44, -max_size * (0.28 + float(i % 3) * 0.14))
				_spawn_elemental_effect("cast", center + offset, "gold", area_size * 0.20, duration * 0.74, intensity, duration * (0.03 + float(i) * 0.035), Vector2(sin(float(i)) * max_size * 0.18, max_size * 0.30), 0.0, 1.6, 0.58)
			_spawn_coin_rain(center, max_size, duration, intensity, screen_wide)
			_spawn_pack_layer("hit_01", center, "gold", area_size * 0.34, duration * 0.50, intensity, 0.12, 0.22, 2.2, 0.48)
		_:
			_spawn_elemental_effect("area", center, kind, area_size, duration * 1.30, intensity, 0.0, Vector2.ZERO, 0.0, 0.45, 0.92)
	if screen_wide:
		_spawn_elemental_screen_wide(kind, center, duration, intensity)


func _spawn_elemental_cast_recipe(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color) -> void:
	var clean_kind := _clean_kind(kind)
	var spool_duration := maxf(0.48, spool_lifetime * 1.30)
	var travel_duration := maxf(0.38, travel_lifetime * 1.24)
	var launch_delay := maxf(0.34, spool_duration * 0.84)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var travel_size := Vector2(164 + intensity * 22, 92 + intensity * 10)
	_spawn_light(source, core, 2.0 + float(intensity) * 0.22, spool_size.x * 1.25, spool_duration * 1.05)
	match clean_kind:
		"fire":
			_spawn_elemental_effect("cast", source, "fire", spool_size * 1.10, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.94)
			_spawn_elemental_path_afterimage("fire", source, delta, launch_delay, travel_duration, intensity, angle)
			_spawn_elemental_effect("projectile", source, "fire", travel_size * Vector2(1.12, 0.95), travel_duration, intensity, launch_delay, delta, angle - PI, 1.5, 0.96)
			_spawn_pack_layer("hit_01", source + delta * 0.44, "fire", spool_size * 0.42, travel_duration * 0.48, intensity, launch_delay + travel_duration * 0.34, angle, 2.1, 0.42)
			_spawn_elemental_effect("area", target, "fire", spool_size * (1.22 + float(intensity) * 0.05), travel_duration * 1.42, intensity, launch_delay + travel_duration * 0.88, Vector2.ZERO, angle, 1.9, 0.98)
			_spawn_pack_layer("big_impact_01" if intensity >= 6 else "impact_01", target, "fire", spool_size * 0.56, travel_duration * 0.60, intensity, launch_delay + travel_duration * 0.92, angle, 2.4, 0.60)
		"ice":
			_spawn_elemental_effect("cast", source, "ice", spool_size * 0.86, spool_duration * 1.15, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.82)
			for lane_index in [-1, 1]:
				var lane := normal * float(lane_index) * (12.0 + float(intensity) * 1.8)
				_spawn_elemental_effect("projectile", source + lane, "ice", travel_size * Vector2(0.82, 0.58), travel_duration * 1.12, intensity, launch_delay + (0.05 if lane_index > 0 else 0.0), delta - lane * 0.35, angle - PI + float(lane_index) * 0.08, 1.5, 0.72)
			_spawn_elemental_path_afterimage("ice", source, delta, launch_delay, travel_duration * 1.10, intensity, angle)
			_spawn_elemental_effect("area", target, "ice", spool_size * (0.98 + float(intensity) * 0.04), travel_duration * 1.58, intensity, launch_delay + travel_duration * 0.88, Vector2.ZERO, angle, 1.9, 0.82)
			_spawn_pack_layer("impact_02", target, "ice", spool_size * 0.46, travel_duration * 0.72, intensity, launch_delay + travel_duration * 0.94, angle, 2.4, 0.48)
		"earth":
			var source_rumble := _spawn_elemental_effect("area", source + Vector2(0.0, 18.0), "earth", spool_size * Vector2(1.18, 0.70), spool_duration * 1.10, intensity, 0.0, Vector2.ZERO, angle, 0.4, 0.78)
			_stretch_effect(source_rumble, Vector3(1.45, 0.48, 1.0))
			_spawn_elemental_path_afterimage("earth", source, delta, launch_delay * 0.84, travel_duration * 1.24, intensity + 1, angle)
			var crawl := _spawn_elemental_effect("projectile", source, "earth", travel_size * Vector2(0.72, 0.52), travel_duration * 1.28, intensity, launch_delay, delta, angle - PI, 1.2, 0.46)
			_stretch_effect(crawl, Vector3(1.15, 0.58, 1.0))
			var impact := _spawn_elemental_effect("area", target + Vector2(0.0, 12.0), "earth", spool_size * (1.10 + float(intensity) * 0.05), travel_duration * 1.52, intensity, launch_delay + travel_duration * 0.94, Vector2.ZERO, angle, 1.9, 0.86)
			_stretch_effect(impact, Vector3(1.34, 0.56, 1.0))
			_spawn_pack_layer("impact_01", target, "earth", spool_size * 0.46, travel_duration * 0.62, intensity, launch_delay + travel_duration * 0.98, angle, 2.4, 0.44)
		"heart":
			_spawn_elemental_effect("cast", source, "heart", spool_size * 0.90, spool_duration * 1.04, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.74)
			for lane_index in [-1, 0, 1]:
				var lane := normal * float(lane_index) * (10.0 + float(intensity))
				_spawn_elemental_effect("projectile", source + lane, "heart", travel_size * Vector2(0.58, 0.70), travel_duration * 1.20, intensity, launch_delay + float(lane_index + 1) * 0.035, delta - lane * 0.30, angle - PI, 1.5, 0.58)
			_spawn_elemental_effect("area", target, "heart", spool_size * (0.92 + float(intensity) * 0.04), travel_duration * 1.64, intensity, launch_delay + travel_duration * 0.88, Vector2(0.0, -18.0), angle, 1.9, 0.76)
		"armor":
			_spawn_elemental_effect("cast", source, "armor", spool_size * 0.92, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.76)
			_spawn_elemental_effect("projectile", source, "armor", travel_size * Vector2(0.74, 0.78), travel_duration * 1.10, intensity, launch_delay, delta, angle - PI, 1.5, 0.62)
			var shell := _spawn_elemental_effect("area", target, "armor", spool_size * (1.04 + float(intensity) * 0.04), travel_duration * 1.68, intensity, launch_delay + travel_duration * 0.88, Vector2.ZERO, angle, 1.9, 0.78)
			_stretch_effect(shell, Vector3(1.22, 0.78, 1.0))
			_spawn_pack_layer("impact_02", target, "armor", spool_size * 0.44, travel_duration * 0.58, intensity, launch_delay + travel_duration * 0.92, angle, 2.4, 0.46)
		"gold":
			_spawn_elemental_effect("cast", source, "gold", spool_size * 0.90, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.78)
			_spawn_elemental_effect("projectile", source, "gold", travel_size * Vector2(0.68, 0.62), travel_duration * 1.04, intensity, launch_delay, delta, angle - PI, 1.5, 0.62)
			_spawn_elemental_effect("area", target, "gold", spool_size * (0.94 + float(intensity) * 0.04), travel_duration * 1.28, intensity, launch_delay + travel_duration * 0.86, Vector2.ZERO, angle, 1.9, 0.74)
			_spawn_coin_rain(target, spool_size.x, travel_duration * 1.4, intensity, false)
			_spawn_pack_layer("hit_01", target, "gold", spool_size * 0.42, travel_duration * 0.50, intensity, launch_delay + travel_duration * 0.92, angle, 2.4, 0.48)
		_:
			_spawn_elemental_effect("cast", source, kind, spool_size * 1.04, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.92)
			_spawn_elemental_effect("projectile", source, kind, travel_size, travel_duration, intensity, launch_delay, delta, angle - PI, 1.4, 0.94)
			_spawn_elemental_effect("area", target, kind, spool_size * (1.16 + float(intensity) * 0.05), travel_duration * 1.42, intensity, launch_delay + travel_duration * 0.88, Vector2.ZERO, angle, 1.9, 0.96)
	_spawn_camera_kick(delta.normalized() * (5.0 + float(intensity) * 1.2), launch_delay + travel_duration * 0.90)


func _spawn_elemental_beam_recipe(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	var clean_kind := _clean_kind(kind)
	match clean_kind:
		"ice":
			var normal := Vector2(-delta.y, delta.x).normalized()
			_spawn_elemental_effect("projectile", source + normal * 9.0, "ice", Vector2(142 + intensity * 10, 56 + intensity * 5), lifetime * 1.22, intensity, 0.0, delta - normal * 6.0, angle - PI + 0.06, 1.4, 0.62)
			_spawn_elemental_effect("projectile", source - normal * 9.0, "ice", Vector2(112 + intensity * 8, 46 + intensity * 4), lifetime * 1.14, intensity, 0.05, delta + normal * 6.0, angle - PI - 0.06, 1.3, 0.44)
		"earth":
			_spawn_elemental_path_afterimage("earth", source, delta, 0.0, lifetime * 1.22, intensity, angle)
			var crawl := _spawn_elemental_effect("projectile", source, "earth", Vector2(118 + intensity * 10, 48 + intensity * 4), lifetime * 1.24, intensity, 0.0, delta, angle - PI, 1.2, 0.48)
			_stretch_effect(crawl, Vector3(1.20, 0.52, 1.0))
		"heart":
			_spawn_elemental_effect("projectile", source, "heart", Vector2(112 + intensity * 8, 70 + intensity * 5), lifetime * 1.20, intensity, 0.0, delta, angle - PI, 1.4, 0.54)
		"armor":
			_spawn_elemental_effect("projectile", source, "armor", Vector2(118 + intensity * 8, 76 + intensity * 6), lifetime * 1.18, intensity, 0.0, delta, angle - PI, 1.4, 0.58)
		"gold":
			_spawn_elemental_effect("projectile", source, "gold", Vector2(118 + intensity * 8, 64 + intensity * 5), lifetime * 1.10, intensity, 0.0, delta, angle - PI, 1.4, 0.58)
		_:
			_spawn_elemental_effect("projectile", source, kind, Vector2(156 + intensity * 14, 84 + intensity * 7), lifetime * 1.18, intensity, 0.0, delta, angle - PI, 1.4, 0.82)


func _elemental_magic_available() -> bool:
	return _elemental_scene("cast") != null and _elemental_scene("projectile") != null and _elemental_scene("area") != null


func _elemental_scene(key: String) -> PackedScene:
	if _elemental_scene_cache.has(key):
		return _elemental_scene_cache[key]
	var path := String(ELEMENTAL_MAGIC_SCENE_PATHS.get(key, ""))
	if path == "":
		return null
	var scene := load(path) as PackedScene
	if scene != null:
		_elemental_scene_cache[key] = scene
	return scene


func _spawn_elemental_effect(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, rotation: float = 0.0, z: float = 0.0, alpha: float = 1.0) -> Node3D:
	if not _ensure_overlay():
		return null
	var scene := _elemental_scene(scene_key)
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "ElementalVfx_%s_%s" % [kind, scene_key]
	effect.position = _screen_to_world_position(center_local, z)
	effect.rotation = Vector3(0.0, 0.0, _screen_to_world_rotation(rotation))
	effect.scale = Vector3.ONE * _elemental_scale_from_size(draw_size, scene_key, intensity)
	effect.visible = delay <= 0.0
	_configure_elemental_effect(effect, scene_key, kind, intensity, alpha, lifetime)
	_root_3d.add_child(effect)
	if effect.has_signal("finished"):
		effect.finished.connect(func() -> void:
			if is_instance_valid(effect):
				effect.queue_free()
		, CONNECT_ONE_SHOT)
	else:
		_queue_free_after(effect, delay + maxf(0.35, lifetime) + 0.55)
	if scene_key != "cast":
		_schedule_elemental_stop(effect, delay + maxf(0.18, lifetime * 0.78))
	_schedule_elemental_play(effect, scene_key, delay)
	if move_offset != Vector2.ZERO and _timer_owner != null and is_instance_valid(_timer_owner) and _timer_owner.get_tree() != null:
		var tween := _timer_owner.create_tween()
		tween.tween_property(effect, "position", effect.position + _screen_to_world_offset(move_offset), maxf(0.10, lifetime)).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	return effect


func _configure_elemental_effect(effect: Node3D, scene_key: String, kind: String, intensity: int, alpha: float, lifetime: float) -> void:
	var colors := _elemental_kind_colors(kind)
	var primary_base: Color = colors.get("primary", Color.WHITE)
	var secondary_base: Color = colors.get("secondary", Color.WHITE)
	var tertiary_base: Color = colors.get("tertiary", secondary_base)
	var primary := Color(primary_base.r, primary_base.g, primary_base.b, alpha)
	var secondary := Color(secondary_base.r, secondary_base.g, secondary_base.b, alpha)
	var tertiary := Color(tertiary_base.r, tertiary_base.g, tertiary_base.b, alpha)
	_set_node_property_if_present(effect, "one_shot", true)
	_set_node_property_if_present(effect, "autoplay", false)
	_set_node_property_if_present(effect, "audio_autoplay", false)
	_set_node_property_if_present(effect, "audio_playing", false)
	_set_node_property_if_present(effect, "volume_db", -80.0)
	_set_node_property_if_present(effect, "speed_scale", 0.68 + float(intensity) * 0.018)
	_set_node_property_if_present(effect, "primary_color", primary)
	_set_node_property_if_present(effect, "secondary_color", secondary)
	_set_node_property_if_present(effect, "tertiary_color", tertiary)
	_set_node_property_if_present(effect, "light_color", primary)
	_set_node_property_if_present(effect, "emission", 2.6 + float(intensity) * 0.34)
	_set_node_property_if_present(effect, "light_energy", 3.2 + float(intensity) * 0.42)
	_set_node_property_if_present(effect, "light_indirect_energy", 0.42)
	_set_node_property_if_present(effect, "light_volumetric_fog_energy", 0.16)
	_set_node_property_if_present(effect, "particles_amount", mini(144, 48 + intensity * 11))
	_set_node_property_if_present(effect, "lifetime", maxf(0.22, lifetime * 0.55))
	if scene_key == "area":
		_set_node_property_if_present(effect, "area_radius", 1.34 + float(intensity) * 0.10)
		_set_node_property_if_present(effect, "explosiveness", 0.18 + float(intensity) * 0.035)
	elif scene_key == "projectile":
		_set_node_property_if_present(effect, "tail_length", 0.74 + float(intensity) * 0.018)
		_set_node_property_if_present(effect, "spiral_amount", 0.32 + float(intensity) * 0.025)
		_set_node_property_if_present(effect, "spiral_count", 5 + mini(intensity, 6))
		_set_node_property_if_present(effect, "wave_speed", 0.72 + float(intensity) * 0.06)
	if scene_key != "cast":
		_set_node_property_if_present(effect, "emitting", false)


func _schedule_elemental_play(effect: Node3D, scene_key: String, delay: float) -> void:
	if effect == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		_play_elemental_effect(effect, scene_key)
		return
	if delay <= 0.0:
		_play_elemental_effect(effect, scene_key)
		return
	var tween := _timer_owner.create_tween()
	tween.tween_interval(delay)
	tween.tween_callback(func() -> void:
		_play_elemental_effect(effect, scene_key)
	)


func _play_elemental_effect(effect: Node3D, scene_key: String) -> void:
	if not is_instance_valid(effect):
		return
	effect.visible = true
	if scene_key == "cast" and effect.has_method("play"):
		effect.call("play")
		return
	_set_node_property_if_present(effect, "emitting", true)
	if effect.has_method("open"):
		effect.call("open")


func _schedule_elemental_stop(effect: Node3D, delay: float) -> void:
	if effect == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		return
	var tween := _timer_owner.create_tween()
	tween.tween_interval(maxf(0.05, delay))
	tween.tween_callback(func() -> void:
		if is_instance_valid(effect):
			_set_node_property_if_present(effect, "emitting", false)
	)


func _elemental_scale_from_size(draw_size: Vector2, scene_key: String, intensity: int) -> float:
	var longest := maxf(draw_size.x, draw_size.y)
	var divisor := 6.4
	match scene_key:
		"projectile":
			divisor = 5.2
		"area":
			divisor = 5.0
		"cast":
			divisor = 7.0
	return maxf(8.0, longest / divisor) * (1.0 + float(intensity) * 0.030)


func _spawn_elemental_path_afterimage(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	var count := 3 + mini(5, int(floor(float(intensity) * 0.65)))
	for i in range(count):
		var progress := (float(i) + 0.35) / float(count + 1)
		var lane := Vector2(-delta.y, delta.x).normalized() * sin(float(i) * 1.7) * (8.0 + float(intensity) * 1.8)
		var point := source + delta * progress + lane
		var delay := launch_delay + travel_duration * progress * 0.68
		var size := Vector2(58 + intensity * 8, 58 + intensity * 6)
		var alpha := 0.34
		if kind == "earth":
			size *= Vector2(1.28, 0.72)
			alpha = 0.48
		elif kind == "ice":
			size *= Vector2(0.90, 1.08)
			alpha = 0.38
		_spawn_elemental_effect("area", point, kind, size, travel_duration * 0.44, intensity, delay, Vector2.ZERO, angle, 0.2, alpha)


func _spawn_elemental_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0:
		return
	var offensive := _clean_kind(kind) in ["fire", "ice", "earth", "damage"]
	var focus_y := clampf(center.y, layer_size.y * (0.08 if offensive else 0.36), layer_size.y * (0.42 if offensive else 0.86))
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var size := Vector2(layer_size.x * 0.92, layer_size.y * (0.34 if offensive else 0.42))
	_spawn_elemental_effect("area", focus, kind, size, lifetime * 1.36, intensity, 0.0, Vector2.ZERO, 0.0, -0.8, 0.64)
	var bursts := 3 + mini(4, int(floor(float(intensity) * 0.45)))
	for i in range(bursts):
		var x := layer_size.x * (0.18 + float(i) / float(maxi(1, bursts - 1)) * 0.64)
		var y := focus_y + sin(float(i) * 1.9) * layer_size.y * 0.055
		var delay := lifetime * (0.06 + float(i % 4) * 0.045)
		_spawn_elemental_effect("cast", Vector2(x, y), kind, size * 0.22, lifetime * 0.74, intensity, delay, Vector2.ZERO, sin(float(i)) * 0.28, 1.4, 0.42)


func _pack_vfx_available() -> bool:
	return _pack_scene("hit_01") != null and _pack_scene("impact_01") != null and _pack_scene("big_impact_01") != null


func _pack_scene(key: String) -> PackedScene:
	if _pack_scene_cache.has(key):
		return _pack_scene_cache[key]
	var path := String(PACK_VFX_SCENE_PATHS.get(key, ""))
	if path == "":
		return null
	var scene := load(path) as PackedScene
	if scene != null:
		_pack_scene_cache[key] = scene
	return scene


func _spawn_pack_effect(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, rotation: float = 0.0, z: float = 0.0, alpha: float = 1.0) -> Node3D:
	if not _ensure_overlay():
		return null
	var scene := _pack_scene(scene_key)
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "PackVfx_%s_%s" % [kind, scene_key]
	effect.position = _screen_to_world_position(center_local, z)
	effect.rotation = Vector3(0.0, 0.0, _screen_to_world_rotation(rotation))
	effect.scale = Vector3.ONE * _pack_scale_from_size(draw_size, intensity)
	effect.visible = delay <= 0.0
	_configure_pack_effect(effect, kind, intensity, alpha)
	_root_3d.add_child(effect)
	if effect.has_signal("finished"):
		effect.finished.connect(func() -> void:
			if is_instance_valid(effect):
				effect.queue_free()
		, CONNECT_ONE_SHOT)
	else:
		_queue_free_after(effect, delay + maxf(0.35, lifetime) + 0.40)
	_schedule_pack_play(effect, delay)
	if move_offset != Vector2.ZERO and _timer_owner != null and is_instance_valid(_timer_owner) and _timer_owner.get_tree() != null:
		var tween := _timer_owner.create_tween()
		tween.tween_property(effect, "position", effect.position + _screen_to_world_offset(move_offset), maxf(0.10, lifetime)).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	return effect


func _spawn_pack_layer(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> Node3D:
	if not _pack_vfx_available():
		return null
	return _spawn_pack_effect(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, Vector2.ZERO, rotation, z, alpha)


func _stretch_effect(effect: Node3D, stretch: Vector3) -> void:
	if is_instance_valid(effect):
		effect.scale = Vector3(effect.scale.x * stretch.x, effect.scale.y * stretch.y, effect.scale.z * stretch.z)


func _schedule_pack_play(effect: Node3D, delay: float) -> void:
	if effect == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		_play_pack_effect(effect)
		return
	if delay <= 0.0:
		_play_pack_effect(effect)
		return
	var tween := _timer_owner.create_tween()
	tween.tween_interval(delay)
	tween.tween_callback(func() -> void:
		_play_pack_effect(effect)
	)


func _play_pack_effect(effect: Node3D) -> void:
	if not is_instance_valid(effect):
		return
	effect.visible = true
	if effect.has_method("play"):
		effect.call("play")


func _configure_pack_effect(effect: Node3D, kind: String, intensity: int, alpha: float) -> void:
	var colors := _kind_colors(kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", Color.WHITE)
	var primary := Color(core.r, core.g, core.b, alpha)
	var secondary := Color(accent.r, accent.g, accent.b, alpha)
	_set_node_property_if_present(effect, "one_shot", true)
	_set_node_property_if_present(effect, "autoplay", false)
	_set_node_property_if_present(effect, "speed_scale", 0.86 + float(intensity) * 0.025)
	_set_node_property_if_present(effect, "primary_color", primary)
	_set_node_property_if_present(effect, "secondary_color", secondary)
	_set_node_property_if_present(effect, "light_color", primary)
	_set_node_property_if_present(effect, "emission", 2.5 + float(intensity) * 0.25)
	_set_node_property_if_present(effect, "light_energy", 3.0 + float(intensity) * 0.34)
	_set_node_property_if_present(effect, "light_indirect_energy", 0.3)
	_set_node_property_if_present(effect, "light_volumetric_fog_energy", 0.15)
	_set_node_property_if_present(effect, "volume_db", -80.0)


func _set_node_property_if_present(node: Object, property_name: String, value: Variant) -> void:
	if node == null:
		return
	for property in node.get_property_list():
		if String(property.get("name", "")) == property_name:
			node.set(property_name, value)
			return


func _pack_scale_from_size(draw_size: Vector2, intensity: int) -> float:
	var longest := maxf(draw_size.x, draw_size.y)
	return maxf(12.0, longest / 6.0) * (1.0 + float(intensity) * 0.025)


func _pack_impact_scene_key(kind: String, intensity: int, screen_wide: bool) -> String:
	if screen_wide or intensity >= 6:
		return "big_impact_02" if _clean_kind(kind) in ["ice", "armor", "heart"] else "big_impact_01"
	match _clean_kind(kind):
		"ice", "armor", "heart":
			return "impact_02"
		"earth", "gold":
			return "impact_01"
	return "impact_01"


func _pack_hit_scene_key(kind: String) -> String:
	return "hit_02" if _clean_kind(kind) in ["ice", "armor", "heart"] else "hit_01"


func _spawn_pack_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0:
		return
	var offensive := _clean_kind(kind) in ["fire", "ice", "earth", "damage"]
	var focus_y := clampf(center.y, layer_size.y * (0.08 if offensive else 0.36), layer_size.y * (0.44 if offensive else 0.86))
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var size := Vector2(layer_size.x * 0.92, layer_size.y * (0.34 if offensive else 0.44))
	_spawn_pack_effect(_pack_impact_scene_key(kind, intensity, true), focus, kind, size, lifetime * 1.05, intensity, 0.0, Vector2.ZERO, 0.0, -1.4, 0.62)
	_spawn_pack_effect("hit_01", focus + Vector2(layer_size.x * 0.18, -layer_size.y * 0.03), kind, size * 0.46, lifetime * 0.66, intensity, lifetime * 0.10, Vector2.ZERO, 0.22, 1.6, 0.54)
	_spawn_pack_effect("hit_02", focus - Vector2(layer_size.x * 0.20, -layer_size.y * 0.02), kind, size * 0.40, lifetime * 0.62, intensity, lifetime * 0.16, Vector2.ZERO, -0.20, 1.7, 0.50)


func _spawn_flipbook(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, target_scale: float = 1.0, z: float = 0.0, rotation: float = 0.0, spin: float = 0.0) -> Sprite3D:
	if not _ensure_overlay():
		return null
	var texture := _max_texture(key)
	if texture == null:
		return null
	var sprite := Sprite3D.new()
	sprite.name = "MaxVfx_%s" % key
	sprite.texture = texture
	sprite.hframes = GRID_COLUMNS
	sprite.vframes = GRID_ROWS
	sprite.frame = 0
	sprite.centered = true
	sprite.pixel_size = 1.0
	sprite.modulate = Color(color.r, color.g, color.b, 0.0 if delay > 0.0 else color.a)
	var cell_size := Vector2(float(texture.get_width()) / float(GRID_COLUMNS), float(texture.get_height()) / float(GRID_ROWS))
	sprite.scale = Vector3(draw_size.x / cell_size.x, draw_size.y / cell_size.y, 1.0)
	sprite.position = _screen_to_world_position(center_local, z)
	sprite.rotation = Vector3(0.0, 0.0, _screen_to_world_rotation(rotation))
	_root_3d.add_child(sprite)
	_tween_sprite3d(sprite, lifetime, target_scale, delay, move_offset, spin, color.a)
	return sprite


func _tween_sprite3d(sprite: Sprite3D, lifetime: float, target_scale: float, delay: float, move_offset: Vector2, spin: float, target_alpha: float) -> void:
	if sprite == null:
		return
	var duration := maxf(0.12, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		sprite.queue_free()
		return
	var start_scale := sprite.scale
	var start_position := sprite.position
	var start_rotation := sprite.rotation.z
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_property(sprite, "modulate:a", target_alpha, 0.04).set_delay(delay)
	tween.tween_method(func(value: float) -> void:
		if is_instance_valid(sprite):
			sprite.frame = clampi(int(round(value)), 0, PRIMARY_FRAMES - 1)
	, 0.0, float(PRIMARY_FRAMES - 1), duration).set_delay(delay)
	tween.tween_property(sprite, "scale", start_scale * target_scale, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if move_offset != Vector2.ZERO:
		tween.tween_property(sprite, "position", start_position + _screen_to_world_offset(move_offset), duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if not is_zero_approx(spin):
		tween.tween_property(sprite, "rotation:z", start_rotation - spin, duration).set_delay(delay)
	tween.tween_property(sprite, "modulate:a", 0.0, duration * 0.45).set_delay(delay + duration * 0.55)
	tween.finished.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.queue_free()
	)


func _spawn_burst_particles(kind: String, center: Vector2, base_size: float, lifetime: float, intensity: int) -> void:
	var colors := _kind_colors(kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", Color.WHITE)
	var particle_key := _particle_key(kind)
	var count := 18 + intensity * 7
	for i in range(count):
		var angle := TAU * float(i) / float(count) + sin(float(i) * 1.37) * 0.32
		var dist := base_size * (0.34 + float(i % 5) * 0.045 + float(intensity) * 0.025)
		var start := center + Vector2(cos(angle), sin(angle)) * base_size * 0.10
		var travel := Vector2(cos(angle), sin(angle) - (0.20 if kind in ["fire", "heal", "gold"] else 0.0)) * dist
		var color := core if i % 3 == 0 else accent
		var size := Vector2(34 + intensity * 3, 34 + intensity * 3)
		if particle_key in ["ice_shards", "stone_chunks", "light_rays"]:
			size = Vector2(42 + intensity * 5, 76 + intensity * 6)
		_spawn_flipbook(particle_key, start, size, lifetime * (0.54 + float(i % 4) * 0.035), Color(color.r, color.g, color.b, 0.78), float(i % 6) * lifetime * 0.014, travel, 0.42, 1.8, angle + PI * 0.5, 0.55)
	_spawn_gpu_particles(particle_key, center, mini(96, 28 + intensity * 8), accent, base_size * 0.28, lifetime * 0.66, kind)


func _spawn_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0:
		return
	var colors := _kind_colors(kind)
	var core: Color = colors.get("core", Color.WHITE)
	var offensive := kind in ["fire", "ice", "earth", "damage"]
	var focus_y := clampf(center.y, layer_size.y * (0.08 if offensive else 0.36), layer_size.y * (0.46 if offensive else 0.86))
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var size := Vector2(layer_size.x * 1.15, layer_size.y * (0.46 if offensive else 0.62))
	_spawn_light(focus, core, 3.0 + float(intensity) * 0.28, layer_size.x * 0.72, lifetime * 0.72)
	_spawn_flipbook(_impact_key(kind), focus, size, lifetime * 0.86, Color(1, 1, 1, 0.40), 0.0, Vector2.ZERO, 1.06, -2.0, 0.0)
	for i in range(7 + mini(intensity, 8)):
		var y := focus_y + (float(i) - 3.0) * layer_size.y * 0.045
		_spawn_flipbook("light_rays", Vector2(layer_size.x * 0.5, y), Vector2(layer_size.x * (0.72 + float(i % 3) * 0.10), 48 + intensity * 4), lifetime * 0.50, Color(core.r, core.g, core.b, 0.48), lifetime * (0.04 + float(i % 5) * 0.025), Vector2(sin(float(i)) * 34.0, -12.0), 0.48, -1.0, -0.22 + sin(float(i)) * 0.20)
	if kind == "gold":
		_spawn_coin_rain(focus, layer_size.x * 0.34, lifetime * 1.2, intensity, true)


func _spawn_coin_rain(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	var layer_size := _vfx_layer_size()
	var count := 24 + intensity * (8 if screen_wide else 5)
	for i in range(count):
		var spread := layer_size.x * 0.88 if screen_wide else base_size * 2.1
		var x := center.x + (float(i % 13) / 12.0 - 0.5) * spread + sin(float(i) * 1.9) * 22.0
		var y := -40.0 - float(i % 5) * 28.0 if screen_wide else center.y - base_size * (0.74 + float(i % 4) * 0.12)
		var travel_y := layer_size.y * (0.75 + float(i % 4) * 0.06) if screen_wide else base_size * (1.25 + float(i % 4) * 0.08)
		_spawn_flipbook("coin_spin", Vector2(x, y), Vector2(50 + intensity * 4, 50 + intensity * 4), lifetime * 1.05, Color(1.0, 0.86, 0.24, 0.96), float(i % 9) * lifetime * 0.020, Vector2(sin(float(i) * 2.4) * 36.0, travel_y), 0.76, 2.0, sin(float(i)) * 0.4, 1.4)


func _spawn_gpu_particles(texture_key: String, center: Vector2, amount: int, color: Color, radius: float, lifetime: float, kind: String) -> void:
	if _root_3d == null or not is_instance_valid(_root_3d):
		return
	var texture := _max_texture(texture_key)
	if texture == null:
		return
	var particles := GPUParticles3D.new()
	particles.name = "MaxVfxParticles_%s" % texture_key
	particles.position = _screen_to_world_position(center, 2.4)
	particles.amount = amount
	particles.lifetime = maxf(0.12, lifetime)
	particles.one_shot = true
	particles.explosiveness = 0.92
	particles.randomness = 0.62
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = maxf(8.0, radius)
	process.direction = Vector3(0.0, 1.0 if kind in ["fire", "heal", "gold"] else 0.0, 0.0)
	process.spread = 180.0
	process.initial_velocity_min = radius * 0.32
	process.initial_velocity_max = radius * 0.92
	process.gravity = Vector3(0.0, -58.0 if kind == "gold" else 18.0, 0.0)
	process.scale_min = 0.18
	process.scale_max = 0.62
	particles.process_material = process
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = texture
	material.albedo_color = Color(color.r, color.g, color.b, 0.70)
	var mesh := QuadMesh.new()
	mesh.size = Vector2(34, 34)
	mesh.material = material
	particles.draw_pass_1 = mesh
	_root_3d.add_child(particles)
	particles.emitting = true
	_queue_free_after(particles, lifetime + 0.24)


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float, delay: float = 0.0) -> void:
	if _root_3d == null or not is_instance_valid(_root_3d):
		return
	if delay > 0.0:
		if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
			return
		var delayed_tween := _timer_owner.create_tween()
		delayed_tween.tween_interval(delay)
		delayed_tween.finished.connect(func() -> void:
			_spawn_light(center, color, energy, radius, lifetime)
		)
		return
	var light := OmniLight3D.new()
	light.name = "MaxVfxLight"
	light.position = _screen_to_world_position(center, 90.0)
	light.light_color = color
	light.light_energy = energy
	light.omni_range = maxf(64.0, radius)
	_root_3d.add_child(light)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		light.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.tween_property(light, "light_energy", 0.0, maxf(0.08, lifetime)).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.finished.connect(func() -> void:
		if is_instance_valid(light):
			light.queue_free()
	)


func _spawn_camera_kick(direction: Vector2, delay: float) -> void:
	if _camera == null or not is_instance_valid(_camera):
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		return
	var layer_size := _vfx_layer_size()
	var base_position := Vector3(layer_size.x * 0.5, layer_size.y * 0.5, 1000.0)
	var kick := _screen_to_world_offset(Vector2(clampf(direction.x, -10.0, 10.0), clampf(direction.y, -10.0, 10.0)))
	var tween := _timer_owner.create_tween()
	tween.tween_property(_camera, "position", base_position + kick, 0.045).set_delay(delay)
	tween.tween_property(_camera, "position", base_position, 0.18).set_trans(Tween.TRANS_ELASTIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)


func _queue_free_after(node: Node, delay: float) -> void:
	if node == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		node.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.tween_interval(maxf(0.05, delay))
	tween.finished.connect(func() -> void:
		if is_instance_valid(node):
			node.queue_free()
	)


func _screen_to_world_position(screen_position: Vector2, z: float) -> Vector3:
	var layer_size := _vfx_layer_size()
	return Vector3(screen_position.x, layer_size.y - screen_position.y, z)


func _screen_to_world_offset(screen_offset: Vector2) -> Vector3:
	return Vector3(screen_offset.x, -screen_offset.y, 0.0)


func _screen_to_world_rotation(screen_rotation: float) -> float:
	return -screen_rotation


func _max_texture(key: String) -> Texture2D:
	if _texture_cache.has(key):
		return _texture_cache[key]
	if _visual_registry == null or not _visual_registry.has_method("max_combat_vfx_texture"):
		return null
	var texture: Texture2D = _visual_registry.max_combat_vfx_texture(key)
	if texture != null:
		_texture_cache[key] = texture
	return texture


func _impact_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "fire_impact"
		"ice":
			return "ice_impact"
		"earth":
			return "stone_chunks"
		"heart":
			return "heal_impact"
		"armor":
			return "armor_impact"
		"gold":
			return "gold_reward"
		"damage":
			return "damage_impact"
	return "orb_clear"


func _projectile_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "fire_projectile"
		"ice":
			return "ice_projectile"
		"earth":
			return "dust_puff"
		"heart":
			return "heal_impact"
		"armor":
			return "armor_impact"
		"gold":
			return "gold_reward"
	return "orb_clear"


func _trail_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "flame_trail"
		"ice":
			return "frost_mist"
		"earth":
			return "dust_puff"
		"heart":
			return "heal_motes"
		"armor":
			return "armor_shell"
		"gold":
			return "spark_particles"
	return "smoke_puff"


func _mist_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "flame_trail"
		"ice":
			return "frost_mist"
		"earth":
			return "dust_puff"
		"heart":
			return "heal_motes"
		"armor":
			return "armor_shell"
	return "smoke_puff"


func _particle_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "spark_particles"
		"ice":
			return "ice_shards"
		"earth":
			return "stone_chunks"
		"heart":
			return "heal_motes"
		"armor":
			return "armor_shell"
		"gold":
			return "coin_spin"
		"damage":
			return "spark_particles"
	return "spark_particles"


func _clean_kind(kind: String) -> String:
	var clean := kind.strip_edges().to_lower()
	if clean == "heal" or clean == "healing":
		return "heart"
	if clean == "block" or clean == "shield":
		return "armor"
	return clean


func _should_use_elemental_magic(kind: String) -> bool:
	return _clean_kind(kind) in ["fire", "ice", "earth", "heart", "armor", "gold"]


func _kind_for_orb(orb_id: int) -> String:
	match orb_id:
		OrbType.Id.FIRE:
			return "fire"
		OrbType.Id.ICE:
			return "ice"
		OrbType.Id.EARTH:
			return "earth"
		OrbType.Id.HEART:
			return "heart"
		OrbType.Id.ARMOR:
			return "armor"
		OrbType.Id.GOLD:
			return "gold"
	return "damage"


func _elemental_kind_colors(kind: String) -> Dictionary:
	match _clean_kind(kind):
		"fire":
			return {"primary": Color(1.0, 0.76, 0.20, 1.0), "secondary": Color(1.0, 0.22, 0.03, 1.0), "tertiary": Color(0.34, 0.02, 0.00, 1.0)}
		"ice":
			return {"primary": Color(0.90, 1.0, 1.0, 1.0), "secondary": Color(0.28, 0.84, 1.0, 1.0), "tertiary": Color(0.04, 0.18, 0.68, 1.0)}
		"earth":
			return {"primary": Color(0.66, 1.0, 0.26, 1.0), "secondary": Color(0.28, 0.58, 0.14, 1.0), "tertiary": Color(0.12, 0.16, 0.06, 1.0)}
		"heart":
			return {"primary": Color(0.86, 1.0, 0.78, 1.0), "secondary": Color(0.30, 1.0, 0.58, 1.0), "tertiary": Color(0.06, 0.35, 0.18, 1.0)}
		"armor":
			return {"primary": Color(0.94, 0.99, 1.0, 1.0), "secondary": Color(0.46, 0.78, 1.0, 1.0), "tertiary": Color(0.06, 0.16, 0.46, 1.0)}
		"gold":
			return {"primary": Color(1.0, 0.96, 0.44, 1.0), "secondary": Color(1.0, 0.58, 0.10, 1.0), "tertiary": Color(0.48, 0.18, 0.02, 1.0)}
	return {"primary": Color(1.0, 1.0, 1.0, 1.0), "secondary": Color(0.78, 0.86, 1.0, 1.0), "tertiary": Color(0.18, 0.24, 0.38, 1.0)}


func _kind_colors(kind: String) -> Dictionary:
	match _clean_kind(kind):
		"fire":
			return {"accent": Color(1.0, 0.25, 0.04, 1.0), "core": Color(1.0, 0.88, 0.35, 1.0)}
		"ice":
			return {"accent": Color(0.35, 0.86, 1.0, 1.0), "core": Color(0.88, 1.0, 1.0, 1.0)}
		"earth":
			return {"accent": Color(0.36, 0.62, 0.18, 1.0), "core": Color(0.78, 1.0, 0.34, 1.0)}
		"heart":
			return {"accent": Color(0.32, 1.0, 0.50, 1.0), "core": Color(0.84, 1.0, 0.76, 1.0)}
		"armor":
			return {"accent": Color(0.54, 0.80, 1.0, 1.0), "core": Color(0.92, 0.98, 1.0, 1.0)}
		"gold":
			return {"accent": Color(1.0, 0.68, 0.12, 1.0), "core": Color(1.0, 0.96, 0.42, 1.0)}
		"damage":
			return {"accent": Color(1.0, 0.18, 0.12, 1.0), "core": Color(1.0, 0.58, 0.44, 1.0)}
	return {"accent": Color(0.86, 0.90, 1.0, 1.0), "core": Color(1.0, 1.0, 1.0, 1.0)}


func _vfx_layer_size() -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return Vector2.ZERO
	var layer_size := _vfx_layer.size
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		var viewport := _vfx_layer.get_viewport()
		if viewport != null:
			layer_size = viewport.get_visible_rect().size
	return layer_size


func _global_to_overlay_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position
