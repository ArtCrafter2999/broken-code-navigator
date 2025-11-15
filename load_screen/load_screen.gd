class_name LoadScreen;
extends Control

signal loaded_file(file_name: String)
signal back_pressed

@export var save_load_manager: SaveLoadManager;
@onready var pages: Pages = $Pages

@onready var grid_container: GridContainer = %GridContainer

var opened = false;
var load_slot_template: LoadSlot
var saves: Array[Dictionary]

func _ready() -> void:
	var child = grid_container.get_child(0)
	load_slot_template = child.duplicate()
	child.queue_free();

func load_file(file_name: String):
	if not opened: return;
	loaded_file.emit(file_name);
	close();

func open():
	if opened: return;
	opened = true;
	show();
	saves = save_load_manager.get_save_files()
	saves.reverse();
	_render();
	
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT);
	
func close():
	if not opened: return;
	opened = false;
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.5).finished
	for node in grid_container.get_children():
		node.queue_free()
	hide();

func _render(page: int = 1):
	for child in grid_container.get_children():
		child.queue_free();
		
	pages.render(ceili(saves.size()/4.0));
	
	var pageItems = saves.slice((page - 1) * 4, ((page) * 4)) 
	for save in pageItems:
		var file = save["file"]
		var image = save["image"]
		var load_slot = load_slot_template.duplicate() as LoadSlot
		load_slot.image = image;
		load_slot.file_name = file;
		load_slot.pressed.connect(func (): load_file(file))
		grid_container.add_child(load_slot)
	pass

func _on_back_button_pressed() -> void:
	back_pressed.emit();
