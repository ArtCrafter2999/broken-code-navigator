class_name MainScene
extends Node

@onready var main_menu: MainMenu = $MainMenu
@onready var play_scene: PlayScene = $PlayScene
@onready var save_load_manager: SaveLoadManager = $SaveLoadManager
@onready var pause_screen: PauseScreen = $PauseScreen

var in_main_menu: bool = true;

func _input(event: InputEvent) -> void:
	if in_main_menu: return
	if Input.is_action_just_pressed("Pause"):
		if pause_screen.is_open:
			pause_screen.close()
			play_scene.resume()
		else:
			pause_screen.open()
			play_scene.pause()

func _on_main_menu_new_game_pressed() -> void:
	await get_tree().create_timer(1).timeout

	play_scene.show()
	play_scene.play("res://dialogues/test dialogue.dialogue")
	in_main_menu = false;

func _on_main_menu_load_pressed() -> void:
	in_main_menu = false;
	save_load_manager.load_file("quick", true);


func _on_pause_screen_main_menu() -> void:
	save_load_manager.save_file()
	in_main_menu = true;
	play_scene.quit()
	pause_screen.close()
	main_menu.open()
