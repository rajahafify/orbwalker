extends Node


const SAMPLE_RATE := 44100
const MUSIC_VOLUME_DB := -12.0
const SFX_VOLUME_DB := -8.0
const MAX_SFX_PLAYERS := 8
const MUSIC_STREAM_PATHS := {
	"combat": "res://resources/audio/music/combat.wav",
	"credits": "res://resources/audio/music/credit.wav",
	"menu": "res://resources/audio/music/main-menu.wav",
	"melody": "res://resources/audio/music/melody.wav",
	"shop": "res://resources/audio/music/shop.wav",
}

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _streams: Dictionary = {}
var _current_music_key := ""


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
	if _music_player.stream != null:
		_music_player.play()
		print("AudioManager music playing: key=%s stream=%s volume_db=%s bus=%s" % [
			key,
			_music_player.stream.get_class(),
			str(_music_player.volume_db),
			_music_player.bus,
		])


func stop_music() -> void:
	_current_music_key = ""
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
		return music_stream

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

	var stream := _make_poly_stream(notes, 4.8, true)
	_streams[cache_key] = stream
	return stream


func _load_music_stream(key: String) -> AudioStream:
	var path := String(MUSIC_STREAM_PATHS.get(key, ""))
	if path == "" or not ResourceLoader.exists(path):
		return null
	var stream := _load_pcm16_wav_stream(path)
	if stream != null:
		return stream
	var imported_stream := load(path)
	if imported_stream is AudioStreamWAV:
		imported_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	return imported_stream if imported_stream is AudioStream else null


func _load_pcm16_wav_stream(path: String) -> AudioStreamWAV:
	var file := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.READ)
	if file == null:
		file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var bytes := file.get_buffer(file.get_length())
	if bytes.size() < 44:
		return null
	if bytes.slice(0, 4).get_string_from_ascii() != "RIFF" or bytes.slice(8, 12).get_string_from_ascii() != "WAVE":
		return null

	var channels := 0
	var sample_rate := 0
	var bits_per_sample := 0
	var data := PackedByteArray()
	var offset := 12
	while offset + 8 <= bytes.size():
		var chunk_id := bytes.slice(offset, offset + 4).get_string_from_ascii()
		var chunk_size := bytes.decode_u32(offset + 4)
		var chunk_start := offset + 8
		var chunk_end := mini(chunk_start + chunk_size, bytes.size())
		if chunk_id == "fmt " and chunk_size >= 16:
			var audio_format := bytes.decode_u16(chunk_start)
			if audio_format != 1:
				return null
			channels = bytes.decode_u16(chunk_start + 2)
			sample_rate = bytes.decode_u32(chunk_start + 4)
			bits_per_sample = bytes.decode_u16(chunk_start + 14)
		elif chunk_id == "data":
			data = bytes.slice(chunk_start, chunk_end)
			break
		offset = chunk_end + int(chunk_size % 2)

	if data.is_empty() or sample_rate <= 0 or bits_per_sample != 16 or (channels != 1 and channels != 2):
		return null
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = channels == 2
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = int(float(data.size()) / (2.0 * float(channels)))
	return stream


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
