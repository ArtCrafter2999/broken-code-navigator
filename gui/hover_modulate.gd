extends Button

@export var hover_modulate: Color;

var begnining_modulate

var tween: Tween

func _ready():
	begnining_modulate = modulate;
	mouse_entered.connect(_hover)
	mouse_exited.connect(_hover_out)
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("HideUI"):
		modulate = Color.TRANSPARENT;
	else:
		modulate = Color.WHITE;

func _hover():
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", hover_modulate, 0.3)
	
func _hover_out():
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", begnining_modulate, 0.3)
