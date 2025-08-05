extends Node

var settings: Dictionary = {}
var read_messages = []

func _ready() -> void:
	_load()

func save():
	var file := FileAccess.open("user://saved_data", FileAccess.WRITE)
	file.store_var(settings, true)
	file.store_var(read_messages, true)
	file.close();

func _load():
	if not FileAccess.file_exists("user://saved_data"):
		return;
	var file := FileAccess.open("user://saved_data", FileAccess.READ)
	if not file: return;
	settings = file.get_var(true);
	read_messages = file.get_var(true);
	file.close();
