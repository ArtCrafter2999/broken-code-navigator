extends Control

@export var controls: Array[ParallaxElement]
@export var maximum_movement: Vector2

var _previous_screen_percent: Vector2 = Vector2(0,0)

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)

func _process(_delta: float) -> void:
	var mouse_position = get_global_mouse_position();
	var screen_percent = _calculate_screen_percent(mouse_position)
	_set_parallax(screen_percent)

func _calculate_screen_percent(global_pos: Vector2) -> Vector2 :
	var viewport_size = get_viewport_rect().size
	var p = global_pos.clamp(Vector2.ZERO, viewport_size) / viewport_size - Vector2(0.5,0.5)

	p.clamp(Vector2.ONE * -0.5, Vector2.ONE * 0.5)
	return p

func _set_parallax(screen_percent: Vector2) -> void:
	var move = maximum_movement
	for c in controls:
		c.position = move * screen_percent * c.modifier
	_previous_screen_percent = screen_percent

func _on_focus_changed(node: Control) -> void:
	var p =_calculate_screen_percent( node.global_position)
	var t = create_tween()
	t.tween_method(_set_parallax, _previous_screen_percent,  p, 0.25)
