extends Control
class_name AboutScreen

var opened = false;

func open():
	if opened: return;
	opened = true;
	show();

	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT);
	await get_tree().process_frame
	
func close():
	if not opened: return;
	opened = false;
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.5).finished
	hide();
