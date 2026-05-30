extends RefCounted
class_name RepoHygieneTest

const FORBIDDEN_EXACT_PATHS := [
	"Orbwalker.apk",
]
const FORBIDDEN_PREFIXES := [
	".godot/",
	"android/",
	"build/",
	"logs/",
	"tmp/",
]
const FORBIDDEN_SUFFIXES := [
	".aab",
	".apk",
	".apks",
	".idsig",
	".pyc",
	".pyo",
]
const FORBIDDEN_PATH_SEGMENTS := [
	"/__pycache__/",
]


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("tracked_generated_artifacts_are_absent", _test_tracked_generated_artifacts_are_absent, failures)

	return {
		"passed": failures.is_empty(),
		"total": 1,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_tracked_generated_artifacts_are_absent() -> String:
	var tracked_files_result := _tracked_files()
	if tracked_files_result.has("__error"):
		return String(tracked_files_result["__error"])
	var generated_artifacts: Array[String] = []
	for path in Array(tracked_files_result.get("paths", [])):
		var normalized := String(path).replace("\\", "/")
		if _is_forbidden_generated_artifact(normalized):
			generated_artifacts.append(normalized)
	if not generated_artifacts.is_empty():
		return "Expected generated artifacts not to be tracked; found %s." % ", ".join(generated_artifacts)
	return ""


func _tracked_files() -> Dictionary:
	var output: Array = []
	var project_root := ProjectSettings.globalize_path("res://")
	var exit_code := OS.execute("git", PackedStringArray(["-C", project_root, "ls-files"]), output, true)
	if exit_code != 0:
		return {"__error": "Expected git ls-files to succeed for repo hygiene check; exit code %d." % exit_code}
	var stdout := ""
	for chunk in output:
		stdout += String(chunk)
	var paths: Array[String] = []
	for line in stdout.split("\n", false):
		var path := String(line).strip_edges()
		if path != "":
			paths.append(path)
	return {"paths": paths}


func _is_forbidden_generated_artifact(path: String) -> bool:
	if path in FORBIDDEN_EXACT_PATHS:
		return true
	for prefix in FORBIDDEN_PREFIXES:
		if path.begins_with(String(prefix)):
			return true
	for suffix in FORBIDDEN_SUFFIXES:
		if path.ends_with(String(suffix)):
			return true
	for segment in FORBIDDEN_PATH_SEGMENTS:
		if path.contains(String(segment)) or path.begins_with(String(segment).trim_prefix("/")):
			return true
	return false
