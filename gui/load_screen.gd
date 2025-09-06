class_name LoadScreen;
extends Control

signal loaded_file(file_name: String)
signal back_pressed

@export var save_load_manager: SaveLoadManager;
const LOAD_SLOT = preload("res://gui/load_slot.tscn")

@onready var grid_container: GridContainer = $ScrollContainer/MarginContainer/GridContainer

var opened = false;

func load_file(file_name: String):
	if not opened: return;
	loaded_file.emit(file_name);
	close();

func open():
	if opened: return;
	opened = true;
	show();
	var saves = save_load_manager.get_save_files()
	for save in saves:
		var file = save["file"]
		var image = save["image"]
		var load_slot = LOAD_SLOT.instantiate() as LoadSlot
		load_slot.image = image
		load_slot.pressed.connect(func (): load_file(file))
		grid_container.add_child(load_slot)
	
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT);
	
func close():
	if not opened: return;
	opened = false;
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.5).finished
	for node in grid_container.get_children():
		node.queue_free()
	hide();

func _on_back_button_pressed() -> void:
	back_pressed.emit();
