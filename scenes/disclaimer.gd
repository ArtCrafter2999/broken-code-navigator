extends TextureRect

signal finished;

@onready var timer: Timer = $Timer

func _ready() -> void:
	create_tween().tween_property(self, "modulate", Color.WHITE, 1).from(Color.BLACK).finished

func _on_timer_timeout() -> void:
	timer.stop()
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 1).finished
	finished.emit()
	queue_free()

func _on_gui_input(event: InputEvent) -> void:
	if Input.is_anything_pressed():
		_on_timer_timeout();
