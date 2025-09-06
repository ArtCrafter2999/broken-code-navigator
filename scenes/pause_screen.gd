class_name PauseScreen
extends CanvasLayer

signal main_menu
signal closed

@export var save_load_manager: SaveLoadManager;

@onready var panel: Panel = $Panel
@onready var load_screen: LoadScreen = $Panel/LoadScreen
@onready var settings_screen: SettingsScreen = $Panel/SettingsScreen
@onready var buttons: VBoxContainer = $Panel/Buttons
@onready var audio_slide: AudioStreamPlayer = $AudioSlide

var is_open = false;

var tween: Tween
var image: Image

var _buttons_sliding : Array[Control] = [];

func _ready() -> void:
	load_screen.save_load_manager = save_load_manager

func _process(delta: float) -> void:
	if Input.is_action_pressed("HideUI"):
		panel.modulate = Color.TRANSPARENT;
	else:
		panel.modulate = Color.WHITE;

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

func close():
	if not is_open: return;
	closed.emit()
	load_screen.close()
	is_open = false;
	
	if tween:
		tween.kill();
		
	tween = get_tree().create_tween()
	tween.tween_property(panel, "modulate", Color.TRANSPARENT, 0.2)
	await tween.finished
	
	if is_open: return;
	
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

func _on_save_pressed() -> void:
	print(image.data.width)
	save_load_manager.save_file(image)

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

func _on_settings_pressed() -> void:
	slide_buttons(buttons, false)
	settings_screen.open()

func _on_settings_screen_back_pressed() -> void:
	slide_buttons(buttons, true)
	settings_screen.close()
