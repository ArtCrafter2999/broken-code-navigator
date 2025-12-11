class_name PauseScreen
extends CanvasLayer

signal main_menu
signal closed

@export var save_load_manager: SaveLoadManager;
@export var play_scene: PlayScene;

@onready var panel: Panel = $Panel
@onready var load_screen: LoadScreen = $Panel/LoadScreen
@onready var settings_screen: SettingsScreen = $Panel/SettingsScreen
@onready var history_screen: HistoryScreen = $Panel/HistoryScreen
@onready var buttons: VBoxContainer = $Panel/Buttons
@onready var audio_slide: AudioStreamPlayer = $AudioSlide
@onready var save_name_dialog: Panel = $Panel/SaveNameDialog
@onready var save_name_field: TextEdit = %SaveName
@onready var about_screen: AboutScreen = $Panel/AboutScreen

var is_open = false;

var tween: Tween
var image: Image

var _buttons_sliding : Dictionary[Control, Tween] = {};

func _ready() -> void:
	load_screen.save_load_manager = save_load_manager
	history_screen.play_scene = play_scene

func _process(delta: float) -> void:
	if Input.is_action_pressed("HideUI"):
		panel.modulate = Color.TRANSPARENT;
	else:
		panel.modulate = Color.WHITE;

func slide_buttons(buttons: Control, in_view: bool):
	if _buttons_sliding.has(buttons): return;
	audio_slide.play();
	
	var tween = create_tween();
	_buttons_sliding.set(buttons, tween);
	if in_view:
		tween.tween_property(
			buttons, "position", Vector2(75, buttons.position.y), 0.5)
	else:
		tween.tween_property(
			buttons, "position", Vector2(-320, buttons.position.y), 0.5)
	await tween.finished
	_buttons_sliding.erase(buttons)

func close():
	if not is_open: return;
	closed.emit()
	load_screen.close()
	settings_screen.close()
	history_screen.close()
	is_open = false;
	
	if tween:
		tween.kill();
		
	tween = get_tree().create_tween()
	tween.tween_property(panel, "modulate", Color.TRANSPARENT, 0.2)
	await tween.finished
	
	if is_open: return;
	
	var sliding_tween: Tween = _buttons_sliding.get(buttons, null);
	if sliding_tween:
		sliding_tween.kill();
		_buttons_sliding.erase(buttons)
	buttons.position.x = 75
	visible = false

func open():
	if is_open: return;
	is_open = true
	await RenderingServer.frame_post_draw;
	image = get_viewport().get_texture().get_image();
	
	visible = true;
	if tween:
		tween.kill();
		
	tween = get_tree().create_tween()
	tween.tween_property(panel, "modulate", Color.WHITE, 0.2)
	await tween.finished
	
	if not is_open: return;

func _on_load_pressed() -> void:
	slide_buttons(buttons, false)
	load_screen.open()

func _on_main_menu_pressed() -> void:
	main_menu.emit()

func _on_load_screen_loaded_file(file_name: String) -> void:
	save_load_manager.load_file(file_name);
	close();

func _on_load_screen_back_pressed() -> void:
	slide_buttons(buttons, true)
	load_screen.close();

func _on_settings_pressed() -> void:
	slide_buttons(buttons, false)
	settings_screen.open()

func _on_settings_screen_back_pressed() -> void:
	slide_buttons(buttons, true)
	settings_screen.close()
	
func _on_history_screen_back_pressed() -> void:
	slide_buttons(buttons, true)
	history_screen.close()

func _on_history_pressed() -> void:
	slide_buttons(buttons, false)
	history_screen.open()

func _on_save_confirm_button_pressed() -> void:
	var save_name = save_name_field.text;
	if !save_name: save_name = save_name_field.placeholder_text
	save_load_manager.save_file(image, save_name)
	save_name_dialog.hide()

func _on_cancel_save_button_pressed() -> void:
	save_name_dialog.hide()

func _on_save_button_pressed() -> void:
	save_name_dialog.show()
	save_name_field.placeholder_text = Time.get_datetime_string_from_system().replace(":", ".").replace("T", " ")

func on_link_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_about_pressed() -> void:
	slide_buttons(buttons, false)
	about_screen.open()

func _on_about_screen_back_pressed() -> void:
	slide_buttons(buttons, true)
	about_screen.close()
