extends RefCounted
class_name AudioManagerResolver

const AUDIO_MANAGER_SCRIPT := preload("res://scripts/core/audio_manager.gd")


static func audio_manager_node(tree: SceneTree) -> Node:
	if tree == null or tree.root == null:
		return null
	var audio := tree.root.get_node_or_null("AudioManager")
	if audio != null:
		return audio
	audio = AUDIO_MANAGER_SCRIPT.new()
	audio.name = "AudioManager"
	tree.root.add_child(audio)
	return audio
