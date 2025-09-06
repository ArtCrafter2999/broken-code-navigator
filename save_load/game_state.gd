extends Node

var settings: Dictionary = {}
var read_messages = []

func _ready() -> void:
	_load()

func _process(delta: float) -> void:
	_apply_settings()

func save():
	var file := FileAccess.open("user://saved_data", FileAccess.WRITE)
	file.store_var(settings, true)
	file.store_var(read_messages, true)
	file.close();

func _load():
	if not FileAccess.file_exists("user://saved_data"):
		_default();
	var file := FileAccess.open("user://saved_data", FileAccess.READ)
	if not file: _default();
	settings = file.get_var(true);
	read_messages = file.get_var(true);
	file.close();

func _default():
	settings = {
		&"noise": true,
		&"chromatic_abberation": true,
		&"window_mode": DisplayServer.WINDOW_MODE_FULLSCREEN,
		&"music_volume": 100,
		&"sfx_volume": 100,
		&"voice_volume": 100
	}
	save();

func _apply_settings():
	if not Engine.is_embedded_in_editor():
		DisplayServer.window_set_mode(settings[&"window_mode"])
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"), 
		linear_to_db(settings[&"sfx_volume"] / 100.0))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"), 
		linear_to_db(settings[&"music_volume"] / 100.0))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"), 
		linear_to_db(settings[&"voice_volume"] / 100.0))
