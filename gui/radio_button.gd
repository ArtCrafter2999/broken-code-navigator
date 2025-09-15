@tool
extends Control
class_name RadioButton

signal pressed();
signal toggled(toggled_on: bool);

@export var text: String:
	get: return $Button.text;
	set(value):
		if is_instance_valid(%Button):
			%Button.text = value;
		elif is_instance_valid($Button):
			$Button.text = value;
		elif is_instance_valid(button):
			button.text = value;
@export var button_pressed: bool:
	get: return $Button.button_pressed;
	set(value): 
		if is_instance_valid(%Button):
			%Button.button_pressed = value;
		elif is_instance_valid($Button):
			$Button.button_pressed = value;
		elif is_instance_valid(button):
			button.button_pressed = value;
@export var disabled: bool:
	get: return $Button.disabled;
	set(value): 
		if is_instance_valid(%Button):
			%Button.disabled = value;
		elif is_instance_valid($Button):
			$Button.disabled = value;
		elif is_instance_valid(button):
			button.disabled = value;
@export var button_group: ButtonGroup:
	get: return $Button.button_group;
	set(value): 
		if is_instance_valid(%Button):
			%Button.button_group = value;
		elif is_instance_valid($Button):
			$Button.button_group = value;
		elif is_instance_valid(button):
			button.button_group = value;

@onready var button: CheckBox = %Button;

func _ready() -> void:
	button.pressed.connect(pressed.emit)
	button.toggled.connect(toggled.emit);
