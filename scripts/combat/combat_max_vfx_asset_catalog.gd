extends RefCounted
class_name CombatMaxVfxAssetCatalog

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
const EXTERNAL_SCENE_PATHS := {
	"flame": "res://assets/BinbunVFX_Vol2/FlameFX/effects/fire/vfx_basic_fire_01.tscn",
	"beam": "res://assets/BinbunVFX/beam_vfx/effects/base/base_beam_vfx.tscn",
	"shield": "res://assets/UserVFX/shield_vfx/main.tscn",
	"tornado": "res://assets/UserVFX/tornado_vfx/node_3d.tscn",
}


func required_texture_keys() -> Array[String]:
	return REQUIRED_TEXTURE_KEYS.duplicate()


func pack_scene_paths() -> Dictionary:
	return PACK_VFX_SCENE_PATHS.duplicate()


func elemental_magic_scene_paths() -> Dictionary:
	return ELEMENTAL_MAGIC_SCENE_PATHS.duplicate()


func status_sheet_paths() -> Dictionary:
	return STATUS_VFX_SHEET_PATHS.duplicate()


func atmospheric_sheet_paths() -> Dictionary:
	return ATMOSPHERIC_VFX_SHEET_PATHS.duplicate()


func external_scene_paths() -> Dictionary:
	return EXTERNAL_SCENE_PATHS.duplicate()


func pack_scene_path(key: String) -> String:
	return String(PACK_VFX_SCENE_PATHS.get(key, ""))


func elemental_magic_scene_path(key: String) -> String:
	return String(ELEMENTAL_MAGIC_SCENE_PATHS.get(key, ""))


func status_sheet_path(key: String) -> String:
	return String(STATUS_VFX_SHEET_PATHS.get(key, ""))


func atmospheric_sheet_path(key: String) -> String:
	return String(ATMOSPHERIC_VFX_SHEET_PATHS.get(key, ""))


func external_scene_path(key: String) -> String:
	return String(EXTERNAL_SCENE_PATHS.get(key, ""))
