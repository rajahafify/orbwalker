extends Node

const AudioStreamLoader = preload("res://scripts/core/audio_stream_loader.gd")

const SAMPLE_RATE := 44100
const MUSIC_VOLUME_DB := -12.0
const SFX_VOLUME_DB := -8.0
const MAX_SFX_PLAYERS := 8
const AUDIO_DIAGNOSTICS_SETTING_PATH := "debug/audio_diagnostics_enabled"
const MUSIC_STREAM_PATHS := {
	"combat": "res://resources/audio/music/combat.wav",
	"credits": "res://resources/audio/music/credit.wav",
	"menu": "res://resources/audio/music/main-menu.wav",
	"melody": "res://resources/audio/music/melody.wav",
	"shop": "res://resources/audio/music/shop.wav",
}
const ANDROID_TEMPLATE_RAW_MUSIC_PATHS := {
	"combat": "res://resources/audio/raw_music/combat.wav.bin",
	"menu": "res://resources/audio/raw_music/menu.wav.bin",
	"shop": "res://resources/audio/raw_music/shop.wav.bin",
}

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _streams: Dictionary = {}
var _music_stream_sources: Dictionary = {}
var _music_stream_source_paths: Dictionary = {}
var _current_music_key := ""
var _manual_music_restart_enabled := false


func _ready() -> void:
	_ensure_players()


func _ensure_players() -> void:
	if _music_player != null:
		return
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Master"
	_music_player.volume_db = MUSIC_VOLUME_DB
	add_child(_music_player)
	if not _music_player.finished.is_connected(_on_music_player_finished):
		_music_player.finished.connect(_on_music_player_finished)

	for index in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % (index + 1)
		player.volume_db = SFX_VOLUME_DB
		add_child(player)
		_sfx_players.append(player)


func play_music(key: String) -> void:
	if key == "":
		return
	_ensure_players()
	if _current_music_key == key and _music_player.stream != null and _music_player.playing:
		return
	_current_music_key = key
	_music_player.volume_db = MUSIC_VOLUME_DB
	_music_player.stream = _stream_for_music(key)
	_configure_music_playback_for_runtime(key, _music_player.stream)
	if _music_player.stream != null:
		_music_player.play()
		if audio_diagnostics_opt_in_enabled():
			var cache_key := "music:%s" % key
			var source_path := _music_stream_source_path(key)
			var source_frame_count := AudioStreamLoader.wav_source_frame_count(source_path)
			var loop_mode := "n/a"
			var loop_end := -1
			var data_bytes := -1
			if _music_player.stream is AudioStreamWAV:
				var wav_stream := _music_player.stream as AudioStreamWAV
				loop_mode = str(wav_stream.loop_mode)
				loop_end = wav_stream.loop_end
				data_bytes = wav_stream.data.size()
			print("AudioManager music: key=%s source=%s android=%s template=%s manual_restart=%s stream=%s loop_mode=%s loop_end=%s source_frame_count=%s stream_data_bytes=%s playing=%s volume_db=%s bus=%s" % [
				key,
				String(_music_stream_sources.get(cache_key, "unknown")),
				str(OS.has_feature("android")),
				str(OS.has_feature("template")),
				str(_manual_music_restart_enabled),
				_music_player.stream.get_class(),
				loop_mode,
				str(loop_end),
				str(source_frame_count),
				str(data_bytes),
				str(_music_player.playing),
				str(_music_player.volume_db),
				_music_player.bus,
			])


func stop_music() -> void:
	_current_music_key = ""
	_manual_music_restart_enabled = false
	if _music_player != null:
		_music_player.stop()


func play_sfx(key: String) -> void:
	_ensure_players()
	var stream := _stream_for_sfx(key)
	if stream == null:
		return
	var player := _available_sfx_player()
	if player == null:
		return
	player.stream = stream
	player.play()


func _available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	return _sfx_players[0] if not _sfx_players.is_empty() else null


func _stream_for_music(key: String) -> AudioStream:
	var cache_key := "music:%s" % key
	if _streams.has(cache_key):
		return _streams[cache_key]

	var music_stream := _load_music_stream(key)
	if music_stream != null:
		_streams[cache_key] = music_stream
		_music_stream_sources[cache_key] = String(music_stream.get_meta("audio_source", "imported_or_pcm_wav"))
		_music_stream_source_paths[cache_key] = String(music_stream.get_meta("audio_source_path", _music_source_path(key)))
		return music_stream

	var stream := _make_generated_music_stream(key)
	_streams[cache_key] = stream
	_music_stream_sources[cache_key] = "generated_fallback"
	_music_stream_source_paths[cache_key] = ""
	return stream


