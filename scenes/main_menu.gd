class_name MainMenu
extends Control

signal new_game_pressed
signal load_pressed

@export var backgrounds: Array[Texture2D]
@export var save_load_manager: SaveLoadManager

@onready var background: TextureRect = $Background
@onready var main_menu_music: AudioStreamPlayer = $MainMenuMusic
@onready var quit_button: GeneralMenuButton = $MainButtons/Quit
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var play_buttons: VBoxContainer = $PlayButtons
@onready var load_button: GeneralMenuButton = $PlayButtons/Load
@onready var audio_slide: AudioStreamPlayer = $AudioSlide
@onready var load_screen: LoadScreen = $LoadScreen
@onready var settings_screen: SettingsScreen = $SettingsScreen

var _buttons_sliding : Array[Control] = [];

func open():
	background.texture = backgrounds.pick_random()
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
	main_buttons.position.x = 75
	play_buttons.position.x = -320
	visible = false;


func _ready() -> void:
	load_screen.save_load_manager = save_load_manager;
	if OS.get_name() == "Web":
		quit_button.hide();


func slide_buttons(buttons: Control, in_view: bool):
	if _buttons_sliding.has(buttons): return;
	load_screen.close();
	audio_slide.play();
	
	_buttons_sliding.append(buttons)
	if in_view:
		await create_tween().tween_property(
			buttons, "position", Vector2(75, buttons.position.y), 0.5)\
			.finished
	else:
		await create_tween().tween_property(
			buttons, "position", Vector2(-320, buttons.position.y), 0.5)
	_buttons_sliding.erase(buttons)


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
	slide_buttons(play_buttons, false)
	load_screen.open();


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_load_screen_loaded_file(file_name: String) -> void:
	save_load_manager.load_file(file_name, true);
	load_pressed.emit()
	close();


func _back_to_play_buttons():
	slide_buttons(play_buttons, true)
	load_screen.close();
	
	
func _open_play_buttons():
	slide_buttons(main_buttons, false)
	slide_buttons(play_buttons, true)


func _back_to_main_buttons():
	slide_buttons(main_buttons, true)
	slide_buttons(play_buttons, false)
	settings_screen.close();
	load_screen.close();


func _on_settings_pressed() -> void:
	slide_buttons(main_buttons, false)
	settings_screen.open()
