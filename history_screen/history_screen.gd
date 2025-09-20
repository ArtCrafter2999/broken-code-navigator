extends Panel
class_name HistoryScreen

signal back_pressed

@onready var records_container: VBoxContainer = $MarginContainer/ScrollContainer/RecordsContainer
@onready var scroll_container: ScrollContainer = $MarginContainer/ScrollContainer

var opened = false;
var record_template: HistoryRecord
var play_scene: PlayScene;
var pages: int = 1
var max_scroll: int: 
	get:
		return records_container.size.y - scroll_container.size.y

func _ready() -> void:
	var child = records_container.get_child(0)
	record_template = child.duplicate()
	child.queue_free();

func open():
	if opened: return;
	opened = true;
	pages = 1;
	show();
	#var saves = save_load_manager.get_save_files()
	
	var history = play_scene.ballon.history
	
	for line_id in history.slice(history.size() - pages * 30):
		var record = _get_history_record(line_id);
		records_container.add_child(record)
	
	
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT);
	await get_tree().process_frame
	scroll_container.scroll_vertical = max_scroll
	
func close():
	if not opened: return;
	opened = false;
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.5).finished
	for node in records_container.get_children():
		node.queue_free()
	hide();

func _get_history_record(line_id: String) -> HistoryRecord:
	var line = play_scene.get_line(line_id)
	var record = record_template.duplicate() as HistoryRecord;
	record.character = line.character
	var character = play_scene.characters_dict.get(line.character, null) as Character
	if not character: # if character is not unknown to player it could have other name
		var ch_tag = line.get_tag_value("ch")
		if ch_tag:
			character = play_scene.characters_dict.get(ch_tag, null)
	
	record.character_color = character.color if character else play_scene.defaut_character_color
	record.text = line.text
	return record

func _on_back_button_pressed() -> void:
	back_pressed.emit()

var loading: bool = false;

func _on_scroll_container_gui_input(event: InputEvent) -> void:
	if loading or not (event is InputEventMouseButton and \
			(event.button_index == MOUSE_BUTTON_WHEEL_UP or \
			event.button_index == MOUSE_BUTTON_WHEEL_DOWN)):
				return;
	loading = true;
	var scroll_bottom = max_scroll - scroll_container.scroll_vertical;
	var history = play_scene.ballon.history
	if scroll_container.scroll_vertical <= 100 and (pages + 1) * 30 < history.size() + 30:
		pages += 1
		var page
		if pages * 30 < history.size():
			page = history.slice(history.size() - pages * 30, history.size() - (pages-1) * 30)
		else:
			page = history.slice(0, history.size() - (pages-1) * 30)
		var prev = null;
		for line_id in page:
			var record = _get_history_record(line_id);
			if not prev:
				records_container.add_child(record)
				records_container.move_child(record, 0)
			else:
				prev.add_sibling(record)
			prev = record
		
		await get_tree().process_frame
		scroll_container.scroll_vertical = max_scroll - scroll_bottom;
	loading = false;