func _configure_music_playback_for_runtime(key: String, stream: AudioStream) -> void:
	_manual_music_restart_enabled = _is_android_or_template_runtime()
	if stream == null:
		return
	var source_path := _music_stream_source_path(key)
	if stream is AudioStreamWAV:
		var wav_stream := stream as AudioStreamWAV
		AudioStreamLoader.configure_wav_loop(wav_stream, source_path, _manual_music_restart_enabled)
	elif stream.has_method("set_loop"):
		stream.call("set_loop", not _manual_music_restart_enabled)


func _is_android_or_template_runtime() -> bool:
	return OS.has_feature("android") or OS.has_feature("template")


func _music_source_path(key: String) -> String:
	return String(MUSIC_STREAM_PATHS.get(key, ""))


func _music_stream_source_path(key: String) -> String:
	return String(_music_stream_source_paths.get("music:%s" % key, _music_source_path(key)))


func _make_generated_music_stream(key: String) -> AudioStreamWAV:
	var notes: Array[Dictionary]
	match key:
		"menu":
			notes = [
				{"freq": 220.0, "start": 0.0, "duration": 0.9, "volume": 0.20},
				{"freq": 329.63, "start": 0.6, "duration": 0.9, "volume": 0.15},
				{"freq": 392.0, "start": 1.2, "duration": 1.2, "volume": 0.12},
				{"freq": 246.94, "start": 2.4, "duration": 1.1, "volume": 0.18},
				{"freq": 369.99, "start": 3.0, "duration": 1.1, "volume": 0.13},
				{"freq": 440.0, "start": 3.6, "duration": 1.4, "volume": 0.12},
			]
		"shop":
			notes = [
				{"freq": 261.63, "start": 0.0, "duration": 0.7, "volume": 0.18},
				{"freq": 329.63, "start": 0.5, "duration": 0.8, "volume": 0.13},
				{"freq": 392.0, "start": 1.0, "duration": 0.8, "volume": 0.12},
				{"freq": 523.25, "start": 1.8, "duration": 0.5, "volume": 0.08},
				{"freq": 293.66, "start": 2.6, "duration": 0.9, "volume": 0.14},
				{"freq": 440.0, "start": 3.2, "duration": 1.0, "volume": 0.11},
			]
		_:
			notes = [
				{"freq": 146.83, "start": 0.0, "duration": 1.2, "volume": 0.20},
				{"freq": 220.0, "start": 0.7, "duration": 1.0, "volume": 0.14},
				{"freq": 293.66, "start": 1.4, "duration": 1.0, "volume": 0.12},
				{"freq": 164.81, "start": 2.5, "duration": 1.1, "volume": 0.18},
				{"freq": 246.94, "start": 3.1, "duration": 1.1, "volume": 0.13},
				{"freq": 329.63, "start": 3.8, "duration": 1.2, "volume": 0.11},
			]
	return _make_poly_stream(notes, 4.8, true)


func _load_music_stream(key: String) -> AudioStream:
	var path := String(MUSIC_STREAM_PATHS.get(key, ""))
	if path == "":
		return null
	if _is_android_or_template_runtime():
		var raw_path := String(ANDROID_TEMPLATE_RAW_MUSIC_PATHS.get(key, ""))
		if raw_path != "":
			var raw_stream := AudioStreamLoader.load_pcm16_wav_stream(raw_path, _is_android_or_template_runtime())
			if raw_stream != null:
				raw_stream.set_meta("audio_source", "raw_pcm_wav")
				raw_stream.set_meta("audio_source_path", raw_path)
				return raw_stream
	var stream := AudioStreamLoader.load_pcm16_wav_stream(path, _is_android_or_template_runtime())
	if stream != null:
		stream.set_meta("audio_source", "imported_or_pcm_wav")
		stream.set_meta("audio_source_path", path)
		return stream
	var imported_stream := AudioStreamLoader.load_imported_audio_stream(path, _is_android_or_template_runtime())
	if imported_stream != null:
		imported_stream.set_meta("audio_source", "imported_or_pcm_wav")
		imported_stream.set_meta("audio_source_path", path)
	return imported_stream


