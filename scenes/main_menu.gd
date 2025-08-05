class_name MainMenu
extends Control

signal new_game_pressed
signal load_pressed

@onready var main_menu_music: AudioStreamPlayer = $MainMenuMusic
@onready var quit_button: GeneralMenuButton = $VBoxContainer/Quit
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var play_buttons: VBoxContainer = $PlayButtons
@onready var load_button: GeneralMenuButton = $PlayButtons/Load

func _ready() -> void:
	set_music_playing(true)
	if OS.get_name() == "Web":
		quit_button.hide();

func slide_play_buttons(in_view: bool):
	var out_buttons = main_buttons if in_view else play_buttons
	var in_buttons = play_buttons if in_view else main_buttons
	
	create_tween().tween_property(
		out_buttons, "position", Vector2(-out_buttons.position.x, out_buttons.position.y), 0.5)
	create_tween().tween_property(
		in_buttons, "position", Vector2(-in_buttons.position.x, in_buttons.position.y), 0.5)

func set_music_playing(value: bool):
	if value:
		main_menu_music.play(0)
		var tween = get_tree().create_tween()
		tween.tween_property(main_menu_music, "volume_linear", 1, 1).from(0)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(main_menu_music, "volume_linear", 0, 1)
		await tween.finished
		main_menu_music.stop();


func _on_new_game_pressed() -> void:
	new_game_pressed.emit()


func _on_load_pressed() -> void:
	load_pressed.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()
