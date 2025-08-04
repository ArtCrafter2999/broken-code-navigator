extends Node

@onready var main_scene: MainScene = $".."

func save_file():
	var file := FileAccess.open("user://data", FileAccess.WRITE)
	file.store_var(main_scene.history, true)
	file.store_var(main_scene.ballon.history, true)
	file.store_var(main_scene.get_current_state(), true)
	file.close();

func load_file():
	var file := FileAccess.open("user://data", FileAccess.READ)
	main_scene.history = file.get_var(true);
	main_scene.ballon.history = file.get_var(true);
	var state = file.get_var(true);
	print(state)
	file.close();
	main_scene.restore_state(state)