func _on_music_player_finished() -> void:
	if not _manual_music_restart_enabled:
		return
	if _current_music_key == "":
		return
	if audio_diagnostics_opt_in_enabled():
		var source_path := _music_stream_source_path(_current_music_key)
		var source_frame_count := AudioStreamLoader.wav_source_frame_count(source_path)
		var loop_mode := "n/a"
		var loop_end := -1
		var data_bytes := -1
		if _music_player != null and _music_player.stream is AudioStreamWAV:
			var wav_stream := _music_player.stream as AudioStreamWAV
			loop_mode = str(wav_stream.loop_mode)
			loop_end = wav_stream.loop_end
			data_bytes = wav_stream.data.size()
		print("AudioManager music manual restart fired: key=%s source=%s loop_mode=%s loop_end=%s source_frame_count=%s stream_data_bytes=%s android=%s template=%s" % [
			_current_music_key,
			String(_music_stream_sources.get("music:%s" % _current_music_key, "unknown")),
			loop_mode,
			str(loop_end),
			str(source_frame_count),
			str(data_bytes),
			str(OS.has_feature("android")),
			str(OS.has_feature("template")),
		])
	play_music(_current_music_key)


func audio_diagnostics_opt_in_enabled() -> bool:
	if not ProjectSettings.has_setting(AUDIO_DIAGNOSTICS_SETTING_PATH):
		return false
	var setting_value: Variant = ProjectSettings.get_setting(AUDIO_DIAGNOSTICS_SETTING_PATH, false)
	if setting_value is bool:
		return setting_value
	if setting_value is int:
		return setting_value != 0
	if setting_value is float:
		return not is_zero_approx(setting_value)
	if setting_value is String:
		return ["1", "true", "yes", "on"].has(String(setting_value).strip_edges().to_lower())
	return false


func _stream_for_sfx(key: String) -> AudioStreamWAV:
	var cache_key := "sfx:%s" % key
	if _streams.has(cache_key):
		return _streams[cache_key]

	var stream: AudioStreamWAV
	match key:
		"ui_accept":
			stream = _make_chirp([520.0, 700.0], 0.12, 0.35)
		"ui_cancel":
			stream = _make_chirp([260.0, 180.0], 0.14, 0.32)
		"match":
			stream = _make_chirp([520.0, 780.0, 1040.0], 0.16, 0.28)
		"combo":
			stream = _make_chirp([740.0, 980.0], 0.10, 0.24)
		"swap":
			stream = _make_chirp([360.0, 510.0], 0.055, 0.18)
		"hit":
			stream = _make_chirp([150.0, 95.0], 0.18, 0.42)
		"heal":
			stream = _make_chirp([440.0, 660.0, 880.0], 0.20, 0.25)
		"armor":
			stream = _make_chirp([300.0, 420.0], 0.16, 0.30)
		"gold":
			stream = _make_chirp([880.0, 1320.0], 0.12, 0.22)
		"victory":
			stream = _make_chirp([523.25, 659.25, 783.99, 1046.5], 0.38, 0.28)
		"defeat":
			stream = _make_chirp([220.0, 164.81, 110.0], 0.45, 0.35)
		"purchase":
			stream = _make_chirp([620.0, 920.0, 1240.0], 0.16, 0.27)
		"error":
			stream = _make_chirp([180.0, 150.0], 0.18, 0.34)
		_:
			stream = _make_chirp([420.0], 0.10, 0.20)

	_streams[cache_key] = stream
	return stream


func _make_chirp(frequencies: Array[float], duration: float, volume: float) -> AudioStreamWAV:
	var notes: Array[Dictionary] = []
	var note_duration := duration / maxf(1.0, float(frequencies.size()))
	for index in frequencies.size():
		notes.append({
			"freq": frequencies[index],
			"start": float(index) * note_duration,
			"duration": note_duration,
			"volume": volume,
		})
	return _make_poly_stream(notes, duration, false)


func _make_poly_stream(notes: Array[Dictionary], duration: float, loop: bool) -> AudioStreamWAV:
	var frame_count := maxi(1, int(duration * SAMPLE_RATE))
	var data := PackedByteArray()
	data.resize(frame_count * 4)

	for frame in frame_count:
		var time := float(frame) / float(SAMPLE_RATE)
		var sample := 0.0
		for note in notes:
			var start := float(note.get("start", 0.0))
			var note_duration := float(note.get("duration", 0.1))
			if time < start or time > start + note_duration:
				continue
			var note_time := time - start
			var env := _envelope(note_time, note_duration)
			var freq := float(note.get("freq", 440.0))
			var volume := float(note.get("volume", 0.2))
			sample += sin(TAU * freq * note_time) * env * volume
			sample += sin(TAU * freq * 2.0 * note_time) * env * volume * 0.16
		var encoded := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(frame * 4, encoded)
		data.encode_s16(frame * 4 + 2, encoded)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = true
	stream.data = data
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = frame_count
	return stream


func _envelope(time: float, duration: float) -> float:
	var attack := minf(0.04, duration * 0.25)
	var release := minf(0.12, duration * 0.35)
	if time < attack:
		return time / maxf(0.001, attack)
	if time > duration - release:
		return maxf(0.0, (duration - time) / maxf(0.001, release))
	return 1.0
