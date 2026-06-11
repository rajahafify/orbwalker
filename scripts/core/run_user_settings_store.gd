extends RefCounted
class_name RunUserSettingsStore

const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

const SETTINGS_PATH := "user://matchatro_settings.cfg"
const RUN_LOG_SECTION := "run_log"
const GENERATE_LOG_KEY := "generate_log"
const GAMEPLAY_SECTION := "gameplay"
const VFX_SPEED_KEY := "vfx_speed"
const COMBAT_VFX_QUALITY_KEY := "combat_vfx_quality"
const REDUCED_MOTION_KEY := "reduced_motion"
const GAME_JUICE_KEY := "game_juice"
const VFX_SPEED_SLOW := "slow"
const VFX_SPEED_NORMAL := "normal"
const VFX_SPEED_FAST := "fast"
const VFX_SPEED_INSTANT := "instant"
const COMBAT_VFX_QUALITY_LOW := "low"
const COMBAT_VFX_QUALITY_HIGH := "high"

var generate_run_log_files := false
var vfx_speed := VFX_SPEED_NORMAL
var combat_vfx_quality := COMBAT_VFX_QUALITY_LOW
var reduced_motion := false
var game_juice_enabled := true
var game_juice_flags: Dictionary = GAME_JUICE_FLAGS_SCRIPT.default_flags()
var settings_path := SETTINGS_PATH


func load() -> void:
	var config := ConfigFile.new()
	var error := config.load(settings_path)
	if error != OK:
		reset_to_defaults(false)
		return
	generate_run_log_files = bool(config.get_value(RUN_LOG_SECTION, GENERATE_LOG_KEY, false))
	vfx_speed = normalized_vfx_speed(String(config.get_value(GAMEPLAY_SECTION, VFX_SPEED_KEY, vfx_speed)))
	combat_vfx_quality = normalized_combat_vfx_quality(String(config.get_value(GAMEPLAY_SECTION, COMBAT_VFX_QUALITY_KEY, combat_vfx_quality)))
	reduced_motion = bool(config.get_value(GAMEPLAY_SECTION, REDUCED_MOTION_KEY, reduced_motion))
	game_juice_enabled = bool(config.get_value(GAMEPLAY_SECTION, GAME_JUICE_KEY, game_juice_enabled))
	var loaded_flags := {}
	for key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		loaded_flags[key] = bool(config.get_value(GAMEPLAY_SECTION, key, true))
	game_juice_flags = GAME_JUICE_FLAGS_SCRIPT.normalized_flags(loaded_flags)


func save() -> void:
	var config := ConfigFile.new()
	config.load(settings_path)
	config.set_value(RUN_LOG_SECTION, GENERATE_LOG_KEY, generate_run_log_files)
	config.set_value(GAMEPLAY_SECTION, VFX_SPEED_KEY, vfx_speed)
	config.set_value(GAMEPLAY_SECTION, COMBAT_VFX_QUALITY_KEY, combat_vfx_quality)
	config.set_value(GAMEPLAY_SECTION, REDUCED_MOTION_KEY, reduced_motion)
	config.set_value(GAMEPLAY_SECTION, GAME_JUICE_KEY, game_juice_enabled)
	for key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		config.set_value(GAMEPLAY_SECTION, key, bool(game_juice_flags.get(key, true)))
	var error := config.save(settings_path)
	if error != OK:
		push_warning("Failed to save user settings at %s: %d" % [settings_path, error])


func set_generate_run_log_files(enabled: bool) -> void:
	generate_run_log_files = enabled
	save()


func set_vfx_speed(speed: String) -> void:
	vfx_speed = normalized_vfx_speed(speed)
	save()


func set_combat_vfx_quality(quality: String) -> void:
	combat_vfx_quality = normalized_combat_vfx_quality(quality)
	save()


func set_reduced_motion_enabled(enabled: bool) -> void:
	reduced_motion = enabled
	save()


func set_game_juice_enabled(enabled: bool) -> void:
	game_juice_enabled = enabled
	save()


func game_juice_flag_enabled(flag_key: String) -> bool:
	return game_juice_enabled and bool(game_juice_flags.get(flag_key, false))


func set_game_juice_flag_enabled(flag_key: String, enabled: bool) -> void:
	if not GAME_JUICE_FLAGS_SCRIPT.is_valid_key(flag_key):
		return
	game_juice_flags[flag_key] = enabled
	save()


func reset_to_defaults(save_after_reset: bool = true) -> void:
	generate_run_log_files = false
	vfx_speed = VFX_SPEED_NORMAL
	combat_vfx_quality = COMBAT_VFX_QUALITY_LOW
	reduced_motion = false
	game_juice_enabled = true
	game_juice_flags = GAME_JUICE_FLAGS_SCRIPT.default_flags()
	if save_after_reset:
		save()


func combat_feedback_settings() -> Dictionary:
	return {
		"vfx_speed": vfx_speed,
		"combat_vfx_quality": combat_vfx_quality,
		"reduced_motion": reduced_motion,
		"game_juice": game_juice_enabled,
		"game_juice_flags": game_juice_flags.duplicate(),
	}


static func normalized_vfx_speed(speed: String) -> String:
	var normalized := speed.strip_edges().to_lower()
	match normalized:
		VFX_SPEED_SLOW, VFX_SPEED_NORMAL, VFX_SPEED_FAST, VFX_SPEED_INSTANT:
			return normalized
		_:
			return VFX_SPEED_NORMAL


static func normalized_combat_vfx_quality(quality: String) -> String:
	var normalized := quality.strip_edges().to_lower()
	match normalized:
		COMBAT_VFX_QUALITY_LOW, COMBAT_VFX_QUALITY_HIGH:
			return normalized
		_:
			return COMBAT_VFX_QUALITY_LOW
