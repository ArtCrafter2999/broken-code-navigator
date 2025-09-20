class_name SaveLoadManager
extends Node

@export var play_scene: PlayScene
@export var main_menu: MainMenu
@onready var main_scene: MainScene = $".."

func _ready() -> void:
	await get_tree().process_frame
	if not DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_absolute("user://saves")
		main_menu.load_button.disabled = true
	elif _is_save_dir_empty():
		main_menu.load_button.disabled = true

func save_file(image: Image = null):
	var file_name = Time.get_datetime_string_from_system().replace(":", "")
	var file := FileAccess.open("user://saves/%s" % file_name, FileAccess.WRITE)
	image.compress(Image.COMPRESS_S3TC)
	file.store_var(image.data, true)
	file.store_var(play_scene.get_current_state(), true)
	file.store_var(play_scene.history, true)
	file.store_var(play_scene.ballon.history, true)
	
	main_menu.load_button.disabled = false
	file.close();

func load_image(file_name: String):
	if not FileAccess.file_exists("user://saves/%s" % file_name):
		push_error("Trying to load savefile '%s' that doesnt exist" % file_name)
		return null;
	var file := FileAccess.open("user://saves/%s" % file_name, FileAccess.READ)
	var data = file.get_var(true)
	var image = Image.create_empty(0, 0, true, Image.Format.FORMAT_RGBA8)
	image.data = data
	return image;

func load_file(file_name: String, from_menu: bool = false):
	if not FileAccess.file_exists("user://saves/%s" % file_name):
		push_error("Trying to load savefile '%s' that doesnt exist" % file_name)
		return;
	var file := FileAccess.open("user://saves/%s" % file_name, FileAccess.READ)
	file.get_var(true)
	var state = file.get_var(true);
	play_scene.history = file.get_var(true);
	if from_menu:
		play_scene.play("res://dialogues/script.dialogue", state.get("line_id"))
		play_scene.ballon.history = file.get_var(true);
	else:
		play_scene.ballon.history = file.get_var(true);
		play_scene.restore_state(state)
	file.close();

func get_save_files() -> Array[Dictionary]:
	var dir = DirAccess.open("user://saves")
	var files = dir.get_files()
	var response: Array[Dictionary] = []
	for file in files:
		response.append({"file": file, "image": load_image(file)})
	return response

func _is_save_dir_empty():
	var dir = DirAccess.open("user://saves")
	if dir == null:
		# Directory does not exist, so it's not empty in the sense
		# that it can't be 	opened, but you might want to handle this differently.
		# For this example, we'll return false, as it's not "empty" of
		# content (it's just missing).	
		return false
	
	dir.list_dir_begin() # `true` to skip hidden files and nav entries
	var file_name = dir.get_next()
	dir.list_dir_end()
	
	return file_name == ""

func remove_all_saves():
	var dir = DirAccess.open("user://saves");
	if not dir: return;
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			dir.remove("user://saves".path_join(file_name))
		file_name = dir.get_next()
	main_menu.load_button.disabled = true
