class_name LoadScreen;
extends Control

signal loaded_file(file_name: String)
signal deleted_file(file_name: String)
signal renamed_file(old_filename: String, new_filename: String)
signal back_pressed

@export var save_load_manager: SaveLoadManager;

@onready var pages: Pages = $Pages
@onready var grid_container: GridContainer = %GridContainer
@onready var delete_confirmation_dialog: Panel = $DeleteConfirmationDialog
@onready var rename_dialog: Panel = $RenameDialog
@onready var new_name: TextEdit = %NewName

const CREATE_SAVE_BUTTON = preload("res://load_screen/create_save_button.tscn")

var opened = false;
var load_slot_template: LoadSlot
var saves: Array[Dictionary]
var dialog_file_context = null;

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
	render();
	
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT);
	
func close():
	if not opened: return;
	opened = false;
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.5).finished
	for node in grid_container.get_children():
		node.queue_free()
	hide();

func render(page: int = 1):
	for child in grid_container.get_children():
		child.queue_free();
	
	pages.render(ceili(saves.size()/4.0), page);
	
	var pageItems = saves.slice((page - 1) * 4, ((page) * 4)) 
	for save in pageItems:
		var file = save["file"]
		var image = save["image"]
		var load_slot = load_slot_template.duplicate() as LoadSlot
		load_slot.image = image;
		load_slot.file_name = file;
		load_slot.pressed.connect(func (): load_file(file))
		load_slot.context_menu_open.connect(_close_all_context_menu)
		load_slot.on_delete.connect(func (): _on_delete_init(file))
		load_slot.on_rename.connect(func (): _on_rename_init(file))
		grid_container.add_child(load_slot)
	pass

func _close_all_context_menu():
	for child in grid_container.get_children():
		if child is LoadSlot:
			child.context_menu.visible = false;

func _on_back_button_pressed() -> void:
	back_pressed.emit();

func _on_delete_init(file_name: String):
	delete_confirmation_dialog.visible = true;
	dialog_file_context = file_name
	_close_all_context_menu();

func _on_dialogs_close() -> void:
	delete_confirmation_dialog.visible = false;
	rename_dialog.visible = false;
	dialog_file_context = null;

func _on_delete_button_pressed() -> void:
	save_load_manager.remove_file(dialog_file_context);
	_on_dialogs_close();
	saves = save_load_manager.get_save_files()
	saves.reverse();
	render();
	
func _on_rename_init(file_name: String):
	rename_dialog.visible = true;
	dialog_file_context = file_name
	new_name.placeholder_text = file_name.substr(0, file_name.rfind("."))
	_close_all_context_menu();

func _on_confirm_edit_button_pressed() -> void:
	save_load_manager.rename_file(dialog_file_context, new_name.text)
	_on_dialogs_close();
	saves = save_load_manager.get_save_files()
	saves.reverse();
	render()
