extends Slider
class_name LabeledSlider

@onready var label: Label = $Label
@onready var audio_click: AudioStreamPlayer = $AudioClick
@onready var audio_hover: AudioStreamPlayer = $AudioHover

var _is_dragging: bool = false;

func _process(delta: float) -> void:
	label.text = "(%s)" % int(value)

func _slider_drag_started():
	audio_hover.play();
func _slider_drag_ended():
	audio_click.play();

func play_hover():
	if not _is_dragging:
		audio_hover.play();
