class_name MainScene
extends Node

@onready var main_menu: MainMenu = $MainMenu
@onready var play_scene: PlayScene = $PlayScene
@onready var save_load_manager: SaveLoadManager = $SaveLoadManager
@onready var pause_screen: PauseScreen = $PauseScreen
@onready var back_button: CanvasLayer = $PlayScene/BackButton
@onready var credits: Credits = $Credits
@onready var disclaimer: TextureRect = $Disclaimer

var in_main_menu: bool = true:
	get:
		return in_main_menu;
	set(value):
		in_main_menu = value
		if value:
			back_button.hide()
		else:
			back_button.show()

func _ready() -> void:
	pause_screen.closed.connect(play_scene.resume)

func _input(_event: InputEvent) -> void:
	if in_main_menu: return
	if Input.is_action_just_pressed("Pause"):
		if pause_screen.is_open:
			pause_screen.close()
		else:
			_pause();

func _on_main_menu_new_game_pressed() -> void:
	await get_tree().create_timer(1).timeout

	play_scene.show()
	play_scene.play("res://dialogues/script.dialogue")
	in_main_menu = false;

func _on_main_menu_load_pressed() -> void:
	in_main_menu = false;
	#save_load_manager.load_file("quick", true);


func _on_pause_screen_main_menu() -> void:
	#save_load_manager.save_file()
	in_main_menu = true;
	play_scene.quit()
	pause_screen.close()
	main_menu.open()


func _on_main_menu_test_pressed() -> void:
	await get_tree().create_timer(1).timeout

	play_scene.show()
	play_scene.play("res://dialogues/test dialogue.dialogue")
	in_main_menu = false;

func _pause() -> void:
	pause_screen.open()
	play_scene.pause()


func _on_play_scene_removed_saves() -> void:
	save_load_manager.remove_all_saves()


func _on_play_scene_game_ended() -> void:
	in_main_menu = true;
	play_scene.quit()
	pause_screen.close()
	credits.start()


func _on_credits_credits_ended() -> void:
	credits.quit()
	main_menu.open()


func _on_disclaimer_finished() -> void:
	main_menu.open();
