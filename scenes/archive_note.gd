extends Control

var opened = false;

func open():
	if opened: return;
	opened = true;
	show();

	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT);
	await get_tree().create_timer(2).timeout
	await _close();
	
func _close():
	if not opened: return;
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.5).finished
	opened = false;
	hide();
