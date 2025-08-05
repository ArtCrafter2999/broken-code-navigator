class_name MainMenu
extends Control

signal new_game_pressed
signal load_pressed

@onready var main_menu_music: AudioStreamPlayer = $MainMenuMusic
@onready var quit_button: GeneralMenuButton = $MainButtons/Quit
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var play_buttons: VBoxContainer = $PlayButtons
@onready var load_button: GeneralMenuButton = $PlayButtons/Load

var _is_sliding := false;

func open():
	visible = true;
	set_music_playing(true)
	await create_tween() \
		.tween_property(self, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT) \
		.finished

func close():
	set_music_playing(false)
	await create_tween() \
			.tween_property(self, "modulate", Color.TRANSPARENT, 0.5) \
			.finished
	main_buttons.position.x = 180
	play_buttons.position.x = -180
	visible = false;

func _ready() -> void:
	open();
	if OS.get_name() == "Web":
		quit_button.hide();

func slide_play_buttons(in_view: bool):
	if _is_sliding: return;
	
	var out_buttons = main_buttons if in_view else play_buttons
	var in_buttons = play_buttons if in_view else main_buttons
	
	_is_sliding = true
	create_tween().tween_property(
		out_buttons, "position", Vector2(-180, out_buttons.position.y), 0.5)
	await create_tween().tween_property(
		in_buttons, "position", Vector2(180, in_buttons.position.y), 0.5)\
		.finished
	_is_sliding = false

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
	close()

func _on_load_pressed() -> void:
	load_pressed.emit()
	close();

func _on_quit_pressed() -> void:
	get_tree().quit()
