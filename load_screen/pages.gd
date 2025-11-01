extends HBoxContainer
class_name Pages

signal page_selected(page: int)

var prev_pages: int
var page_button_template: GeneralMenuButton;

func _ready() -> void:
	var child = get_child(0)
	page_button_template = child.duplicate()
	child.queue_free();

func render(pages):
	if prev_pages == pages: return;
	if !prev_pages: prev_pages = pages;
	
	prev_pages = pages;
	for child in get_children():
		child.queue_free();
		
	for page_index in range(pages):
		var page_button = page_button_template.duplicate()
		page_button.text = str(page_index+1)
		page_button.pressed.connect(func (): page_selected.emit(page_index +1))
		add_child(page_button)
