extends Node

@onready var main_menu: MainMenu = $MainMenu
@onready var play_scene: PlayScene = $PlayScene
@onready var save_load_manager: Node = $SaveLoadManager

func _on_main_menu_new_game_pressed() -> void:
	main_menu.set_music_playing(false)
	await create_tween() \
			.tween_property(main_menu, "modulate", Color.TRANSPARENT, 0.5) \
			.finished

	await get_tree().create_timer(0.5).timeout

	play_scene.show()
	play_scene.play("res://dialogues/test dialogue.dialogue")

func _on_main_menu_load_pressed() -> void:
	save_load_manager.load_file();
