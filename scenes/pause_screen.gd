class_name PauseScreen
extends CanvasLayer

signal main_menu
signal closed

@export var save_load_manager: SaveLoadManager;

@onready var panel: Panel = $Panel

var is_open = false;

var tween: Tween

func close():
	if not is_open: return;
	closed.emit()
	is_open = false;
	
	if tween:
		tween.kill();
		
	var tween = get_tree().create_tween()
	tween.tween_property(panel, "modulate", Color.TRANSPARENT, 0.2)
	await tween.finished
	
	if is_open: return;
	
	visible = false

func open():
	if is_open: return;
	is_open = true
	visible = true;
	if tween:
		tween.kill();
		
	var tween = get_tree().create_tween()
	tween.tween_property(panel, "modulate", Color.WHITE, 0.2)
	await tween.finished
	
	if not is_open: return;


func _on_save_pressed() -> void:
	save_load_manager.save_file()

func _on_load_pressed() -> void:
	save_load_manager.load_file()
	close();

func _on_main_menu_pressed() -> void:
	main_menu.emit()
