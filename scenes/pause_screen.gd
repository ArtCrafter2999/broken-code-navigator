class_name PauseScreen
extends CanvasLayer

signal main_menu
signal closed

@export var save_load_manager: SaveLoadManager;

@onready var panel: Panel = $Panel
@onready var load_screen: LoadScreen = $Panel/LoadScreen

var is_open = false;

var tween: Tween
var image: Image

func _ready() -> void:
	load_screen.save_load_manager = save_load_manager

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
	load_screen.open()

func _on_main_menu_pressed() -> void:
	main_menu.emit()


func _on_load_screen_loaded_file(file_name: String) -> void:
	save_load_manager.load_file(file_name);
	close();
