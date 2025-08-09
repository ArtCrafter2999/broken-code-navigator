@tool
class_name GeneralMenuButton
extends BaseButton

@export var text: String:
	get: 
		return text;
	set(value):
		text = value;
		if is_instance_valid(%Label):
			%Label.text = value;
		elif is_instance_valid($CenterContainer/Label):
			$CenterContainer/Label.text = value;
		elif is_instance_valid(label):
			label.text = value;
@export var font_size: int:
	get:
		return font_size;
	set(value): 
		font_size = value
		if is_instance_valid(%Label):
			%Label.add_theme_font_size_override("font_size", value);
		elif is_instance_valid($CenterContainer/Label):
			$CenterContainer/Label.add_theme_font_size_override("font_size", value);
		elif is_instance_valid(label):
			label.add_theme_font_size_override("font_size", value);

@onready var outline: TextureRect = $Outline
@onready var hover_outline: TextureRect = $HoverOutline
@onready var pressed_outline: TextureRect = $PressedOutline
@onready var background: TextureRect = $MarginContainer/Background
@onready var hover_background: TextureRect = $MarginContainer/HoverBackground
@onready var pressed_background: TextureRect = $MarginContainer/PressedBackground
@onready var disabled_background: TextureRect = $MarginContainer/DisabledBackground

@onready var label: Label = $CenterContainer/Label

func _ready() -> void:
	mouse_entered.connect(func (): 
		if disabled: return;
		fade_in(hover_background, 0.3)
		fade_in(hover_outline, 0.3))
	mouse_exited.connect(func (): 
		if disabled: return;
		fade_out(hover_background, 0.3)
		fade_out(hover_outline, 0.3))
	button_down.connect(func ():
		if disabled: return;
		fade_in(pressed_background, 0.1)
		fade_in(pressed_background, 0.1)
		to_black(label, 0.1))
	button_up.connect(func ():
		if disabled: return;
		fade_out(pressed_background, 0.1)
		fade_out(pressed_background, 0.1)
		to_white(label, 0.1))

var _prev_disabled = false;
func _process(_delta: float) -> void:
	if not _prev_disabled and disabled:
		fade_in(disabled_background, 0.1)
	elif _prev_disabled and not disabled:
		fade_out(disabled_background, 0.1)
	
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not disabled else Control.CURSOR_ARROW
	_prev_disabled = disabled

func fade_in(texture: Control, time: float):
	if not texture: return;
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.WHITE, time).from(Color.TRANSPARENT)
	
func fade_out(texture: Control, time: float):
	if not texture: return;
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.TRANSPARENT, time).from(Color.WHITE)

func to_black(texture: Control, time: float):
	if not texture: return;
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.BLACK, time)
	
func to_white(texture: Control, time: float):
	if not texture: return;
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.WHITE, time)
