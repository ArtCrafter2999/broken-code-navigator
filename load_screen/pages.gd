extends HBoxContainer
class_name Pages

signal page_selected(page: int)

var prev_pages: int
var prev_page: int
var page_button_template: GeneralMenuButton;

func _ready() -> void:
	var child = get_child(0)
	page_button_template = child.duplicate()
	child.queue_free();

func render(pages: int, page: int):
	if prev_pages == pages and prev_page == page: return;
	prev_pages = pages;
	prev_page = page;
	
	prev_pages = pages;
	for child in get_children():
		child.queue_free();
	
	var layout = _get_page_layout(pages, page)
	for page_index in layout:
		var page_button = page_button_template.duplicate()
		page_button.text = str(page_index)
		if str(page) == str(page_index):
			page_button.text = "[%s]" % str(page_index)
		if str(page_index) != "...":
			page_button.pressed.connect(func (): page_selected.emit(page_index))
		add_child(page_button)

func _get_page_layout(pages: int, page: int):
	if pages < 9:
		return range(pages)
	if page < 6:
		return [1,2,3,4,5, 6, "...", pages-1, pages]
	if page > pages - 5:
		return [1,2, "...", pages-5, pages-4, pages-3, pages-2, pages-1, pages]
	return [1,2, "...", page-1, page, page+1, "...", pages-1, pages]
