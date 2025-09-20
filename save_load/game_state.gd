extends Node

var settings: Dictionary = {}
var read_messages = []

const DEFAULT_SETTINGS =  {
	&"noise": true,
	&"chromatic_abberation": true,
	&"window_mode": DisplayServer.WINDOW_MODE_FULLSCREEN,
	&"music_volume": 100,
	&"sfx_volume": 100,
	&"voice_volume": 100,
	&"font_size": 28,
}

func _ready() -> void:
	_load()
	_apply_settings();

func save():
	_save_file();
	_apply_settings();

func get_setting(key: StringName):
	return settings.get_or_add(key, DEFAULT_SETTINGS.get(key))

func set_setting(key: StringName, value: Variant):
	settings[key] = value
	_save_file()
	_apply_settings(key == &"window_mode")
	
func _save_file():
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
	settings = DEFAULT_SETTINGS
	save();

func _apply_settings(change_window: bool = true):
	if change_window and not Engine.is_embedded_in_editor():
		DisplayServer.window_set_mode(get_setting(&"window_mode"))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"), 
		linear_to_db(get_setting(&"sfx_volume") / 100.0))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"), 
		linear_to_db(get_setting(&"music_volume") / 100.0))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Voice"), 
		linear_to_db(get_setting(&"voice_volume") / 100.0))
