extends Node

signal skip_changed(value: bool);

var should_skip: bool = false;
var is_skipping: bool = false;
var check_skip: Callable

var prev_skip = false;

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Skip"):
		should_skip = true;
	if Input.is_action_just_pressed("SkipToggle"):
		should_skip = !should_skip
	if Input.is_action_just_released("Skip"):
		should_skip = false;
	
	var is_changed;
	if should_skip and check_skip:
		var new_skipping = check_skip.call()
		is_changed = new_skipping != is_skipping
		is_skipping = new_skipping
	else:
		is_changed = is_skipping
		is_skipping = false
		
	if is_changed:
		skip_changed.emit(is_skipping)
