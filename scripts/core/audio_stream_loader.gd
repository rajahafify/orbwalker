extends RefCounted


static func load_pcm16_wav_stream(path: String, disable_internal_loop: bool = false) -> AudioStreamWAV:
	var bytes := read_file_bytes(path)
	var parsed := _parse_wav_bytes(bytes)
	if parsed.is_empty():
		return null
	if int(parsed.get("audio_format", 0)) != 1:
		return null
	var channels := int(parsed.get("channels", 0))
	var sample_rate := int(parsed.get("sample_rate", 0))
	var bits_per_sample := int(parsed.get("bits_per_sample", 0))
	var data: PackedByteArray = parsed.get("data", PackedByteArray())
	if data.is_empty() or sample_rate <= 0 or bits_per_sample != 16 or (channels != 1 and channels != 2):
		return null

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = channels == 2
	stream.data = data
	configure_wav_loop(stream, path, disable_internal_loop)
	return stream


static func load_imported_audio_stream(path: String, disable_internal_loop: bool = false) -> AudioStream:
	var imported_stream: Variant = load(path)
	if imported_stream is AudioStreamWAV:
		configure_wav_loop(imported_stream, path, disable_internal_loop)
	elif imported_stream is AudioStream:
		if imported_stream.has_method("set_loop"):
			imported_stream.call("set_loop", not disable_internal_loop)
	return imported_stream if imported_stream is AudioStream else null


static func configure_wav_loop(stream: AudioStreamWAV, source_path: String = "", disable_internal_loop: bool = false) -> void:
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED if disable_internal_loop else AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	var frame_count := wav_frame_count(stream, source_path)
	if disable_internal_loop:
		stream.loop_end = 0
	elif frame_count > 0:
		stream.loop_end = frame_count
	elif stream.loop_end <= 0:
		stream.loop_end = 1


static func wav_frame_count(stream: AudioStreamWAV, source_path: String = "") -> int:
	var source_frame_count := wav_source_frame_count(source_path)
	if source_frame_count > 0:
		return source_frame_count
	var channels := 2 if stream.stereo else 1
	if channels <= 0:
		return 0
	if stream.data.is_empty():
		return 0
	return int(float(stream.data.size()) / (2.0 * float(channels)))


static func wav_source_frame_count(path: String) -> int:
	if path == "":
		return 0
	var parsed := _parse_wav_bytes(read_file_bytes(path))
	if parsed.is_empty():
		return 0
	if int(parsed.get("audio_format", 0)) != 1:
		return 0
	var channels := int(parsed.get("channels", 0))
	var bits_per_sample := int(parsed.get("bits_per_sample", 0))
	var data_size := int(parsed.get("data_size", 0))
	if channels <= 0 or bits_per_sample <= 0 or bits_per_sample % 8 != 0 or data_size <= 0:
		return 0
	var bytes_per_sample := int(float(bits_per_sample) / 8.0)
	var bytes_per_frame := bytes_per_sample * channels
	if bytes_per_frame <= 0:
		return 0
	return int(float(data_size) / float(bytes_per_frame))


static func read_file_bytes(path: String) -> PackedByteArray:
	var empty := PackedByteArray()
	var file := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.READ)
	if file == null:
		file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return empty
	return file.get_buffer(file.get_length())


static func _parse_wav_bytes(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 44:
		return {}
	if bytes.slice(0, 4).get_string_from_ascii() != "RIFF" or bytes.slice(8, 12).get_string_from_ascii() != "WAVE":
		return {}

	var parsed := {
		"audio_format": 0,
		"channels": 0,
		"sample_rate": 0,
		"bits_per_sample": 0,
		"data": PackedByteArray(),
		"data_size": 0,
	}
	var offset := 12
	while offset + 8 <= bytes.size():
		var chunk_id := bytes.slice(offset, offset + 4).get_string_from_ascii()
		var chunk_size := bytes.decode_u32(offset + 4)
		var chunk_start := offset + 8
		var chunk_end := mini(chunk_start + chunk_size, bytes.size())
		if chunk_id == "fmt " and chunk_size >= 16:
			parsed["audio_format"] = bytes.decode_u16(chunk_start)
			parsed["channels"] = bytes.decode_u16(chunk_start + 2)
			parsed["sample_rate"] = bytes.decode_u32(chunk_start + 4)
			parsed["bits_per_sample"] = bytes.decode_u16(chunk_start + 14)
		elif chunk_id == "data":
			parsed["data"] = bytes.slice(chunk_start, chunk_end)
			parsed["data_size"] = maxi(0, chunk_end - chunk_start)
			break
		offset = chunk_end + int(chunk_size % 2)
	return parsed
