extends Control
class_name LabeledSlider

@onready var slider: HSlider = %Slider
@onready var label: Label = $Label
@onready var audio_click: AudioStreamPlayer = $AudioClick
@onready var audio_hover: AudioStreamPlayer = $AudioHover

var _is_dragging: bool = false;

signal value_changed(value: float)

func _ready() -> void:
	slider.value_changed.connect(value_changed.emit)

func _process(delta: float) -> void:
	label.text = "(%s)" % int(slider.value)

func set_value_no_signal(value: float):
	slider.set_value_no_signal(value)

func _slider_drag_started():
	audio_hover.play();
func _slider_drag_ended():
	audio_click.play();

func play_hover():
	if not _is_dragging:
		audio_hover.play();
